#INCLUDE "APWEBEX.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSMGER.CH"

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PPLCAB    ³Autor  ³ Thiago Guilherme      ³ Data ³024/01/14  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Cria o cabeçalho das notícias no portal					     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Web Function PPLCAB()

LOCAl cRet := ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

cRet := "<html>"
cRet += "<head>"
cRet += "<link href='imagens-pls/estilo.css' rel='stylesheet' type='text/css'>"
cRet += "<style type=text/css>"
cRet += "body { margin:0px; }"
cRet += "</style>"
cRet += "<script type='text/javascript' src='imagens-pls/jquery-1.7.1.min.js'></script> "
cRet += "<script type='text/javascript' src='imagens-pls/jspls.js'></script>"
cRet += "</head>"
cRet += "<BODY>"
cRet += "<div id='cab' onclick='openNews()'>"
cRet += "<h4><center>Espaço Notícias</center></BODY></HTML></h4>"
cRet += "<span class='imgCabSpan'>"
cRet += "<img src='imagens-pls/hideNews.png' id='shNews' alt='expand/collapse' height='16' width='16' class='imgCab'/>"
cRet += "</span>"
cRet += "<span class='imgCabSpan'>"
cRet += "<img src='imagens-pls/news.png' alt='expand/collapse' height='16' width='16' class='imgCab'/>"
cRet += "</span>"
cRet += "</div>"
cRet += "</body>"
cRet += "</html>"

WEB EXTENDED END

Return cRet


