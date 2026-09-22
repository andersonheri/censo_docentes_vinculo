# ============================================================
# gerar_docx.ps1
# Gera relatorio_descritivo_docentes_2025.docx a partir do .md
# ============================================================
#
# Usa referencia_com_rodape.docx como --reference-doc: é o reference
# docx padrão do pandoc com um footer1.xml adicionado manualmente (via
# unzip/edição de XML/zip), contendo um campo PAGE centralizado. Sem
# isso, o docx gerado pelo pandoc não tem nenhum rodapé/numeração de
# página. Se precisar recriar essa referência do zero, veja o
# histórico do commit que a introduziu.

$pandoc = "C:\Program Files\RStudio\resources\app\bin\quarto\bin\tools\pandoc.exe"
$pasta  = $PSScriptRoot
$md     = Join-Path $pasta "relatorio_descritivo_docentes_2025.md"
$ref    = Join-Path $pasta "referencia_com_rodape.docx"
$docx   = Join-Path $pasta "relatorio_descritivo_docentes_2025.docx"

& $pandoc $md -o $docx --resource-path=$pasta --reference-doc=$ref
if ($LASTEXITCODE -ne 0) { throw "pandoc falhou" }

Write-Host ">>> DOCX salvo em: $docx ($((Get-Item $docx).Length) bytes)"
