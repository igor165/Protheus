#INCLUDE "APWEBEX.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSMGER.CH"

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �PPLCAB    �Autor  � Thiago Guilherme      � Data �024/01/14  ���
��������������������������������������������������������������������������Ĵ��
���          �Cria o cabe�alho das not�cias no portal					     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
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
cRet += "<h4><center>Espa�o Not�cias</center></BODY></HTML></h4>"
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


