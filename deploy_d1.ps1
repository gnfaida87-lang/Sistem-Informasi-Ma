# ============================================================
# SCRIPT DEPLOY SCHEMA KE CLOUDFLARE D1
# Jalankan: .\deploy_d1.ps1 -Token "your_api_token" -DbName "nama_db_d1"
# ============================================================

param(
    [Parameter(Mandatory=$true)]
    [string]$Token,
    
    [Parameter(Mandatory=$true)]
    [string]$DbName
)

$env:CLOUDFLARE_API_TOKEN = $Token

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host " DEPLOY SCHEMA KE CLOUDFLARE D1" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Cek list D1
Write-Host "[1/3] Mengecek daftar D1 database..." -ForegroundColor Yellow
wrangler d1 list

Write-Host ""
Write-Host "[2/3] Menjalankan schema SQL ke D1: $DbName ..." -ForegroundColor Yellow
Write-Host ""

# Step 2: Execute schema
wrangler d1 execute $DbName --remote --file=schema_lengkap_d1.sql

Write-Host ""
Write-Host "[3/3] Verifikasi tabel..." -ForegroundColor Yellow
wrangler d1 execute $DbName --remote --command="SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;"

Write-Host ""
Write-Host "======================================" -ForegroundColor Green
Write-Host " SELESAI! Schema berhasil dimasukkan." -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
