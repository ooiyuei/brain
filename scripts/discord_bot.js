#!/usr/bin/env node
/**
 * Discord Bot - 大井湧瑛のBrainシステム双方向化
 *
 * 大井がDiscordでメッセージ送信 → このbotが受信
 *   → queue/inbox に投入 → worker.ps1 が処理 → Discord に返信
 *
 * 起動: node discord_bot.js
 * 常駐: PM2 or タスクスケジューラで自動起動
 */

const fs = require('fs');
const path = require('path');
const { Client, GatewayIntentBits, Partials } = require('discord.js');
const { execSync } = require('child_process');

const BRAIN_ROOT = 'C:\\Users\\Owner\\business\\brain';
const CONFIG_PATH = path.join(BRAIN_ROOT, 'scripts', 'config.json');
const QUEUE_INBOX = path.join(BRAIN_ROOT, 'queue', 'inbox');
const LOG_PATH = path.join(BRAIN_ROOT, 'scripts', 'discord_bot.log');

// Config 読み込み
const config = JSON.parse(fs.readFileSync(CONFIG_PATH, 'utf8'));
const BOT_TOKEN = config.discord.bot_token;
const WEBHOOK_URL = config.discord.webhook_url;

if (!BOT_TOKEN) {
    console.error('ERROR: bot_token not in config.json');
    process.exit(1);
}

const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMessages,
        GatewayIntentBits.MessageContent,
        GatewayIntentBits.DirectMessages,
    ],
    partials: [Partials.Channel, Partials.Message],
});

function log(msg) {
    const stamp = new Date().toISOString();
    const line = `${stamp} ${msg}\n`;
    fs.appendFileSync(LOG_PATH, line);
    console.log(line.trim());
}

// メッセージ受信
client.on('messageCreate', async (message) => {
    // Bot自身のメッセージは無視
    if (message.author.bot) return;

    // 大井からのメッセージか確認（任意：特定userのみ受け付ける場合）
    log(`Received from ${message.author.tag}: ${message.content.substring(0, 100)}`);

    const content = message.content.trim();
    if (!content) return;

    // コマンド処理
    if (content.startsWith('!')) {
        await handleCommand(message, content);
    } else {
        // 通常メッセージ → OpenClaw に投入
        await dispatchToOpenClaw(message, content);
    }
});

async function handleCommand(message, content) {
    const cmd = content.toLowerCase();

    if (cmd === '!status' || cmd === '!ping') {
        // status 確認
        try {
            const inbox = fs.readdirSync(QUEUE_INBOX).length;
            const processing = fs.readdirSync(path.join(BRAIN_ROOT, 'queue', 'processing')).length;
            const todayDone = fs.readdirSync(path.join(BRAIN_ROOT, 'queue', 'done'))
                .filter(f => {
                    try {
                        const stat = fs.statSync(path.join(BRAIN_ROOT, 'queue', 'done', f));
                        return stat.mtime.toDateString() === new Date().toDateString();
                    } catch (e) { return false; }
                }).length;
            await message.reply(`📊 **Brain Status**\n📥 inbox: ${inbox}\n⚙️ processing: ${processing}\n✅ 今日完了: ${todayDone}`);
        } catch (e) {
            await message.reply(`❌ Error: ${e.message}`);
        }
        return;
    }

    if (cmd.startsWith('!help')) {
        await message.reply([
            '**🦞 Brain Bot コマンド**',
            '',
            '通常メッセージ → OpenClaw(qwen3.6)に処理依頼、結果が後で返信',
            '',
            '**特殊コマンド:**',
            '`!status` - キュー状況確認',
            '`!ping` - 同上',
            '`!help` - このヘルプ',
            '',
            '**使い方例:**',
            '`AIpa Web の競合5社調べて`',
            '`Twitter原稿10本書いて`',
            '`今日の業界ニュース要約して`',
        ].join('\n'));
        return;
    }

    await message.reply(`❓ Unknown command: ${cmd}\nTry !help`);
}

async function dispatchToOpenClaw(message, prompt) {
    try {
        // タスクID生成
        const taskId = require('crypto').randomBytes(4).toString('hex');
        const stamp = new Date().toISOString().replace(/[:.]/g, '-').substring(0, 19);
        const filename = `5-${stamp}-${taskId}.json`;
        const filepath = path.join(QUEUE_INBOX, filename);

        const title = prompt.length > 60 ? prompt.substring(0, 60) + '...' : prompt;

        const job = {
            id: taskId,
            title: `[Discord] ${title}`,
            department: 'misc',
            template: '',
            model: 'qwen3.6:latest',
            priority: 'normal',
            use_agent: false,
            prompt: prompt,
            context_files: [],
            output_path: '',
            retries: 0,
            created_at: new Date().toISOString(),
            requested_by: 'discord-bot',
            discord_channel_id: message.channelId,
            discord_message_id: message.id,
            discord_user: message.author.tag,
        };

        fs.writeFileSync(filepath, JSON.stringify(job, null, 2), 'utf8');

        // 受付確認のリアクション
        await message.react('🦞');
        await message.reply(`✅ 受け付けました (id: \`${taskId}\`)\nqwen3.6で処理開始。完了したら結果をここに返します。`);

        log(`Dispatched: ${taskId} - ${title}`);

        // ポーリング：results/<taskId>.md が出来たら返信
        watchForResult(taskId, message);

    } catch (e) {
        log(`Dispatch error: ${e.message}`);
        await message.reply(`❌ Dispatch failed: ${e.message}`);
    }
}

function watchForResult(taskId, originalMessage) {
    const resultPath = path.join(BRAIN_ROOT, 'queue', 'results', `${taskId}.md`);
    const failedDir = path.join(BRAIN_ROOT, 'queue', 'failed');

    const checkInterval = setInterval(() => {
        // 成功確認
        if (fs.existsSync(resultPath)) {
            clearInterval(checkInterval);
            const content = fs.readFileSync(resultPath, 'utf8');
            // frontmatter除去して本文だけ
            const body = content.replace(/^---[\s\S]*?---\n\n/, '');
            const truncated = body.length > 1800 ? body.substring(0, 1800) + '\n...(続く)' : body;

            originalMessage.reply(`🎉 完了 \`${taskId}\`\n\n${truncated}`).catch(e => log(`Reply error: ${e.message}`));
            log(`Replied: ${taskId}`);
            return;
        }

        // 失敗確認
        const failedFiles = fs.readdirSync(failedDir).filter(f => f.includes(taskId));
        if (failedFiles.length > 0) {
            clearInterval(checkInterval);
            originalMessage.reply(`❌ 失敗 \`${taskId}\` - リトライ後も失敗しました`).catch(() => {});
            log(`Failed: ${taskId}`);
            return;
        }
    }, 5000); // 5秒おき

    // 30分タイムアウト
    setTimeout(() => {
        clearInterval(checkInterval);
    }, 30 * 60 * 1000);
}

client.once('ready', () => {
    log(`✅ Bot online: ${client.user.tag}`);

    // webhook で起動通知
    if (WEBHOOK_URL) {
        require('https').request(new URL(WEBHOOK_URL), {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' }
        }, () => {}).end(JSON.stringify({
            username: '🦞 Brain Bot',
            embeds: [{
                title: '🟢 Brain Bot オンライン',
                description: `Discord双方向化 稼働中\nコマンド: \`!help\``,
                color: 5763719
            }]
        }));
    }
});

client.on('error', (e) => log(`Client error: ${e.message}`));

client.login(BOT_TOKEN);
