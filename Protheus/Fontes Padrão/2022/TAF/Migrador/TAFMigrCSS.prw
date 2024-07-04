//-------------------------------------------------------------------
/*/{Protheus.doc} TAFMigrCSS
Fonte genérico contendo os Cascade Style (CSS) utilizados nas interfaces
do Migrador
@author  Victor A. Barbosa
@since   08/10/2018
@version 1
/*/
//-------------------------------------------------------------------
Function TAFMigrCSS(cIDCSS)

Local cCSS := ""

Do Case

    Case cIDCSS == "BTFILE"
        cCSS += "QPushButton{ background-color: #3C7799; "
		cCSS += "border: none; "
		cCSS += "color: white;" 
		cCSS += "padding: 15px 32px;" 
		cCSS += "text-align: center; "
        cCSS += "text-decoration: none; "
		cCSS += "display: inline-block; "
		cCSS += "font-size: 12px; "
		cCSS += "border-radius: 2px "
        cCSS += "}"
		cCSS += "QPushButton:hover { "
    	cCSS += "background-color: #FFFFFF;"
		cCSS += "color: #3C7799;"
    	cCSS += "background-repeat: no-repeat;"
		cCSS += "border: 2px solid #3C7799; "
		cCSS += "border-radius: 2px "
		cCSS += "}"
		cCSS +=	"QPushButton:pressed {"
		cCSS +=	"  background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,"
		cCSS +=	"                                    stop: 0 #FFFFFF, stop: 1 #3C7799);"
		cCSS += "color: #000000;" 
		cCSS +=	"}"
    Case cIDCSS == "TEXTTITLE"
        cCSS +=	"QLabel{"
		cCSS += "  font-size: 20;"
		cCSS += "  font-weight: bold;"
		cCSS += "  color: #000000;"
		cCSS += "}"
	Case cIDCSS == "RADIO"
		cCSS +=	"QRadioButton{"
		cCSS +=	"  color: #3E97EB;"
		cCSS +=	"  font-size: 14px;"
		cCSS +=	"}"
		cCSS +=	"QRadioButton::indicator {"
		cCSS +=	"    width: 18px;"
		cCSS +=	"    height: 18px"
		cCSS +=	"    padding: 2px"
		cCSS +=	"}"
		cCSS +=	"QRadioButton::indicator:checked {"
		cCSS +=	"border: 1px solid; "
		cCSS +=	"border-color: rgb(132,132,132); "
		cCSS +=	"border-radius: 5px; "
		cCSS +=	"background-color: white; "
		cCSS +=	"width: 11px; "
		cCSS +=	"height: 11px; "
		cCSS +=	"}"
		cCSS +=	"QRadioButton::indicator::unchecked {"
		cCSS +=	"border: 3px solid; "
		cCSS +=	"border-color: white;"
		cCSS +=	"border-radius: 6px;"
		cCSS +=	"background-color: rgb(0,116,188); "
		cCSS +=	"width: 7px; "
		cCSS +=	"height: 7px; "
		cCSS +=	"}"
	Case cIDCSS == "METER"
		cCSS +=	"QProgressBar {"
		cCSS +=	"    border: 2px solid #953734;"
		cCSS +=	"    border-radius: 5px; "
		cCSS +=	"}"
		cCSS +=	"QProgressBar::chunk {"
		cCSS +=	"    background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,"
		cCSS +=	"		stop: 0 #C4BD97, stop: 1 #DDD9C3); "
		cCSS +=	"    width: 10px; "
		cCSS +=	"    margin: 0.5px; "
		cCSS +=	"}"
	Case cIDCSS == "BTPROC"
        cCSS += "QPushButton{ background-color: #3C7799; "
		cCSS += "border: none; "
		cCSS += "color: #FFFFFF;" 
		cCSS += "padding: 2px 5px;" 
		cCSS += "text-align: center; "
        cCSS += "text-decoration: none; "
		cCSS += "display: inline-block; "
		cCSS += "font-size: 16px; "
		cCSS += "border: 2px solid #3C7799; "
		cCSS += "border-radius: 2px "
        cCSS += "}"
		cCSS += "QPushButton:hover { "
    	cCSS += "background-color: #FFFFFF;"
		cCSS += "color: #3C7799;"
    	cCSS += "background-repeat: no-repeat;"
		cCSS += "border: 2px solid #3C7799; "
		cCSS += "border-radius: 2px "
		cCSS += "}"
		cCSS +=	"QPushButton:pressed {"
		cCSS +=	"  background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,"
		cCSS +=	"                                    stop: 0 #FFFFFF, stop: 1 #3C7799);"
		cCSS += "color: #000000;" 
		cCSS +=	"}"
	Case cIDCSS == "BTAPLICAR"
        cCSS += "QPushButton{ background-color: #3C7799; "
		cCSS += "border: none; "
		cCSS += "color: #FFFFFF;" 
		cCSS += "padding: 2px 5px;" 
		cCSS += "text-align: center; "
        cCSS += "text-decoration: none; "
		cCSS += "display: inline-block; "
		cCSS += "font-size: 12px; "
		cCSS += "border: 2px solid #3C7799; "
		cCSS += "border-radius: 2px "
        cCSS += "}"
		cCSS += "QPushButton:hover { "
    	cCSS += "background-color: #FFFFFF;"
		cCSS += "color: #3C7799;"
    	cCSS += "background-repeat: no-repeat;"
		cCSS += "border: 2px solid #3C7799; "
		cCSS += "border-radius: 2px "
		cCSS += "}"
		cCSS +=	"QPushButton:pressed {"
		cCSS +=	"  background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,"
		cCSS +=	"                                    stop: 0 #FFFFFF, stop: 1 #3C7799);"
		cCSS += "color: #000000;" 
		cCSS +=	"}"
	Case cIDCSS == "LINESEPARADOR"
		cCSS +=	"QLabel{"
		cCSS += "  font-size: 20;"
		cCSS += "  font-weight: bold;"
		cCSS += "  color: #BBBBBB;"
		cCSS += "}"
	Case cIDCSS == "CHECKBUTTON"
		cCSS +=	"QCheckBox {"
		cCSS +=	"  color: #3E97EB; "
		cCSS +=	"  font-size: 14px;"
		cCSS +=	"}"
		cCSS +=	"QCheckBox::indicator {"
		cCSS +=	"  width: 15px; "
		cCSS +=	"  height: 15px;"
		cCSS +=	"}"
		cCSS +=	"QCheckBox::indicator:checked {"
		cCSS +=	"    image: url(rpo:taf_check_on.png);"
		cCSS +=	"}"
		cCSS +=	"QCheckBox::indicator::unchecked {"
		cCSS +=	"    image: url(rpo:taf_check_off.png);"
		cCSS +=	"}"	
EndCase

Return(cCSS)

Function TAFMigrText(cInfo)

Local cRet := ""

If !GetRemoteType() == 5
	If cInfo == "BEMVINDO"
		cRet := '<font size="6" color="#0c9abe"><b> Bem vindo...</b></font>'
		cRet += '<br/>'
	EndIf

	If cInfo == "ASSIST"
		cRet += '<font size="5" color="#888"><b>Este é o assistente de importação dos XMLs transmitidos '
		cRet += 'através de sistemas terceiros para o TAF.</b></font>'
		cRet += '<br/>'
	EndIf
		
	If cInfo == "TITETAPAS"
		cRet += '<font size="5" color="#888">Esta rotina consiste de 2 etapas: </font>'
		cRet += '<br/>'
	EndIf

	If cInfo == "TEXTETAPAS"
		cRet += '<font size="4" color="#888"> 1 - Importação dos arquivos XMLs transmitidos e protocolados para uma tabela <b>intermediária</b>.</font><br/><br/>'
		cRet += '<font size="4" color="#888"> 2 - Envio das informações das tabela <b>intermediária</b> para o <b>TAF</b> .</font><br/><br/>'
	EndIf
Else
	If cInfo == "BEMVINDO"
		cRet := '<font size="5" color="#0c9abe"><b> Bem vindo...</b></font>'
		cRet += '<br/>'
	EndIf

	If cInfo == "ASSIST"
		cRet += '<font size="4" color="#888"><b>Este é o assistente de importação dos XMLs transmitidos</b>'
		cRet += '<br/> através de sistemas terceiros para o TAF.</font>'
		cRet += '<br/>'
	EndIf
		
	If cInfo == "TITETAPAS"
		cRet += '<font size="4" color="#888">Esta rotina consiste de 2 etapas: </font>'
		cRet += '<br/>'
	EndIf

	If cInfo == "TEXTETAPAS"
		cRet += '<font size="3" color="#888"> 1 - Importação dos arquivos XMLs transmitidos e protocolados para uma '
		cRet += '<br/> tabela <b>intermediária</b>.</font><br/><br/>'
		cRet += '<font size="3" color="#888"> 2 - Envio das informações das tabela <b>intermediária</b> para o <b>TAF</b> .</font><br/><br/>'
	EndIf
EndIf

Return(cRet)