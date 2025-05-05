# Script para enviar o projeto Flutter para o GitHub
# Executar no diretório raiz do projeto Flutter

# URL do repositório remoto
$repoUrl = "https://github.com/ernanegit/music_app.git"

# Verificar se o Git está instalado
try {
    $gitVersion = git --version
    Write-Host "Git encontrado: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "ERRO: Git não encontrado. Por favor, instale o Git antes de continuar." -ForegroundColor Red
    exit 1
}

# Verificar se estamos no diretório correto (raiz do projeto Flutter)
if (-not (Test-Path -Path "pubspec.yaml")) {
    Write-Host "ERRO: Arquivo pubspec.yaml não encontrado. Certifique-se de estar na pasta raiz do projeto Flutter." -ForegroundColor Red
    exit 1
}

Write-Host "Iniciando processo de envio para o GitHub..." -ForegroundColor Cyan

try {
    # Verificar se já é um repositório Git
    $isGitRepo = Test-Path -Path ".git" -PathType Container
    
    if (-not $isGitRepo) {
        # Inicializar o repositório Git local
        Write-Host "Inicializando repositório Git local..." -ForegroundColor Cyan
        git init
        
        # Adicionar o repositório remoto
        Write-Host "Adicionando repositório remoto..." -ForegroundColor Cyan
        git remote add origin $repoUrl
    } else {
        Write-Host "Repositório Git já inicializado." -ForegroundColor Yellow
        
        # Verificar se o remote origin já existe
        $remoteExists = git remote -v | Select-String -Pattern "origin"
        
        if (-not $remoteExists) {
            # Adicionar o repositório remoto se não existir
            Write-Host "Adicionando repositório remoto..." -ForegroundColor Cyan
            git remote add origin $repoUrl
        } else {
            # Atualizar a URL do repositório remoto se já existir
            Write-Host "Atualizando URL do repositório remoto..." -ForegroundColor Cyan
            git remote set-url origin $repoUrl
        }
    }
    
    # Criar arquivo .gitignore se não existir
    if (-not (Test-Path -Path ".gitignore")) {
        Write-Host "Criando arquivo .gitignore..." -ForegroundColor Cyan
        @"
# Miscellaneous
*.class
*.log
*.pyc
*.swp
.DS_Store
.atom/
.buildlog/
.history
.svn/
migrate_working_dir/

# IntelliJ related
*.iml
*.ipr
*.iws
.idea/

# The .vscode folder contains launch configuration and tasks you configure in
# VS Code which you may wish to be included in version control, so this line
# is commented out by default.
#.vscode/

# Flutter/Dart/Pub related
**/doc/api/
**/ios/Flutter/.last_build_id
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
/build/

# Symbolication related
app.*.symbols

# Obfuscation related
app.*.map.json

# Android Studio will place build artifacts here
/android/app/debug
/android/app/profile
/android/app/release
"@ | Out-File -FilePath ".gitignore" -Encoding utf8
    }
    
    # Adicionar todos os arquivos ao stage
    Write-Host "Adicionando arquivos ao stage..." -ForegroundColor Cyan
    git add .
    
    # Realizar o commit
    Write-Host "Realizando commit..." -ForegroundColor Cyan
    git commit -m "Configuração inicial do projeto Músico App"
    
    # Configurar a branch principal para 'main' se for um novo repositório
    if (-not $isGitRepo) {
        Write-Host "Configurando branch principal para 'main'..." -ForegroundColor Cyan
        git branch -M main
    }
    
    # Enviar para o GitHub
    Write-Host "Enviando para o GitHub..." -ForegroundColor Cyan
    git push -u origin main
    
    Write-Host @"
=====================================
 ENVIO PARA GITHUB CONCLUÍDO
=====================================
Os arquivos do projeto Músico App foram enviados com sucesso para:
$repoUrl

Você pode acessar seu repositório online em:
https://github.com/ernanegit/music_app
"@ -ForegroundColor Green

} catch {
    Write-Host "ERRO ao enviar para o GitHub: $_" -ForegroundColor Red
    
    # Sugestões para problemas comuns
    Write-Host @"
Sugestões para resolver problemas comuns:

1. Verifique se você tem permissão para acessar o repositório.
2. Se você nunca usou o Git antes nesta máquina, talvez precise configurar seu nome e email:
   git config --global user.name "Seu Nome"
   git config --global user.email "seu.email@exemplo.com"
3. Se você está usando autenticação de dois fatores no GitHub, será necessário usar um token de acesso pessoal em vez de senha:
   https://github.com/settings/tokens
4. Para tentar novamente mais tarde, execute:
   git push -u origin main
"@ -ForegroundColor Yellow
}