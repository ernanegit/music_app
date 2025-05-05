# Script para criar a estrutura de diretórios do projeto Músico App
# Executar no diretório raiz do projeto Flutter

# Criar diretórios principais na pasta lib
$libPath = ".\lib"
$directories = @(
    "config",
    "models",
    "services",
    "providers",
    "screens\auth",
    "screens\profile",
    "screens\musician",
    "screens\portfolio",
    "screens\contract",
    "screens\review",
    "widgets\common",
    "widgets\musician",
    "widgets\portfolio",
    "widgets\contract",
    "widgets\review",
    "utils"
)

# Criar cada diretório
foreach ($dir in $directories) {
    $path = Join-Path -Path $libPath -ChildPath $dir
    if (-not (Test-Path -Path $path)) {
        New-Item -Path $path -ItemType Directory -Force
        Write-Host "Diretório criado: $path" -ForegroundColor Green
    } else {
        Write-Host "Diretório já existe: $path" -ForegroundColor Yellow
    }
}

# Criar pasta de assets para imagens e arquivos
$assetsDirectories = @(
    ".\assets\images",
    ".\assets\icons"
)

foreach ($dir in $assetsDirectories) {
    if (-not (Test-Path -Path $dir)) {
        New-Item -Path $dir -ItemType Directory -Force
        Write-Host "Diretório criado: $dir" -ForegroundColor Green
    } else {
        Write-Host "Diretório já existe: $dir" -ForegroundColor Yellow
    }
}

Write-Host "Estrutura de diretórios criada com sucesso!" -ForegroundColor Cyan