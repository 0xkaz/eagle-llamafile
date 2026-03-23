curl -fsSL https://bun.sh/install | bash
# インストール後、ターミナルを再起動
bun --version  # 確認



claude   --allow-dangerously-skip-permissions --dangerously-skip-permissions 




/plugin install discord@claude-plugins-official
/plugin install telegram@claude-plugins-official


claude --channels plugin:telegram@claude-plugins-official --allow-dangerously-skip-permissions --dangerously-skip-permissions --resume f5c0d451-2d7d-4a74-b4a8-004a678e1f5d



/telegram:configure  
However, please don't write to ~/.claude/channels/telegram/ directly. Instead, you can setup TELEGRAM_STATE_DIR in .claude/settings.json to point to .claude/channels/telegram/ in this repo.
access.jsonは、~/.claude/channels/telegram/以下ではなく、このレポ以下の .claude/channels/telegramsいかに保存してください。


/telegram:access pair 






claude --channels plugin:telegram@claude-plugins-official --allow-dangerously-skip-permissions --dangerously-skip-permissions --resume f5c0d451-2d7d-4a74-b4a8-004a678e1f5d
