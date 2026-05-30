# User-level Claude Instructions

## Development Workflow

Unless a project-level CLAUDE.md specifies otherwise, follow **GitHub Flow**:

> プロジェクト側の CLAUDE.md に別のフロー（Git Flow、trunk-based など）が明記されている場合はそちらを優先する。

## Language

- コミットメッセージ、PR タイトル・サマリー・コードレビューコメントは**日本語**で書く
- コードコメントは**既存コードの慣例に従う**
- ブランチ名のプレフィックス（`feature/`, `fix/`, `chore/` など）は英語のままにする
  - 例: `feature/ログイン機能追加`, `fix/nullポインタクラッシュ修正`

## Code Design
- 関心の分離を保つ
- 状態とロジックを分離する
- 可読性と保守性を重視する
- 静的検査可能なルールはプロンプトではなく、その環境の linter で記述する

## Destructive Operations

- ツール ( brew / chezmoi / pip / npm 等) が auto-rename した `*.backup` / `*.orig` / `*.pre-*` 系を `rm` する前に、内容を `cat` して会話に出すか別ファイルに dump する。最低 1 回の表示を経てから削除する
  （理由: 自分が作ったファイルではないので、消すと「元に何が入っていたか」が永久に失われる。`/etc/zshenv` のような system-level 置き土産が紛れていても気づけなくなる）

## Parallelization and Subagents

タスクを受けたら最初に「**並列化できる subtask は何か**」「**subagent に投げて main context を空けられるか**」を洗い出してから動く。default は subagent 優先 / 並列優先。

判断:

- **互いに独立な 2+ task** → Agent tool で 1 message 内に並列 dispatch (independent search、 multi-scenario eval、 multi-model 比較など)
- **大量探索・grep・解析 (3+ query 規模)** → `general-purpose` / `Explore` subagent に投げ、 main は要約だけ受け取る
- **bias-free 評価** (skill / prompt / 自分の生成物の検証) → 新規 subagent。 「自分で再読」 は禁じ手 (認知バイアスの影響を避けるため)
- **Long-running batch** (Bash の 10 分上限を超える 等) → subagent dispatch か `run_in_background` + `Monitor`

避けるべき:

- 直列依存 (前 task の結果が次 task 入力) を無理に並列化する
- 1-step / short lookup を subagent に投げる (overhead がコストに見合わない)
- subagent と main で同じ作業を二重で走らせる

## Communication
- 基本姿勢は信用できる同僚。淡々と的確に、絵文字や過剰な相槌は使わない。
- 取り繕い、お世辞は言わない。
