# ============================================================
# gerar_pdf.ps1
# Gera relatorio_descritivo_docentes_2025.pdf a partir do .md
# ============================================================
#
# Por que este script existe: o .md deste relatorio NAO deve ser
# "Knitado" no RStudio (isso injeta output: pdf_document no YAML e
# tenta compilar via LaTeX/MiKTeX, que nao tem os pacotes necessarios
# instalados aqui). Em vez disso, o pipeline é:
#
#   1. pandoc converte o .md para .html autocontido (imagens
#      embutidas em base64), aplicando estilo_pdf.css (texto
#      justificado, espaçamento 1,5, tamanho A4).
#   2. o Microsoft Edge, em modo headless, imprime esse .html para
#      PDF via Chrome DevTools Protocol (CDP) diretamente -- os
#      flags de linha de comando do Edge para desativar o
#      cabeçalho/rodapé do navegador (--print-to-pdf-no-header etc.)
#      não funcionam nesta versão, então falamos direto com o
#      protocolo (Page.printToPDF), passando um footerTemplate
#      próprio (só número de página, sem data/URL/título) em vez do
#      cabeçalho/rodapé padrão do navegador.
#
# Pré-requisito: pandoc (empacotado com o RStudio/Quarto) e o
# Microsoft Edge instalados nos caminhos abaixo. Ajuste se necessário.

$pandoc = "C:\Program Files\RStudio\resources\app\bin\quarto\bin\tools\pandoc.exe"
$edge   = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
$pasta  = $PSScriptRoot
$md     = Join-Path $pasta "relatorio_descritivo_docentes_2025.md"
$css    = Join-Path $pasta "estilo_pdf.css"
$html   = Join-Path $pasta "relatorio_descritivo_docentes_2025.html"
$pdf    = Join-Path $pasta "relatorio_descritivo_docentes_2025.pdf"

Write-Host ">>> Convertendo .md para .html autocontido..."
& $pandoc $md -o $html --standalone --embed-resources --resource-path=$pasta --css=$css
if ($LASTEXITCODE -ne 0) { throw "pandoc falhou" }

Write-Host ">>> Imprimindo .html para PDF via Edge (CDP)..."
$port = 9333 + (Get-Random -Maximum 500)
$userDataDir = Join-Path $env:TEMP "edge_cdp_profile_$(Get-Random)"

Get-Process msedge -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 1
$proc = Start-Process -FilePath $edge -ArgumentList `
  "--headless=new", "--disable-gpu", "--no-sandbox", `
  "--remote-debugging-port=$port", "--user-data-dir=$userDataDir", "about:blank" `
  -PassThru
Start-Sleep -Seconds 2

$fileUrl = "file:///" + ($html -replace '\\', '/')
$encoded = [uri]::EscapeDataString($fileUrl)
$newTab = Invoke-RestMethod -Uri "http://localhost:$port/json/new?$encoded" -Method PUT
$wsUrl = $newTab.webSocketDebuggerUrl

$ws = New-Object System.Net.WebSockets.ClientWebSocket
$cts = New-Object System.Threading.CancellationTokenSource
$ws.ConnectAsync([Uri]$wsUrl, $cts.Token).GetAwaiter().GetResult() | Out-Null

# tempo para o HTML (imagens embutidas, ~7MB) carregar por completo
Start-Sleep -Seconds 3

function Send-CDP($obj) {
    $json = $obj | ConvertTo-Json -Depth 10 -Compress
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($json)
    $seg = New-Object System.ArraySegment[byte] (, $bytes)
    $ws.SendAsync($seg, [System.Net.WebSockets.WebSocketMessageType]::Text, $true, $cts.Token).GetAwaiter().GetResult() | Out-Null
}
function Receive-CDP() {
    $buffer = New-Object byte[] 1048576
    $ms = New-Object System.IO.MemoryStream
    do {
        $seg = New-Object System.ArraySegment[byte] (, $buffer)
        $result = $ws.ReceiveAsync($seg, $cts.Token).GetAwaiter().GetResult()
        $ms.Write($buffer, 0, $result.Count)
    } while (-not $result.EndOfMessage)
    return [System.Text.Encoding]::UTF8.GetString($ms.ToArray())
}

$footerTemplate = '<div style="width:100%; font-size:9px; text-align:center; color:#888; font-family: Arial, sans-serif;"><span class="pageNumber"></span></div>'

Send-CDP @{
    id     = 1
    method = "Page.printToPDF"
    params = @{
        printBackground     = $true
        displayHeaderFooter = $true
        headerTemplate      = "<span></span>"
        footerTemplate      = $footerTemplate
        preferCSSPageSize   = $true
        marginTop = 0; marginBottom = 0.4; marginLeft = 0; marginRight = 0
    }
}
$resp = Receive-CDP
$obj = $resp | ConvertFrom-Json
if ($obj.error) { throw "CDP retornou erro: $($obj.error | ConvertTo-Json -Depth 5)" }

[IO.File]::WriteAllBytes($pdf, [Convert]::FromBase64String($obj.result.data))
$ws.Dispose()
Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue

Write-Host ">>> PDF salvo em: $pdf ($((Get-Item $pdf).Length) bytes)"
