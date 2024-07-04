#INCLUDE "PLSXSDSIN.ch"
#Include "PLSMGER.CH"
#Include "PROTHEUS.CH"
#Include "COLORS.CH"        
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis STATIC                                                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
STATIC bBlockXml	:= &( "{|| ErrorBlock( {|e| PLERRCONT( e:ERRORSTACK ) } ) }" )
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLSXSDSIN  Ё Autor Ё Alexander         Ё Data Ё 03.05.2009 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Programa para definicao de layout XSD com base no sx3      Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

function PLSXSDSIN()
LOCAL nOpca     := 0
LOCAL nI			:= 0
LOCAL nTam		:= 0
LOCAL nTamII		:= 0
LOCAL bOK       := { || nOpca := K_OK, oDlg:End() }
LOCAL bCancel   	:= { || oDlg:End() }
LOCAL lCheck		:= .F.
LOCAL lChBD		:= .F.
LOCAL lChOP		:= .F.
LOCAL cTabela		:= ""      
LOCAL cOldAlt		:= ""            
LOCAL cConteudo	:= Space(20)
LOCAL cDesObs		:= Space(40)
LOCAL oDlg		:= NIL
LOCAL oSx3  		:= NIL 
LOCAL oSx2		:= NIL 
LOCAL oSxB      := NIL
LOCAL oCheck		:= NIL     
LOCAL oChBD		:= NIL     
LOCAL oChOP		:= NIL     
LOCAL oCombo		:= NIL
LOCAL oBotInc		:= NIL
LOCAL oBotDel		:= NIL
LOCAL oBotGRV		:= NIL
LOCAL oSayDir		:= NIL
LOCAL oBotAlt		:= NIL
LOCAL oBotLim		:= NIL
LOCAL oSayAlt		:= NIL
LOCAL oBotSXD		:= NIL
LOCAL oBotXML		:= NIL
LOCAL oBotCSV		:= NIL
LOCAL aSx3Sx2		:= {} 
LOCAL aMvTab		:= {}
LOCAL aSix		:= {}

private cFileTmp 	:= 'TMP'+DtoS(Date())+StrTran(Time(),":","")
private __cArqLog	:= "xsdlog.txt"
private cDir 		:= ""
private cDirAlt  	:= "" 
private cCombo		:= ""
private cComSix		:= ""                                           
private _cChave  	:= Space(160) 	
private cTab 		:= ""
private aSx3			:= {}
private aSx2			:= {}
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Cria diretorio de trabalho												 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !ExistDir(PLSMUDSIS('\xmlsin'))  
	nResult := MakeDir(PLSMUDSIS("\xmlsin")) 
	If nResult != 0
	  MsgAlert( STR0001 ) //"ImpossМvel criar o diretСrio de trabalho no Servidor"
	  Return
	EndIf
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Retorna Conteudo do MV													 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aMvTab := PLTRTMV()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta obj																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Len(aMvTab)>0		                                      
	cCombo := aMvTab[1]
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta IDX																 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	aSix := PLMONSIX()
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta Tabela e Campos													 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	PLMONTSX()
Endif	           
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicia controle															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nTamII := 0
If Len(aSx2)>0
	cTabela := aSx2[1,2]
	nTamII := Len(aSx2[1])
EndIf
nTam := Iif( Len(aSx3)>0 , Len(aSx3[1]) ,0)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Definicao de tela														 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	aSize := MsAdvSize()

	aObjects := {}       
	AAdd( aObjects, { 100, 25, .T., .T. } )
	AAdd( aObjects, { 100, 40, .T., .T. } )
	AAdd( aObjects, { 100, 70, .T., .T. } )
	
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 1, 1 }
	aPosObj := MsObjSize( aInfo, aObjects,.T. )
		
DEFINE MSDIALOG oDlg TITLE STR0002 FROM aPosObj[1,1],aPosObj[1,2]-1 To 750, 1050 of oMainWnd PIXEL //"Layout XSD para SincronizaГЦo de Dados"
	@ aPosObj[1][1] ,aPosObj[1][2]+2 SAY oSay PROMPT STR0003 SIZE aPosObj[1][3],aPosObj[1][4] OF oDlg PIXEL COLOR CLR_HBLUE //"Selecione o Relacionamento"
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Relacionamento															 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	oCombo := TComboBox():New(aPosObj[1][1]+8,aPosObj[1][2]+2,{|u|if(PCount()>0,cCombo:=u,cCombo)},aMvTab,100,20,oDlg,,,,,,.T.)
	oCombo:bChange := {|| MsAguarde( {|| 	cDirAlt:="",;
											oSayAlt:Refresh(),;
											PLMONTSX(oSx2) } ),;
											aSix := PLMONSIX(),;
											oComSix:AITEMS := aSix,;
											oComSix:Refresh(),;
											oBotLim:Disable(),;
											oBotXML:Disable(),;
											oBotCSV:Disable()  }
											
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Marca/Desmarca															 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	@ aPosObj[1][1]+8,aPosObj[1][3]+30 CHECKBOX oCheck VAR lCheck PROMPT STR0004 OF oDlg SIZE 100,8 //"Marca e Desmarca todos os campos"
	oCheck:bChange := {|| MsAguarde( {|| PLMARCTD(aSx3Sx2,lCheck,,oSxB) ,oSx3:Refresh() } ) }
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Bloqueio / Desbloqueio													 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	@ aPosObj[1][1]+15,aPosObj[1][3]+30 CHECKBOX oChBD VAR lChBD PROMPT STR0005 OF oDlg SIZE 150,8 //"A tabela selecionada, implementa Bloqueio e Desbloqueio?"
	oChBD:bChange := {|| aSx2[oSx2:nAt,4] := lChBD }
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Alias Opcional sim ou nao												 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	@ aPosObj[1][1]+8 ,aPosObj[2][3]+110 CHECKBOX oChOP VAR lChOP PROMPT STR0006 OF oDlg SIZE 150,8 //"A tabela selecionada, serА opcional no relacionamento?"
	oChOP:bChange := {|| aSx2[oSx2:nAt,5] := lChOP }

	@ aPosObj[1][1]+28,aPosObj[1][2]+2 SAY oSay PROMPT STR0007+AllTrim(cTabela)+"]" SIZE aPosObj[2][3],aPosObj[1][4] OF oDlg PIXEL COLOR CLR_HBLUE //"Selecione os campos da tabela ["
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Tabelas																	 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	oSx2 := TcBrowse():New( aPosObj[1][1]+38,aPosObj[1][2]+2,aPosObj[1][1]+38,aPosObj[2][1]+50,,,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.)
	oSx2:lHScroll := .F.
	oSx2:lVScroll := .T.
	
	oSx2:AddColumn(TcColumn():New(" ",{ || Iif( aSx2[oSx2:nAt,nTamII],LoadBitmap( GetResources(), "LBOK" ),LoadBitmap( GetResources(), "LBNO" ) ) },;
					"@c",nil,nil,nil,010,.T.,.T.,nil,nil,nil,.T.,nil))
					
	oSx2:AddColumn(TcColumn():New(STR0033,{ || OemToAnsi(aSx2[oSx2:nAt,1]) },; //"Tabelas"
					"@!",nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))

	oSx2:SetArray(aSx2)

	oSx2:bLDblClick := {||	aSx2[oSx2:nAt,nTamII] := Iif( aSx2[oSx2:nAt,nTamII] ,.F.,.T. ) }
	oSx2:bChange    := {||	PLFILTAB(aSx2[oSx2:nAt,1],aSx3Sx2,oSx3),; 
							cTabela := aSx2[oSx2:nAt,2],;
							lCheck  := .F.,;
							lChBD   := aSx2[oSx2:nAt,4],;
							lChOP   := aSx2[oSx2:nAt,5],;
							oCheck:Refresh(),;
							oChBD:Refresh(),;
							oChOP:Refresh(),;
							oSay:Refresh(),;
							oSxB:Reset()}
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Campos																	 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	
	oSx3 := TcBrowse():New( aPosObj[1][1]+38,aPosObj[1][1]+43,aPosObj[2][3],aPosObj[2][1]+50,,,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.)
	
	oSx3:AddColumn(TcColumn():New(" ",{ || If( aSx3Sx2[oSx3:nAt,nTam],LoadBitmap( GetResources(), "LBOK" ),LoadBitmap( GetResources(), "LBNO" ) ) },;
					"@c",nil,nil,nil,010,.T.,.T.,nil,nil,nil,.T.,nil))
	
	oSx3:AddColumn(TcColumn():New(STR0008,{ || OemToAnsi(aSx3Sx2[oSx3:nAt,1]) },; //"Titulo"
					"@!",nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil))
	
	oSx3:AddColumn(TcColumn():New(STR0009,{ || OemToAnsi(aSx3Sx2[oSx3:nAt,2]) },; //"Campo"
					"@!",nil,nil,nil,050,.F.,.F.,nil,nil,nil,.F.,nil))

	oSx3:AddColumn(TcColumn():New(STR0010,{ || OemToAnsi(aSx3Sx2[oSx3:nAt,6]) },; //"Descricao"
					"@!",nil,nil,nil,180,.F.,.F.,nil,nil,nil,.F.,nil))

	oSx3:SetArray(aSx3Sx2)   

	oSx3:bLDblClick := { || oSxB:Reset(),PLMARCTD(aSx3Sx2,lCheck,oSx3:nAt,oSxB) }
	oSx3:bChange    := { || oSxB:Reset(),PLMONRES(oSxB,aSx3Sx2[oSx3:nAt]),cConteudo := Space(aSx3Sx2[oSx3:nAt,4]) }
	oSx3:lHScroll 	:= .F.
	oSx3:lVScroll 	:= .T.
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Restricoes SXB e BOX													 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	@ aPosObj[1][1] + 16,aPosObj[2][3]+110 SAY oSayII PROMPT STR0011 SIZE 150,010 OF oDlg PIXEL COLOR CLR_HBLUE //"RestriГУes (Conteudo e ObservaГЦo)"
	
	@ aPosObj[1][1] + 24,aPosObj[2][3]+110 MSGet oGetCod VAR cConteudo SIZE 42,08 PICTURE "@!" PIXEL OF oDlg PIXEL 
	@ aPosObj[1][1] + 24,aPosObj[2][3]+155 MSGet oGetDes VAR cDesObs SIZE 42,08 PICTURE "@!" PIXEL OF oDlg PIXEL
	
	@ aPosObj[1][1] + 24,aPosObj[2][3]+200 BUTTON oBotInc PROMPT "+" ACTION {|| 	PLIDSXB(0,oSxb,aSx3Sx2[oSx3:nAt],AllTrim(cConteudo)+'-'+AllTrim(cDesObs)),;
													cConteudo := Space(aSx3Sx2[oSx3:nAt,4]),;
													cDesObs := Space(40) } SIZE 10, 10 OF oDlg PIXEL
													
	@ aPosObj[1][1] + 24,aPosObj[2][3]+210 BUTTON oBotDel PROMPT "-" ACTION {|| PLIDSXB(1,oSxb,aSx3Sx2[oSx3:nAt])} SIZE 10, 10 OF oDlg PIXEL
	
	oSxB := TListBox():New(aPosObj[1][1]+38,aPosObj[2][3]+110,,{''},aPosObj[2][1]-20,aPosObj[2][1]+50,,oDlg,,,,.T.)
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Six																		 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	@ aPosObj[2][1]+124,aPosObj[1][2]+2 SAY oSaySix PROMPT STR0012 SIZE 220,010 OF oDlg PIXEL COLOR CLR_HBLUE //"Selecione um indice e infome o conteudo da chave (NЦo informe a Filial)"
	
	oComSix := TComboBox():New(aPosObj[2][1]+134,aPosObj[1][2]+2,{|u|if(PCount()>0,cComSix:=u,cComSix)},aSix,270,20,oDlg,,,,,,.T.)
	oComSix:bChange := {|| _cChave := Space(160)  }
	
	@ aPosObj[2][1]+134,aPosObj[2][3]+120 MSGet oGetSix VAR _cChave SIZE aPosObj[2][1]+20,aPosObj[3][2]+7 PICTURE "@!" PIXEL OF oDlg PIXEL 
	oGetSix:bChange := {|| oGetSix:Refresh()  }

	@ aPosObj[2][1]+134,aPosObj[2][3]+220 BUTTON oBotSix PROMPT STR0013 ACTION {|| PLEXEPES() } SIZE 30, 10 OF oDlg PIXEL //"Validar"
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Pasta de gravacao														 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	@ aPosObj[2][1]+154,aPosObj[1][2]+2 SAY oSaySix PROMPT STR0014 SIZE 160,010 OF oDlg PIXEL COLOR CLR_HBLUE //"GeraГЦo dos arquivos de Layout XSD, XML e CSV de Exemplo"

	@ aPosObj[2][1]+164,aPosObj[1][2]+2 BUTTON oBotSXD PROMPT STR0015 ACTION {|| 	PLSELPAS(0),;//"Gravar Layout"
																PLGERXSD(),;
																iIf(at('XSD',upper(cDir))>0 ,oBotXML:Enable(),oBotXML:Disable()),; 
																iIf(at('XSD',upper(cDir))>0 ,oBotCSV:Enable(),oBotCSV:Disable()),; 
																cDirAlt:='',;
																oBotLim:Disable() } SIZE 50, 10 OF oDlg PIXEL
																
	@ aPosObj[2][1]+164,aPosObj[1][2]+60 BUTTON oBotXML PROMPT STR0016 ACTION {|| PLGERXML() } SIZE 50, 10 OF oDlg PIXEL //"XML de Exemplo"
	oBotXML:Disable()

	@ aPosObj[2][1]+164,aPosObj[1][2]+120 BUTTON oBotCSV PROMPT STR0034 ACTION {|| PLGERCSV() } SIZE 50, 10 OF oDlg PIXEL //"CSV de Exemplo"
	oBotCSV:Disable()

	@ aPosObj[2][1]+176,aPosObj[1][2]+2 MSGet oSayDir VAR Upper(cDir) SIZE aPosObj[3][1]-60,aPosObj[3][2]+7 PIXEL OF oDlg PIXEL
	oSayDir:Disable()          
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Alteracao de arquivo xsd												 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	@ aPosObj[2][1]+190,aPosObj[1][2]+2 SAY oSaySix PROMPT STR0017 SIZE 150,010 OF oDlg PIXEL COLOR CLR_HBLUE //"Selecione um arquivo XSD"
	
	@ aPosObj[2][1]+200,aPosObj[1][2]+2  BUTTON oBotAlt PROMPT STR0018 ACTION {||	PLSELPAS(1),;  //"Selecione"
																cOldAlt := cDirAlt,;
																MsAguarde( {|| PLLERSXD(oCombo,oSx2,oComSix) } ),;
																cDirAlt := cOldAlt,;
																oBotXML:Enable(),;
																oBotCSV:Enable(),;
																oBotLim:Enable(),;
																cDir := subStr(cDirAlt,1,rAt('\',cDirAlt)) } SIZE 50, 10 OF oDlg PIXEL
													
	@ aPosObj[2][1]+200,aPosObj[1][2]+60  BUTTON oBotLim PROMPT STR0019 ACTION {|| 	cDir := '',; //"Limpar"
																	cDirAlt := '',;
																	MsAguarde( {|| PLMONTSX(oSx2) } ),;
																	oBotLim:Disable(),;
																	oBotXML:Disable(),;
																	oBotCSV:Disable() } SIZE 50, 10 OF oDlg PIXEL
	oBotLim:Disable()                        

	@ aPosObj[2][1]+212,aPosObj[1][2]+2 MSGet oSayAlt VAR Upper(cDirAlt) SIZE aPosObj[3][1]-60,aPosObj[3][2]+7 PIXEL OF oDlg PIXEL
	oSayAlt:Disable()
	
ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,{})
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁFim da funcao														   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return                                                   
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLMONSIX   Ё Autor Ё Alexander         Ё Data Ё 03.05.2009 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Monta matriz de idx										  Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/                              
Function PLMONSIX()
LOCAL cTab 		:= SubStr(cCombo,1,3)
LOCAL aRet 		:= {}               
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Montando SIX															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
SIX->( DbSetOrder(01) )
If SIX->( MsSeek(cTab) )
	While !SIX->( Eof() ) .And. SIX->INDICE == cTab
	    AaDd(aRet,AllTrim(SIX->ORDEM)+'-'+AllTrim(SIX->CHAVE) )
	SIX->(DbSkip())    
    EndDo
EndIf            
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁFim da funcao														   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return aRet                                                   
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLEXEPES   Ё Autor Ё Alexander         Ё Data Ё 03.05.2009 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Testa conteudo da chave									  Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLEXEPES()
LOCAL cIdx 	 := SubStr(cComSix,1,At('-',cComSix)-1)
LOCAL cAlias := SubStr(cCombo,1,3)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁValida chave															   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
&(cAlias+'->( DbSetOrder('+cIdx+') )')
If &(cAlias+'->( MsSeek("'+xFilial(cAlias)+AllTrim(_cChave)+'") )')
	If &( cAlias+'->( FieldPos("'+cAlias+'_MOTBLO") )' ) > 0 .And. !Empty( &( cAlias+'->'+cAlias+'_MOTBLO' ) )
		MsgAlert(STR0035)//'Chave encontrada, porem o registro encontra-se Bloqueado'
	ElseIf &( cAlias+'->( FieldPos("'+cAlias+'_CODBLO") )' ) > 0 .And. !Empty( &( cAlias+'->'+cAlias+'_CODBLO' ) )
		MsgAlert(STR0035)//'Chave encontrada, porem o registro encontra-se Bloqueado'
	Else
		MsgAlert(STR0036)//'Chave encontrada'
	EndIf
Else
	MsgAlert(STR0037)//'Chave nЦo encontrada'
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁFim da funcao														   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return                                                   
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLTRTMV    Ё Autor Ё Alexander         Ё Data Ё 03.05.2009 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Pega conteudo do parametro e monta matriz				  Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLTRTMV()
LOCAL cTab := GetNewPar("MV_SINTAB","BQC-BA3>BA1>BF4,BG9-BA3>BA1>BF4,BA3-BA1>BF4")
LOCAL nPos := 0             
LOCAL cRel := "" 
LOCAL aRet := {}

if empty(cTab)
	cTab := "BQC-BA3>BA1>BF4,BG9-BA3>BA1>BF4,BA3-BA1>BF4"
endIf
cTab += ','
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta Order de Relacionamento conforme MV								 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
While ( nPos := At(',',cTab) ) > 0
	cRel := SubStr(cTab,1,nPos-1)
	cTab := SubStr(cTab,nPos+1,Len(cTab))  
	AaDd(aRet,cRel)
EndDo  
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁFim da funcao														   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return aRet   
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLMONTSX   Ё Autor Ё Alexander         Ё Data Ё 03.05.2009 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Monta sx2 e sx3											  		 Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLMONTSX(oSx2,cRelac) 
LOCAL nPos	 	:= 0             
LOCAL nI	 		:= 0 
LOCAL cRaiz	 	:= ''
LOCAL cTab	 	:= ''
LOCAL cTabC	 	:= ""
LOCAL cSx2	 	:= ""         
LOCAL cNoCampos	:= '_FILIAL, _CODBLO, _MOTBLO, _DATBLO, _DIGITO, _MATVID, _TIPREG, _FORCOP, _IMAGE'
LOCAL aSx3Raiz	:= {}
DEFAULT oSx2 	:= NIL        
default cRelac 	:= ''

if !empty(cRelac)
	cCombo := cRelac
endIf  
cRaiz 	:= subStr(cCombo,1,3)
cTab	:= subStr(cCombo,5,Len(cCombo))
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Tratamento de erro														 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Begin Sequence   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta Order de Relacionamento conforme MV								 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
SX2->( DbSetOrder(01) )
SX2->( DbGoTop() )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Montando Sx2															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aSx2 := {}
cTab += '>'
While ( nPos := At('>',cTab) ) > 0
	cSx2 := SubStr(cTab,1,nPos-1)
	cTab := SubStr(cTab,nPos+1,Len(cTab))  
	If SX2->( MsSeek(cSx2) )
	    AaDd(aSx2,{ OemtoAnsi(cSx2),OemtoAnsi(X2Nome()),++nI,.F.,.F.,.F. } )
	EndIf
EndDo
aSx2 := aSort( aSx2,,, { |x, y| x[3] < y[3] } )           
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica campos do alias raiz											 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
SX3->( DbSetOrder(1) )
If SX3->( MsSeek(cRaiz) )
	PLSMONSX3( cRaiz,aSx3Raiz,,@cNoCampos )
EndIf	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta lista de campos													 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aSx3 := {}
For nI:=1 To Len(aSx2)
	If !(aSx2[nI,1] $ cTabC) .And. SX3->( MsSeek(aSx2[nI,1]) )
		cTabC += aSx2[nI,1] 
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Monta Sx3 com base no alias												 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		PLSMONSX3( aSx2[nI,1],aSx3,aSx3Raiz,@cNoCampos )
	EndIf
Next
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁAtualiza objetos														   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If oSx2<>NIL    
	oSx2:SetArray(aSx2)
	oSx2:GoTop()
	oSx2:Refresh()
EndIf	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Tratamento de erro														 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
End Sequence
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё ErroBlock																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
ErrorBlock( bBlockXml  )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁFim da funcao														   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return                                                                           
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLSMONSX3  Ё Autor Ё Alexander         Ё Data Ё 03.05.2009 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Lendo xsd para alteracao									    Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
function PLSMONSX3(cAlias,aSx3,aSx3Raiz,cNoCampos)
local lObri			:= .f.           
local cCpoRaiz		:= getNewPar("MV_PLSCPOS","_COBNIV") 	// Aparece alguns campos semelhantes no XSD. Exemplo conteudo '_COBNIV, _XXXXX, '
local lCpoTodos		:= getNewPar("MV_PLTCPOS",.f.) 			// Aparece todos os campos semelhantes no XSD
local lCpoTd			:= .t.  
local lNoFoudRaiz	:= .t.
       
default aSx3Raiz	:= {}
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Tratamento de erro														 
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
begin Sequence   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё While no sx3 com base em um alias									   
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
while !SX3->(eof()) .and. allTrim(SX3->X3_ARQUIVO) == allTrim(cAlias)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica se deve ou nao trazer todos os campos semelhantes AliasRaiz com Alias Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	if !lCpoTodos
		lNoFoudRaiz	:= aScan(aSx3Raiz,{|x| subStr(x[2],4) == subStr(upper(SX3->X3_CAMPO),4)})==0
		lCpoTd 		:= subStr(upper(SX3->X3_CAMPO),4) $ cCpoRaiz
	endIf
	
	if upper(SX3->X3_CONTEXT) <> 'V' .and. !empty(X3TITULO()) .and. !(upper(subStr(SX3->X3_CAMPO,4)) $ cNoCampos) .and.;
		 ((lNoFoudRaiz .and. aScan(aSx3,{|x| subStr(x[2],4) == subStr(upper(SX3->X3_CAMPO),4)}) == 0) .or. lCpoTd)
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Verifica o conteudo do relacao										   
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		If AllTrim(SX3->X3_RELACAO) == '"AUTO"'
			cNoCampos += Upper( SubStr(SX3->X3_CAMPO,4) )+', '
			Loop		
		EndIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica se e obrigatorio											   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		lObri := X3Obrigat(SX3->X3_CAMPO) //25-06
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Estrutura de Campos													   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		AaDd(aSx3, { OemtoAnsi(X3TITULO()),;//1
					SX3->X3_CAMPO,;//2
					SX3->X3_TIPO,;//3
					SX3->X3_TAMANHO,;//4
					SX3->X3_DECIMAL,;//5
					OemtoAnsi(AllTrim(SX3->X3_DESCRIC))+IiF(lObri,STR0038,''),;//6 ' - Campo Obrigatorio'
					SX3->X3_ARQUIVO,;//7
					SX3->X3_CBOX,;//8
					Iif(!Empty(SX3->X3_CBOX),PLRETBOX(SX3->X3_CAMPO,SX3->X3_CBOX),{}),;//9
					SX3->X3_F3,;//10
					lObri,;//11
					lObri} )//12
	EndIf
	SX3->( DbSkip() )
EndDo 
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Tratamento de erro														 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
End Sequence
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё ErroBlock																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
ErrorBlock( bBlockXml  )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁFim da funcao														   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return                                                                           
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLLERSXD   Ё Autor Ё Alexander         Ё Data Ё 03.05.2009 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Lendo xsd para alteracao									  Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLLERSXD(oCombo,oSx2,oComSix,lCSV,cDirXSD)
LOCAL nI,nX		:= 0   
LOCAL nPosII		:= 0
LOCAL nPos		:= 0	
LOCAL cErro 		:= ""
LOCAL cAviso		:= ""
LOCAL cRelac		:= ""
LOCAL cResAux		:= ""
LOCAL cRestri		:= ""
LOCAL cArq 		:= ''
LOCAL aMatX		:= {}
LOCAL aMatAux		:= {}
LOCAL oXsd		:= NIL 
LOCAL oObjAux		:= NIL 
default oSx2		:= NIL
default lCSV		:= .f.
default cDirXSD	:= ''

if !empty(cDirXSD)
	cDirAlt := cDirXSD
endIf

cArq := PLSMUDSIS("\xmlsin\"+subStr(cDirAlt,Rat('\',cDirAlt)+1,Len(cDirAlt)))
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁCopia para o diretorio de trabalho no servidor						   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Empty(cDirAlt)
	Return
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁCopia para o diretorio de trabalho no servidor						   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !__copyfile( cDirAlt,PLSMUDSIS("\xmlsin")+substr(cDirAlt,RAt("\",cDirAlt)))
	MsgAlert(STR0020)  //"NЦo foi possМvel copiar o arquivo para Аrea de trabalho no Servidor"
	Return
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Tratamento de erro														 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Begin Sequence   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁParse do arquivo														   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
oXsd := XmlParserFile(cArq,"_",@cErro,@cAviso)     
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁDeleta arquivo da area de trabalho no servidor						   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If FErase(cArq) == -1
	FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0021 , 0, 0, {}) //"NЦo foi possМvel deletar o arquivo da Аrea de trabalho no Servidor"
EndIf 
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁVerificacao de possivel erro											   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ( Empty(cErro) .And. Empty(cAviso) .And. oXsd <> Nil)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁAtualiza conforme Layout												   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If XmlNodeExist( oXsd:_SCHEMA:_ELEMENT:_COMPLEXTYPE:_SEQUENCE:_ELEMENT[1]:_COMPLEXTYPE:_SEQUENCE,"_ELEMENT" )
		cRelac := oXsd:_SCHEMA:_ELEMENT:_COMPLEXTYPE:_SEQUENCE:_ELEMENT[1]:_COMPLEXTYPE:_SEQUENCE:_ELEMENT[2]:_FIXED:TEXT
		
		if lCSV
			if 	len(aSx3)==0 .and. len(aSx2)==0
				PLMONTSX(nil,strTran(cRelac,',','>'))
			endIf	
		else
			If ( nPos := aScan( oCombo:AITEMS,{|x|Upper(x)==StrTran(cRelac,',','>')} ) ) > 0		
				oCombo:Select(nPos)
			Else
				MsgAlert(STR0039+cCombo+STR0040)//'Relacionamento [''] nЦo encontrado, verifique o conteЗdo do parБmetro MV_SINTAB'
				Return
			EndIf
		endIf	
	Else
		MsgAlert(STR0041)//'Problema na estrutura do arquivo, gere o arquivo novamente!'
		Return
	EndIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁChave e idx															   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If XmlNodeExist( oXsd:_SCHEMA:_ELEMENT:_COMPLEXTYPE:_SEQUENCE:_ELEMENT[1]:_COMPLEXTYPE:_SEQUENCE:_ELEMENT[5]:_COMPLEXTYPE:_SEQUENCE,"_ELEMENT" )
	
		cIdx	 := oXsd:_SCHEMA:_ELEMENT:_COMPLEXTYPE:_SEQUENCE:_ELEMENT[1]:_COMPLEXTYPE:_SEQUENCE:_ELEMENT[5]:_COMPLEXTYPE:_SEQUENCE:_ELEMENT[2]:_FIXED:TEXT
		_cChave := oXsd:_SCHEMA:_ELEMENT:_COMPLEXTYPE:_SEQUENCE:_ELEMENT[1]:_COMPLEXTYPE:_SEQUENCE:_ELEMENT[5]:_COMPLEXTYPE:_SEQUENCE:_ELEMENT[3]:_FIXED:TEXT
		_cChave := _cChave+Space(160-Len(_cChave))
		
		if !lCSV
			If ( nPos := aScan( oComSix:AITEMS,{|x| At(cIdx+'-',x) } ) ) > 0		
				oComSix:Select(nPos)
			Else
				MsgAlert(STR0042+cIdx+STR0043)//'Indice [''] nЦo encontrado, verifique o conteЗdo do parБmetro MV_SINTAB'
				Return
			EndIf
		endIf
	endIf	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁCarrega OBJ para matriz												   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	oObjAux := oXsd:_SCHEMA:_ELEMENT:_COMPLEXTYPE:_SEQUENCE:_ELEMENT
	aMatX	 := PLEXTLAY(oObjAux)
Else                                          
	MsgAlert(STR0044+cErro+Iif(!Empty(cAviso),'-'+cAviso,'')+']')//'Problema encontrado no XSD ['
	cDirAlt:=''
EndIf  
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁAtualizando matriz sx2,sx3 e sxb										   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For nI:=1 To Len(aMatX)     
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁSx2																	   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If ( nPos := aScan( aSx2,{|x|AllTrim(Upper(x[1]))==AllTrim(SubStr(aMatX[nI,1],1,3)) } ) ) > 0
		aSx2[nPos,Len(aSx2[nPos])] := .T.
		aSx2[nPos,4]	:= aMatX[nI,7]
		aSx2[nPos,5]	:= aMatX[nI,8]
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁSx3																	   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If ( nPos := aScan( aSx3,{|x| AllTrim( Upper( x[2] ) ) == AllTrim( Upper( aMatX[nI,3] ) ) } ) ) > 0
			aSx3[nPos,Len(aSx3[nPos])] := .T.
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁAjustando informacao do box											   Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			cRestri := aMatX[nI,2]   
			cRestri := SubStr(cRestri, At('[Ex:', cRestri)+4)
			cRestri := StrTran(AllTrim(Left(cRestri, At(']', cRestri)-1)),',',';')
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁSxb																	   Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			aSx3[nPos,8] 	:= ""
			aSx3[nPos,9] 	:= {}
			                      
			If !Empty(cRestri)
				aSx3[nPos,8] := cRestri
				cRestri += ';'
				While ( nPosII := At(';',cRestri) ) > 0
					cResAux	:= SubStr(cRestri,1,nPosII-1)
					cRestri	:= SubStr(cRestri,nPosII+1,Len(cRestri))
					AaDd( aSx3[nPos,9], cResAux )
				EndDo	
			EndIf
		EndIf
	EndIf	
Next                                                                                   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁAtualiza obj															   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If oSx2 <> NIL     
    Eval(oSx2:bChange)
	oSx2:Refresh()
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Tratamento de erro														 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
End Sequence
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё ErroBlock																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
ErrorBlock( bBlockXml  )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁFim da funcao														   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return({cRelac,cIdx})                    
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLEXTLAY   Ё Autor Ё Alexander         Ё Data Ё 03.05.2009 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Gera campos do xsd										  		 Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLEXTLAY(oObj)   
LOCAL nI,nY,nX	:= 0
LOCAL nTam,nTamX	:= 0                      
LOCAL cCp,cCpX	:= ''     
LOCAL cAlias	 	:= ''
LOCAL cTitulo	 	:= ''
LOCAL cCampo	 	:= ''
LOCAL cTipo		:= ''
LOCAL oObjAux	 	:= NIL
LOCAL oObjAu2	 	:= NIL
LOCAL oObjX	 	:= NIL
LOCAL lObj		:= .T.
LOCAL lObjX		:= .T.
LOCAL lBloDes 	:= .F.
LOCAL lRelOpc 	:= .F.
LOCAL lReg	 	:= .F.
LOCAL aRegistros	:= {}
LOCAL aCampos 	:= {}
LOCAL aMatAux 	:= {}
LOCAL aMatLay 	:= {}
LOCAL aRestri	 	:= {}
LOCAL aFormato  	:= {}
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Tratamento de erro														 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Begin Sequence   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posicionando no corpo													 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
oObjAux := oObj[2]:_COMPLEXTYPE:_SEQUENCE:_ELEMENT
cAlias	 := oObjAux:_NAME:TEXT           
lRelOpc := XmlNodeExist( oObjAux , "_MINOCCURS" ) 
oObjAux := oObjAux:_COMPLEXTYPE:_SEQUENCE:_ELEMENT
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Entidade Raiz montando os registros										 
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
While (ValType(oObjAux)=='A') .And. !lReg
	lObj := ValType(oObjAux)=='O'
	nTam := Iif(lObj,1,Len(oObjAux))
	For nI:=1 To nTam    
		cCp := Iif( lObj,'','['+AllTrim(Str(nI))+']' )
		
		If XmlNodeExist( Eval( &( '{|| oObjAux'+cCp+' }' ) ) ,"_COMPLEXTYPE" )
		
			If Upper(Eval( &( '{|| oObjAux'+cCp+':_NAME:TEXT }' ) )) == 'REGISTRO'
				AaDd(aRegistros ,{cAlias , Eval( &( '{|| oObjAux'+cCp+':_COMPLEXTYPE:_SEQUENCE:_ELEMENT }' ) ), lRelOpc } )
				lRelOpc := .F.
				lReg	:= .T.
			Else
				cAlias	:= Eval( &( '{|| oObjAux'+cCp+':_NAME:TEXT}' ) )       
				lRelOpc	:= XmlNodeExist( Eval( &( '{|| oObjAux'+cCp+' }' ) ) ,"_MINOCCURS" ) 
				oObjAux := Eval( &( '{|| oObjAux'+cCp+':_COMPLEXTYPE:_SEQUENCE:_ELEMENT}' ) )
				lReg	:= .F.
			EndIf	
		EndIf	                
	Next
EndDo
	         
If ValType(oObjAux)=='O' .And. XmlNodeExist( oObjAux ,"_COMPLEXTYPE" ) .And. XmlNodeExist( oObjAux:_COMPLEXTYPE ,"_SEQUENCE" ) .And. XmlNodeExist( oObjAux:_COMPLEXTYPE:_SEQUENCE ,"_ELEMENT" )
	AaDd(aRegistros ,{cAlias , oObjAux:_COMPLEXTYPE:_SEQUENCE:_ELEMENT ,lRelOpc } )
EndIf	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Campos																	 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For nI:=1 To Len(aRegistros)  
	lBloDes := .F.
	For nY:=1 To Len(aRegistros[nI,2])
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica se tem opcao de campos											 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If XmlNodeExist( aRegistros[nI,2,nY],"_COMPLEXTYPE" ) .And. XmlNodeExist( aRegistros[nI,2,nY]:_COMPLEXTYPE:_SEQUENCE,"_ELEMENT" ) .And. Upper(aRegistros[nI,2,nY]:_NAME:TEXT) == 'CAMPOS'
			aMatAux:= aRegistros[nI,2,nY]:_COMPLEXTYPE:_SEQUENCE:_ELEMENT
		EndIf	
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica se tem opcao de bloqueio										 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If XmlNodeExist( aRegistros[nI,2,nY],"_COMPLEXTYPE" ) .And. XmlNodeExist( aRegistros[nI,2,nY]:_COMPLEXTYPE:_SEQUENCE,"_ELEMENT" ) .And. Upper(aRegistros[nI,2,nY]:_NAME:TEXT) == 'BLOQUEIODESBLOQUEIO'
			lBloDes := .T.
		EndIf
	Next	
	AaDd(aCampos,{ aRegistros[nI,1], aMatAux, lBloDes, aRegistros[nI,3] } )
Next             
aRegistros:={}
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alimenta a matriz com os campos do obj									 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For nY:=1 To Len(aCampos)       
	cAlias 	:= aCampos[nY,1]                   
	oObjAu2	:= aCampos[nY,2]
	lBloDes 	:= aCampos[nY,3]
	lRelOpc 	:= aCampos[nY,4]
	lObjX 		:= ValType(oObjAu2)=='O'
	nTamX 		:= Iif( lObjX,1,Len(oObjAu2) )
	
	For nX:=1 To nTamX    
		cCpX  := Iif( lObjX,'','['+AllTrim(Str(nX))+']' )
		oObjX := Eval( &( '{|| oObjAu2'+cCpX+' }' ) )
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Pegando dados do obj													 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		cTitulo	:= oObjX:_ANNOTATION:_DOCUMENTATION:TEXT
	   	cCampo	:= oObjX:_NAME:TEXT
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verificando SimpleType													 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	    If XmlNodeExist( oObjX,"_SIMPLETYPE" ) .And. XmlNodeExist( oObjX:_SIMPLETYPE,"_RESTRICTION")
	    	cTipo := oObjX:_SIMPLETYPE:_RESTRICTION:_BASE:TEXT
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Enumeration																 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			aRestri := {}
			If XmlNodeExist( oObjX:_SIMPLETYPE:_RESTRICTION,"_ENUMERATION")
				oObjAux := oObjX:_SIMPLETYPE:_RESTRICTION:_ENUMERATION
				lObj 	:= ValType(oObjAux)=='O'
				nTam 	:= Iif(lObj,1,Len(oObjAux))
				For nI:=1 To nTam
					cCp := Iif( lObj,'','['+AllTrim(Str(nI))+']' )
					AaDd(aRestri , Eval( &( '{|| oObjAux'+cCp+':_VALUE:TEXT }' ) ) )
				Next
			EndIf	
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Formato																	 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			aFormato := {}
			If XmlNodeExist( oObjX:_SIMPLETYPE:_RESTRICTION,"_PATTERN")
				oObjAux := oObjX:_SIMPLETYPE:_RESTRICTION:_PATTERN
				lObj 	:= ValType(oObjAux)=='O'
				nTam 	:= Iif(lObj,1,Len(oObjAux))
				For nI:=1 To nTam
					cCp := Iif( lObj,'','['+AllTrim(Str(nI))+']' )
					AaDd(aFormato , Eval( &( '{|| oObjAux'+cCp+':_VALUE:TEXT }' ) ) ) 
				Next
			EndIf	
	    EndIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Tabela,Campos e Restricoes												 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		AaDd( aMatLay,{cAlias,cTitulo,cCampo,cTipo,aRestri,aFormato,lBloDes,lRelOpc} )
	Next	
Next	                     
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Tratamento de erro														 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
End Sequence
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё ErroBlock																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
ErrorBlock( bBlockXml  )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return(aMatLay)
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLIDSXB    Ё Autor Ё Alexander         Ё Data Ё 03.05.2009 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Inclui e Deleta restricoes								  Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLIDSXB(nTp,oSxB,aSx3Cmp,cDescri)
LOCAL nI 	:= 0
LOCAL nPos 	:= 0
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁAjusta restricoes													   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nTp==0
	AaDd(aSx3Cmp[9],cDescri)
Else
	nPos := oSxB:GetPos()
	oSxB:Del(nPos) 
	aSx3Cmp[9] := {}	
	For nI:=1 To oSxB:Len()           
		oSxB:Select(nI)
		If !Empty(oSxB:GetSelText())
			AaDd(aSx3Cmp[9],oSxB:GetSelText())
		EndIf	
	Next
EndIf	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Atualiza matriz full												   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ( nPos := aScan( aSx3,{|x|Upper(x[2])==aSx3Cmp[2]} ) ) > 0
	aSx3[nPos,9] := aClone(aSx3Cmp[9])
EndIf	 
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁAtualiza obj															   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
oSxB:Reset()
oSxB:SetArray( aClone( aSx3Cmp[9] ) )
oSxB:Refresh()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁFim da funcao														   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLMONRES   Ё Autor Ё Alexander         Ё Data Ё 03.05.2009 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Monta estrutura de restricao								  Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLMONRES(oSxB,aSx3Cmp,lAtu)
LOCAL nI	 := 0                                          
LOCAL nPos	 := 0
LOCAL aRet 	 := {}             
DEFAULT lAtu :=.T.
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Box do Campo														   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Len(aSx3Cmp[9])==0 .And. !Empty(aSx3Cmp[8])
	aSx3Cmp[9] := PLRETBOX(aSx3Cmp[2],aSx3Cmp[8])
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Atualiza matriz full												   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If ( nPos := aScan( aSx3,{|x|Upper(x[2])==aSx3Cmp[2]} ) ) > 0
		aSx3[nPos,9] := aClone(aSx3Cmp[9])
	EndIf	
ElseIf Len(aSx3Cmp[9])>0
	If ( nPos := aScan( aSx3,{|x|Upper(x[2])==aSx3Cmp[2]} ) ) > 0
		aSx3[nPos,9] := aClone(aSx3Cmp[9])
	EndIf	
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁAtualiza obj															   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lAtu
	oSxB:Reset()
	oSxB:SetArray( aClone( aSx3Cmp[9] ) )
	oSxB:Refresh()
EndIf	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁFim da funcao														   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return                                    
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLRETBOX   Ё Autor Ё Alexander         Ё Data Ё 03.05.2009 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Retorna o conteudo do x3_box e implementacoes			  Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLRETBOX(cCampo,cBox)  
LOCAL aRetAux:= {}
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Conteudo original do x3_box											   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If At(';',cBox) > 0  
	cBox+=';'     
	While At(';',cBox) > 0
		cBoxAux := StrTran(Left(cBox,At(';',cBox)-1),'=','-')
		cBox	:= SubStr(cBox,At(';',cBox)+1 )
		
		AaDd( aRetAux,Upper(cBoxAux) )
	EndDo
Else 
 AaDd( aRetAux, StrTran(cBox,'=','-') )
EndIf	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁFim da funcao														   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return aClone(aRetAux)
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLMARCTD   Ё Autor Ё Alexander         Ё Data Ё 03.05.2009 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Marca campos selecionados								  Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLMARCTD(aSx3Sx2,lCheck,nAt,oSxB)  
LOCAL nI 	:= 0 
LOCAL nPos	:= 0              
LOCAL nTam	:= Iif( Len(aSx3Sx2)>0 , Len(aSx3Sx2[1]) ,0)
DEFAULT nAt := 0
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Marca uma ou todas as linhas												 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nAt!=0
	If !aSx3Sx2[nAt,11]
		aSx3Sx2[nAt,nTam] := If(aSx3Sx2[nAt,nTam],.F.,.T.)
	EndIf	
	If ( nPos := aScan( aSx3,{|x|Upper(x[2])==aSx3Sx2[nAt,2]} ) ) > 0
		If !aSx3[nPos,11]
			aSx3[nPos,nTam] := aSx3Sx2[nAt,nTam]			
		EndIf	
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Atualiza restricoes															 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If !Empty(aSx3[nPos,8]) .Or. Len(aSx3[nPos,9])>0
			PLMONRES( oSxB,aSx3[nPos] )	
		EndIf	
	EndIf
Else	
	For nI := 1 To Len(aSx3Sx2) 
	    If aSx3Sx2[nI,nTam] != lCheck
			If !aSx3Sx2[nI,11]
				aSx3Sx2[nI,nTam] := lCheck
			EndIf	
			If ( nPos := aScan( aSx3,{|x|Upper(x[2])==aSx3Sx2[nI,2]} ) ) > 0
				If !aSx3[nPos,11]
					aSx3[nPos,nTam] := aSx3Sx2[nI,nTam]			
				EndIf	
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Atualiza restricoes															 Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If !Empty(aSx3[nPos,8]) .Or. Len(aSx3[nPos,9])>0
					PLMONRES( oSxB,aSx3[nPos],.F. )	
				EndIf	
			EndIf
		EndIf	
	Next
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁFim da funcao														   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return  
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLFILTAB   Ё Autor Ё Alexander         Ё Data Ё 03.05.2009 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Monta filtro da tabela									  Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLFILTAB(cSx2,aSx3Sx2,oSx3)  
LOCAL nI	  	:= 0
LOCAL cTabela	:= AllTrim(SubStr(cSx2,1,4))
DEFAULT oSx3 := NIL
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁMonta a nova matriz com base no filtro								   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aSx3Sx2 := {}                           
For nI:=1 To Len(aSx3)
	If aSx3[nI,7] == cTabela    
		    AaDd(aSx3Sx2, { aSx3[nI,1],;
		     			 	aSx3[nI,2],;
		     			 	aSx3[nI,3],;
		     			 	aSx3[nI,4],;
		     			 	aSx3[nI,5],;
		     			 	aSx3[nI,6],;
		     			 	aSx3[nI,7],;
		     			 	aSx3[nI,8],;
		     			 	aSx3[nI,9],;
		     			 	aSx3[nI,10],;
		     			 	aSx3[nI,11],;
		     			 	aSx3[nI,12]} )
	EndIf
Next
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁAtualiza o Obj														   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If oSx3 <> NIL 
	oSx3:SetArray(aSx3Sx2)   
	oSx3:GoTop()
	oSx3:Refresh()        
EndIf	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁFim da funcao														   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return                                            
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLSELPAS   Ё Autor Ё Alexander         Ё Data Ё 03.05.2009 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Retorna o diretorio para gravacao do XSD					  Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSELPAS(nTp)
If nTp == 0
	cDir    := cGetFile("*.*",STR0022,0,"c:\",.T.,GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE + GETF_RETDIRECTORY)   //"Selecione o diretСrio"
Else 
	cDirAlt := cGetFile("*.XSD|*.xsd",STR0023,1 ,"c:\",.T.,GETF_LOCALHARD + GETF_NETWORKDRIVE)   //"Selecione o Arquivo"
EndIf	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁFim da funcao														   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLGERXSD   Ё Autor Ё Alexander         Ё Data Ё 03.05.2009 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Retorna o diretorio para gravacao do XSD					  Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLGERXSD()
LOCAL nI		:= 0 
LOCAL nTam	:= Iif( Len(aSx3)>0 , Len(aSx3[1]) ,0)
LOCAL nTamII	:= Iif( Len(aSx2)>0 , Len(aSx2[1]) ,0)
LOCAL lFindC	:= .F.
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁVerifica se a pasta de gravacao foi informada						   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Empty(cDir)
	MsgAlert(STR0045)//'Informe a pasta para gravaГЦo'
	Return
EndIf            
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁVerifica se a pasta de gravacao foi informada						   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Empty(_cChave)
	MsgAlert(STR0046)//'Informe chave de pesquisa para tabela raiz'
	Return
EndIf            
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Nome do Arquivo															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cTab := ""
For nI:=1 To Len(aSx2)
	If aSx2[nI,nTamII]
		cTab += "-"+aSx2[nI,1]
	EndIf	
Next                    
If !Empty(cTab)
	cTab := 'sincronizador'+AllTrim( cTab )+'-'+DtoS( Date() )+".xsd"
Else 
	MsgAlert(STR0024) //"Nenhuma tabela foi selecionada!"
	Return
EndIf	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se o arquivo XSD existe										 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If File(cDir+cTab)       
	If MsgYesNo(STR0025) //"Existe um arquivo XSD, com o mesmo nome gerado nesta pasta. Deseja deletar o arquivo?"
		If FErase(cDir+cTab) == -1
			PlsLogFil(STR0026+cDir+cTab+"]",__cArqLog) //"NЦo foi possМvel deletar arquivo ["
		EndIf 
	Else
		Return
	EndIf	
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁPegar os campos que foram selecionados								   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For nI := 1 To Len(aSx3)
	If aSx3[nI,nTam]
		lFindC := .T.
		Exit
	EndIf	
Next         
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁVerifica se tem campo mancado										   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lFindC
	MsgAlert(STR0047)//'Informe os campos para composiГЦo do layout'
	Return
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁMonta Estrutura XSD													   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If PLSINXSD()  
	cDir += cTab
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁFim da funcao														   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLSINXSD   Ё Autor Ё Alexander         Ё Data Ё 03.05.2009 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Sincronizador do XSD										  Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSINXSD()  
LOCAL cSincr := ""
LOCAL lRet	 := .F.
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁEstrutura raiz														   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cSincr += '<?xml version="1.0" encoding="ISO-8859-1"?>'
cSincr += '<!--XSD layout - NameSpace ts (Totvs Saude)-->'
cSincr += ' <schema xmlns="http://www.w3.org/2001/XMLSchema" xmlns:ts="http://localhost" targetNamespace="http://localhost" elementFormDefault="qualified"> '
cSincr += ' <element name="sincronizador"> '
	cSincr += ' <annotation> '
		cSincr += ' <documentation>Estrutura genИrica para exportaГЦo e importaГЦo de dados referente ao relacionamento ['+StrTran(cCombo,'>',',')+']</documentation> '
	cSincr += ' </annotation> '
	cSincr += ' <complexType> '
	cSincr += ' <sequence> '
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁGravacao Arquivo Tmp													   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	PLGRVARQ(cSincr)	
	cSincr := ''
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁEstrutura Cabecalho													   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	PLCABXSD()
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁEstrutura Corpo														   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If !PLCORXSD()
		Return .F.	
	EndIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁEstrutura Rodape														   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	PLRODXSD()
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁFecha a estrutura geral												   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cSincr += ' </sequence> '
	cSincr += ' </complexType> '
cSincr += ' </element> '
cSincr += ' </schema> '                                                 
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁGravacao Arquivo Tmp													   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
lRet := PLGRVARQ(cSincr,'XSD')
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁFim da funcao														   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return lRet
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLCABXSD   Ё Autor Ё Alexander         Ё Data Ё 03.05.2009 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Cabecalho do XSD											  Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLCABXSD()
LOCAL cCabecalho := ""
                 
cCabecalho += ' <element name="cabecalho"> '
cCabecalho += ' <annotation> '
	cCabecalho += ' <documentation>InformaГУes sobre o responГavel pelo arquivo</documentation> '
cCabecalho += ' </annotation> '
cCabecalho += ' <complexType> '
cCabecalho += ' <sequence> '

	cCabecalho += ' <element name="titulo"> '
	cCabecalho += ' <annotation> '
		cCabecalho += ' <documentation>Titulo referente a movimentaГЦo dos dados.</documentation> '
	cCabecalho += ' </annotation> '
	cCabecalho += ' <simpleType> '
	cCabecalho += ' <restriction base="string"> '
	cCabecalho += ' <maxLength value="120"/> '
	cCabecalho += ' </restriction> '
	cCabecalho += ' </simpleType> '
	cCabecalho += ' </element> '
	
	cCabecalho += ' <element name="relacionamento" fixed="'+StrTran(cCombo,'>',',')+'"> '
	cCabecalho += ' <annotation> '
		cCabecalho += ' <documentation>Layout referente ao relacionamento das tabelas</documentation> '
	cCabecalho += ' </annotation> '
	cCabecalho += ' </element> '
	
	cCabecalho += ' <element name="data"> '
	cCabecalho += ' <annotation> '
		cCabecalho += ' <documentation>Data de geraГЦo do arquivo. AAAAMMDD</documentation> '
	cCabecalho += ' </annotation> '
	cCabecalho += ' <simpleType> '
	cCabecalho += ' <restriction base="string"> '
	cCabecalho += ' <pattern value="[0-9]{4}[0-9]{2}[0-9]{2}"/> '
	cCabecalho += ' </restriction> '
	cCabecalho += ' </simpleType> '
	cCabecalho += ' </element> '
	
	cCabecalho += ' <element name="responsavelLayout" fixed="'+AllTrim(PLRETOPE())+'"> '
	cCabecalho += ' <annotation> '
		cCabecalho += ' <documentation>Operadora responsАvel pelo layout do sincronizador.</documentation> '
	cCabecalho += ' </annotation> '
	cCabecalho += ' </element> '
	
	cCabecalho += ' <element name="entidadeRaiz"> '
	cCabecalho += ' <annotation> '
		cCabecalho += ' <documentation>InformaГЦo sobre a entidade Raiz da movimentaГЦo. (Entidade Pai)</documentation> '
	cCabecalho += ' </annotation> '
	cCabecalho += ' <complexType> '
	cCabecalho += ' <sequence> '
		
		cCabecalho += ' <element name="alias" fixed="'+SubStr(cCombo,1,3)+'"> '
		cCabecalho += ' <annotation> '
			cCabecalho += ' <documentation>Alias da entidade base para processamento</documentation> '
		cCabecalho += ' </annotation> '
		cCabecalho += ' </element> '
		
		cCabecalho += ' <element name="idxChave" fixed="'+SubStr(cComSix,1,At('-',cComSix)-1)+'"> '
		cCabecalho += ' <annotation> '
			cCabecalho += ' <documentation>Indice da chave de pesquisa</documentation> '
		cCabecalho += ' </annotation> '
		cCabecalho += ' </element> '
		
		cCabecalho += ' <element name="conteudo" fixed="'+AllTrim(_cChave)+'"> '
		cCabecalho += ' <annotation> '
			cCabecalho += ' <documentation>Conteudo a ser pesquisado na base de dados</documentation> '
		cCabecalho += ' </annotation> '
		cCabecalho += ' </element> '
		
	cCabecalho += ' </sequence> '
	cCabecalho += ' </complexType> '
	cCabecalho += ' </element> '
	
	cCabecalho += ' <element name="origem"> '
	cCabecalho += ' <annotation> '
		cCabecalho += ' <documentation>Enviando a movimentaГЦo</documentation> '
	cCabecalho += ' </annotation> '
	cCabecalho += ' <complexType> '
	cCabecalho += ' <sequence> '
	
		cCabecalho += ' <element name="codigo"> '
		cCabecalho += ' <annotation> '
			cCabecalho += ' <documentation>Codigo de identificaГЦo no sistema que ira receber o arquivo. Ao enviar o XSD-Lauout, tambem deve ser  informado este codigo</documentation> '
		cCabecalho += ' </annotation> '
		cCabecalho += ' <simpleType> '
		cCabecalho += ' <restriction base="string"> '
		cCabecalho += ' <maxLength value="15"/> '
		cCabecalho += ' </restriction> '
		cCabecalho += ' </simpleType> '
		cCabecalho += ' </element> '
		
		cCabecalho += ' <element name="descricao"> '
		cCabecalho += ' <annotation> '
			cCabecalho += ' <documentation>InstituiГЦo que esta enviando o arquivo</documentation> '
		cCabecalho += ' </annotation> '
		cCabecalho += ' <simpleType> '
		cCabecalho += ' <restriction base="string"> '
		cCabecalho += ' <maxLength value="60"/> '
		cCabecalho += ' </restriction> '
		cCabecalho += ' </simpleType> '
		cCabecalho += ' </element> '
		
		cCabecalho += ' <element name="responsavelConteudo"> '
		cCabecalho += ' <annotation> '
			cCabecalho += ' <documentation>Operadora responsАvel pela geraГЦo do arquivo XML que foi enviado para processamento.</documentation> '
		cCabecalho += ' </annotation> '
		cCabecalho += ' <simpleType> '
		cCabecalho += ' <restriction base="string"> '
		cCabecalho += ' <maxLength value="60"/> '
		cCabecalho += ' </restriction> '
		cCabecalho += ' </simpleType> '
		cCabecalho += ' </element> '
		
	cCabecalho += ' </sequence> '
	cCabecalho += ' </complexType> '
	cCabecalho += ' </element> '

	cCabecalho += ' <element name="protocoloControle" minOccurs="0"> '
	cCabecalho += ' <annotation> '
		cCabecalho += ' <documentation>Numero de controle devolvido pelo sistema importador.</documentation> '
	cCabecalho += ' </annotation> '
	cCabecalho += ' <simpleType> '
	cCabecalho += ' <restriction base="string"> '
	cCabecalho += ' <maxLength value="25"/> '
	cCabecalho += ' </restriction> '
	cCabecalho += ' </simpleType> '
	cCabecalho += ' </element> '

	cCabecalho += ' <element name="responsavelProcessamento" minOccurs="0"> '
	cCabecalho += ' <annotation> '
		cCabecalho += ' <documentation>Operador responsАvel pela XML de devoluГЦo para a Origem.</documentation> '
	cCabecalho += ' </annotation> '
	cCabecalho += ' <simpleType> '
	cCabecalho += ' <restriction base="string"> '
	cCabecalho += ' <maxLength value="120"/> '
	cCabecalho += ' </restriction> '
	cCabecalho += ' </simpleType> '
	cCabecalho += ' </element> '
	
cCabecalho += ' </sequence> '
cCabecalho += ' </complexType> '
cCabecalho += ' </element> '
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁGravacao Arquivo Tmp													   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PLGRVARQ(cCabecalho)	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁFim da funcao														   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLCORXSD   Ё Autor Ё Alexander         Ё Data Ё 03.05.2009 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Corpo do XSD												  Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLCORXSD()
LOCAL nI		:= 0	
LOCAL nTam	:= Iif( Len(aSx2)>0 , Len(aSx2[1]) ,0)
LOCAL cCorpo 	:= ""                            
LOCAL cAlias	:= ""	
LOCAL lRelOpc	:= .F.
LOCAL lBloDes:= .F.
LOCAL lFirst	:= .T.
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁMontando corpo														   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cCorpo += ' <element name="corpo"> '
cCorpo += ' <annotation> '
	cCorpo += ' <documentation>Conteudo do arquivo para importaГЦo</documentation> '
cCorpo += ' </annotation> '
cCorpo += ' <complexType> '
cCorpo += ' <sequence> '
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁAlias do Detalhe														   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For nI:=1 To Len(aSx2)
	If aSx2[nI,nTam]
		cAlias		:= aSx2[nI,1]
		cNomeAlias  := AllTrim(aSx2[nI,2])
		lBloDes		:= aSx2[nI,4]
		lRelOpc		:= aSx2[nI,5]
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁAlias Principal														   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		cCorpo += ' <element name="'+cAlias+'" maxOccurs="unbounded" '+iIf(lRelOpc,'minOccurs="0"','')+' > '
		cCorpo += ' <annotation> '
			cCorpo += ' <documentation>"'+cNomeAlias+'"</documentation> '
		cCorpo += ' </annotation> '
		cCorpo += ' <complexType> '
		cCorpo += ' <sequence> '                
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁSequencia e status so vai na tag raiz								   Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If lFirst
				cCorpo += ' <element name="sequencia"> '
				cCorpo += ' <annotation> '
					cCorpo += ' <documentation>Sequencial do registro.</documentation> '
				cCorpo += ' </annotation> '
				cCorpo += ' <simpleType> '
				cCorpo += '   <restriction base="string"> '
				cCorpo += '    <maxLength value="50000"/> '
				cCorpo += '   </restriction> '
				cCorpo += ' </simpleType> '
				cCorpo += ' </element> '
				
				cCorpo += ' <element name="status"> '
				cCorpo += ' <annotation> '
					cCorpo += ' <documentation>Controle do processamento do Arquivo.0-Aguardando Processamento, 1-Processado, 2-Erro e 3-RestriГao Operador.</documentation> '
				cCorpo += ' </annotation> '
				cCorpo += ' <simpleType> '
				cCorpo += ' <restriction base="int"> '
					cCorpo += ' <enumeration value="0"/> '
					cCorpo += ' <enumeration value="1"/> '
					cCorpo += ' <enumeration value="2"/> '
					cCorpo += ' <enumeration value="3"/> '
				cCorpo += ' </restriction> '
				cCorpo += ' </simpleType> '
				cCorpo += ' </element> '
				
				cCorpo += ' <element name="obsOperador"> '
				cCorpo += ' <annotation> '
				cCorpo += ' <documentation>ObservaГЦo referente ao motivo pelo qual o  processamento do registro, nЦo poderА ocorrer.</documentation> '
				cCorpo += ' </annotation> '
				cCorpo += ' <simpleType> '
				cCorpo += ' <restriction base="string"> '
				cCorpo += ' <maxLength value="60"/> '
				cCorpo += ' </restriction> '
				cCorpo += ' </simpleType> '
				cCorpo += ' </element> '
				
				lFirst := .F.
			EndIf	
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁRegistro																   Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			cCorpo += ' <element name="registro"> '
			cCorpo += ' <annotation> '
				cCorpo += ' <documentation>Registro composto por todos os campos</documentation> '
			cCorpo += ' </annotation> '
			cCorpo += ' <complexType> '
			cCorpo += ' <sequence> '
					
				cCorpo += ' <element name="tipoAcao"> '
				cCorpo += ' <annotation> '
					cCorpo += ' <documentation>Tipo de aГЦo tomada. 3-InclusЦo, 4-AlteraГЦo , 8-Bloqueio/Desbloqueio e 9-ReferЙncia. Obs.:O tipo 9 И utilizado para os casos de posicionamento de registro.</documentation> '
				cCorpo += ' </annotation> '
				cCorpo += ' <simpleType> '
				cCorpo += ' <restriction base="int"> '
				cCorpo += ' <enumeration value="3"/> '
				cCorpo += ' <enumeration value="4"/> '
				cCorpo += ' <enumeration value="8"/> '
				cCorpo += ' <enumeration value="9"/> '
				cCorpo += ' </restriction> '
				cCorpo += ' </simpleType> '
				cCorpo += ' </element> '
				
				cCorpo += ' <element name="campos" minOccurs="0" maxOccurs="unbounded"> '
				cCorpo += ' <annotation> '
					cCorpo += ' <documentation>Campos do registro. Deve ser informado apela no tipo de aГЦo 3-InclusЦo ou 4-AlteraГЦo</documentation> '
				cCorpo += ' </annotation> '
				cCorpo += ' <complexType> '
				cCorpo += ' <sequence> '
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//ЁGravacao Arquivo Tmp													   Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					PLGRVARQ(cCorpo)	
					cCorpo := ''
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//ЁCampos da estrutura													   Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If !PLSCAMXSD(cAlias)  
						Return .F.
					EndIf
						
				cCorpo += ' </sequence> '
				cCorpo += ' </complexType> '
				cCorpo += ' </element> '
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//ЁVerifica a possibilidade de bloqueio/desbloqueio para o registro		   Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If lBloDes
					cCorpo += ' <element name="bloqueioDesbloqueio" minOccurs="0"> '
					cCorpo += ' <annotation> '
						cCorpo += ' <documentation>Informa se o registro vai ser bloqueado ou desbloqueado.</documentation> '
					cCorpo += ' </annotation> '
					cCorpo += ' <complexType> '
					cCorpo += ' <sequence> '
	
						cCorpo += ' <element name="tipo"> '
							cCorpo += ' <annotation> '
								cCorpo += ' <documentation>Tipo de aГЦo. 0-Bloqueio e 1-Desbloqueio</documentation> '
							cCorpo += ' </annotation> '
							cCorpo += ' <simpleType> '
							cCorpo += ' <restriction base="string"> '
							cCorpo += ' <maxLength value="1"/> '
							cCorpo += ' <enumeration value="0"/> '
							cCorpo += ' <enumeration value="1"/> '
							cCorpo += ' </restriction> '
							cCorpo += ' </simpleType> '
						cCorpo += ' </element> '

						cCorpo += ' <element name="data"> '
						cCorpo += ' <annotation> '
							cCorpo += ' <documentation>Data do Bloqueio ou Desbloqueio. AAAAMMDD</documentation> '
						cCorpo += ' </annotation> '
						cCorpo += ' <simpleType> '
						cCorpo += ' <restriction base="string"> '
						cCorpo += ' <pattern value="[0-9]{4}[0-9]{2}[0-9]{2}"/> '
						cCorpo += ' </restriction> '
						cCorpo += ' </simpleType> '
						cCorpo += ' </element> '
					
						cCorpo += ' <element name="observacao" minOccurs="0"> '
							cCorpo += ' <annotation> '
								cCorpo += ' <documentation>Breve observaГЦo sobre o motivo da aГЦo.</documentation> '
							cCorpo += ' </annotation> '
							cCorpo += ' <simpleType> '
							cCorpo += ' <restriction base="string"> '
							cCorpo += ' <maxLength value="60"/> '
							cCorpo += ' </restriction> '
							cCorpo += ' </simpleType> '
						cCorpo += ' </element> '
			
					cCorpo += ' </sequence> '
					cCorpo += ' </complexType> '
					cCorpo += ' </element> '
                EndIf
                
				cCorpo += ' <element name="chave" type="integer" minOccurs="0"> '
				cCorpo += ' <annotation> '
					cCorpo += ' <documentation>Chave do registro na base de dados do destino. Deve ser informada para os tipos 4-AlteraГЦo, 8-Bloqueio/Desbloqueio ou 9-ReferЙncia.</documentation> '
				cCorpo += ' </annotation> '
				cCorpo += ' </element> '            
				
				cCorpo += ' <element name="obsProcessamento" minOccurs="0"> '
				cCorpo += ' <annotation> '
				cCorpo += ' <documentation>DescriГЦo de possМvel problema ou informaГУes genИricas</documentation> '
				cCorpo += ' </annotation> '
				cCorpo += ' <simpleType> '
				cCorpo += ' <restriction base="string"> '
				cCorpo += ' <maxLength value="240"/> '
				cCorpo += ' </restriction> '
				cCorpo += ' </simpleType> '
				cCorpo += ' </element> '
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁFechamento Registro													   Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			cCorpo += ' </sequence> '
			cCorpo += ' </complexType> '
			cCorpo += ' </element> '
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁGravacao Arquivo Tmp													   Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			PLGRVARQ(cCorpo)	
			cCorpo := ''
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁVerifica se tem outro alias											   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Len(aSx2)>=(nI+1)
			Loop
		EndIf
	EndIf	
Next		
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁFechamento do Alias													   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For nI:=1 To Len(aSx2)
	If aSx2[nI,nTam]
		cCorpo += ' </sequence> '
		cCorpo += ' </complexType> '
		cCorpo += ' </element> '    
	EndIf	
Next
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁFechamento do Alias Principal										   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cCorpo += ' </sequence> '
cCorpo += ' </complexType> '
cCorpo += ' </element> '
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁGravacao Arquivo Tmp													   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PLGRVARQ(cCorpo)	
cCorpo := ''
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁFim da funcao														   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return .T.
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLSCAMXSD  Ё Autor Ё Alexander         Ё Data Ё 03.05.2009 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Campos do XSD											  Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSCAMXSD(cAlias)  
LOCAL nI,nY		:= 0
LOCAL lCampo	:= .F.
LOCAL nTam		:= Iif( Len(aSx3)>0 , Len(aSx3[1]) ,0)
LOCAL nPos		:= aScan( aSx3,{|x|Upper(x[7])==cAlias} )
LOCAL cRestri	:= ""
LOCAL cCampos 	:= ""
LOCAL cFixed	:= ""                  
LOCAL cBoxF3	:= ""                  
LOCAL cObsBF	:= ""
LOCAL aRet 		:= {}
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁCampos																   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For nI:=nPos To Len(aSx3)  
    If aSx3[nI,7] == cAlias
	  	If aSx3[nI,nTam]                        
	  		lCampo:=.T.
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁMontando restrictions												   Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	  	    cBoxF3 := ""
	  	    cObsBF := ""                                            
	  	    cFixed := ""
	  	    If Len(aSx3[nI,9]) > 0
	  	        If Len( aSx3[nI,9] ) == 1
	  				cFixed := 'fixed="'+SubStr( aSx3[nI,9,1],1,At('-',aSx3[nI,9,1])-1 )+'"'
		  			cObsBF := SubStr( aSx3[nI,9,1],At('-',aSx3[nI,9,1])+1,Len(aSx3[nI,9,1]) )
	  	        Else
		  	    	For nY:=1 To Len(aSx3[nI,9])
		  				cBoxF3 += ' <enumeration value="'+SubStr( aSx3[nI,9,nY],1,At('-',aSx3[nI,9,nY])-1 )+'"/> '
		  				cObsBF += aSx3[nI,9,nY]+','
		  			Next
		  			cObsBF := Left(cObsBF,Len(cObsBF)-1)
		  		EndIf	
            EndIf
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁDefinindo o tipo do campo											   Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			cRestri	:= ""
			Do Case
				Case aSx3[nI,3] == 'C'
					cRestri += ' <restriction base="string"> '
						cRestri += ' <maxLength value="'+AllTrim(Str(aSx3[nI,4]))+'"/> '
						If !Empty(cBoxF3)
							cRestri += cBoxF3
						EndIF
					cRestri += ' </restriction> ' 
				Case aSx3[nI,3] == 'N' .And. !Empty(aSx3[nI,5])
					cRestri += ' <restriction base="decimal"> '
						cRestri += ' <fractionDigits value="'+AllTrim(Str(aSx3[nI,5]))+'"/> '
						cRestri += ' <totalDigits value="'+AllTrim(Str(aSx3[nI,4]))+'"/> '
						If !Empty(cBoxF3)
							cRestri += cBoxF3
						EndIF
					cRestri += ' </restriction> ' 
				Case aSx3[nI,3] == 'N'
					cRestri += ' <restriction base="integer"> '
						cRestri += ' <totalDigits value="'+AllTrim(Str(aSx3[nI,4]))+'"/> '
						If !Empty(cBoxF3)
							cRestri += cBoxF3
						EndIF
					cRestri += ' </restriction> ' 
				Case aSx3[nI,3] == 'D'    
					cRestri += ' <restriction base="string"> '
						cRestri += ' <pattern value="[0-9]{4}[0-9]{2}[0-9]{2}"/> '
						If !Empty(cBoxF3)
							cRestri += cBoxF3
						EndIF
					cRestri += ' </restriction> '
				OtherWise
					cRestri += ' <restriction base="string"> '
						cRestri += ' <maxLength value="'+AllTrim(Str(aSx3[nI,4]))+'"/> '
						If !Empty(cBoxF3)
							cRestri += cBoxF3
						EndIF
					cRestri += ' </restriction> ' 
			EndCase	
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁMontando o campo														   Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			cCampos += ' <element name="'+AllTrim(aSx3[nI,2])+'" '+cFixed+' >
			cCampos += ' <annotation> '
				cCampos += ' <documentation>'+AllTrim(aSx3[nI,1])+' - '+AllTrim(aSx3[nI,6])+Iif(!Empty(cObsBF),' [Ex:'+AllTrim(cObsBF)+']','')+'</documentation> '
			cCampos += ' </annotation> '
			cCampos += ' <simpleType> '
				cCampos += cRestri		
			cCampos += ' </simpleType> '
			cCampos += ' </element> '
			cCampos += ' '             
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁGravacao Arquivo Tmp													   Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			PLGRVARQ(StrTran(cCampos,"&","&amp;"))	
			cCampos := ''
		EndIf	
	Else
		Exit
	EndIf		
Next
If !lCampo
	MsgAlert(STR0048+cAlias+']')//'NЦo encontrado campo para o alias ['
	FErase(cDir+cFileTmp)
	Return .F.
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁFim da funcao														   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return .T.
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLRODXSD   Ё Autor Ё Alexander         Ё Data Ё 03.05.2009 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Rodape do XSD											  Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLRODXSD()
LOCAL cRodape := ""
                       
cRodape += ' <element name="rodape"> '
cRodape += ' <annotation> '
	cRodape += ' <documentation>InformaГУes referentes ao processamento da movimentaГЦo</documentation> '
cRodape += ' </annotation> '
cRodape += ' <complexType> '
cRodape += ' <sequence> '

	cRodape += ' <element name="dataHoraProcessamento"> '
	cRodape += ' <annotation> '
		cRodape += ' <documentation>Data e Hora do processamento do arquivo. AAAAMMDD-HH:MM</documentation> '
	cRodape += ' </annotation> '
	cRodape += ' <simpleType> '
	cRodape += ' <restriction base="string"> '
	cRodape += ' <pattern value="[0-9]{4}[0-9]{2}[0-9]{2}-[0-9]{2}:[0-9]{2}"/> '
	cRodape += ' </restriction> '
	cRodape += ' </simpleType> '
	cRodape += ' </element> '
	
	cRodape += ' <element name="observacao"> '
	cRodape += ' <annotation> '
		cRodape += ' <documentation>Texto livre referente a informaГЦo contida no XML</documentation> '
	cRodape += ' </annotation> '
	cRodape += ' <simpleType> '
	cRodape += ' <restriction base="string"> '
	cRodape += ' <maxLength value="240"/> '
	cRodape += ' </restriction> '
	cRodape += ' </simpleType> '
	cRodape += ' </element> '
	
cRodape += ' </sequence> '
cRodape += ' </complexType> '
cRodape += ' </element> '
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁGravacao Arquivo Tmp													   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PLGRVARQ(cRodape)	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁFim da funcao														   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return  
   
/*/{Protheus.doc} PLGERXML
Cria XML de exemplo

@author Alexander Santos
@since 05/08/2014
@version P11
/*/
function PLGERXML()
local nI,nY			:= 0
local nPos			:= 0
local nTam			:= Iif( Len(aSx3)>0 , Len(aSx3[1]) ,0)
local nTamII			:= Iif( Len(aSx2)>0 , Len(aSx2[1]) ,0)
local lFirst			:= .t.	
local lBloDes			:= .f.
local cTipo			:= ""
local cDescri			:= ""                      
local cAlias			:= ""
local cAliasRef 		:= ""
local cArqXsd			:= lower(iIf(aT('XSD',upper(cDirAlt))>0,cDirAlt,cTab))
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Nome do Arquivo															 
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
cTab := ""
for nI:=1 to len(aSx2)
	if aSx2[nI,nTamII]
		cTab += "-"+aSx2[nI,1]
	endIf	
next
                    
if !empty(cTab)
	cTab := 'sincronizador'+allTrim(cTab)+'-'+dtos(date())+"-exemplo.xml"
else 
	msgAlert(STR0054)//"Nenhuma tabela foi selecionada!"
	return
endIf

cDir := subStr(cDir,1,rAt('\',cDir))
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Verifica se o arquivo xml existe										 
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if file(cDir+cTab)       
	if msgYesNo(STR0049)//"Existe um arquivo XML, com o mesmo nome gerado nesta pasta. Deseja deletar o arquivo?"
		if fErase(cDir+cTab) == -1
			PlsLogFil(STR0050+cDir+cTab+"]",__cArqLog)//"NЦo foi possМvel deletar arquivo ["
		endIf 
	else
		return
	endIf	
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁMonta XML de Exemplo	ts = ts Saude							  	   	   
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
cDescri += '<?xml version="1.0" encoding="ISO-8859-1"?>'
cDescri += '<!--XML sincronizador - NameSpace ts (Totvs Saude)-->'
cDescri += ' <ts:sincronizador xmlns="http://localhost" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://localhost ' + cArqXsd + '" xmlns:ts="http://localhost">
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁAbertura do Cabecalho												   
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
cDescri += ' <ts:cabecalho> '
	cDescri += ' <ts:titulo>Sincronizador de dados referente ao relacionamento ['+StrTran(cCombo,'>',',')+']</ts:titulo> '
	cDescri += ' <ts:relacionamento>'+StrTran(cCombo,'>',',')+'</ts:relacionamento> '
	cDescri += ' <ts:data>'+dtos(date())+'</ts:data> '
	cDescri += ' <ts:responsavelLayout>'+AllTrim(PLRETOPE())+'</ts:responsavelLayout> '
	
	cDescri += ' <ts:entidadeRaiz> '
		cDescri += ' <ts:alias>'+subStr(cCombo,1,3)+'</ts:alias> '
		cDescri += ' <ts:idxChave>'+subStr(cComSix,1,At('-',cComSix)-1)+'</ts:idxChave> '
		cDescri += ' <ts:conteudo>'+allTrim(_cChave)+'</ts:conteudo> '
	cDescri += ' </ts:entidadeRaiz> '
	
	cDescri += ' <ts:origem> '
		cDescri += ' <ts:codigo>1010</ts:codigo> '
		cDescri += ' <ts:descricao>Empresa X</ts:descricao> '
		cDescri += ' <ts:responsavelConteudo>operador</ts:responsavelConteudo> '
	cDescri += ' </ts:origem> '
cDescri += ' </ts:cabecalho> '
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁFechamendo do cabecalho e Abertura do corpo							   
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
cDescri += ' <ts:corpo> '
for nY:=1 to len(aSx2)

	if aSx2[nY,nTamII]
		cAlias		:= aSx2[nY,1]	
		cAliasRef	:= iIf( Len(aSx2) >= nY+1 .And. aSx2[nY+1,nTamII] , aSx2[nY+1,1] , "" )
		nPos 		:= aScan( aSx3,{|x| upper(x[7])==cAlias} )
		lBloDes	:= aSx2[nY,4]
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//ЁAlias																   
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		cDescri += ' <ts:'+AllTrim(cAlias)+'> '
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//ЁSomente para o alias raiz											   
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			if lFirst
				cDescri += ' <ts:sequencia>00000</ts:sequencia> '
				cDescri += ' <ts:status>0</ts:status> '
				cDescri += ' <ts:obsOperador></ts:obsOperador> '
				lFirst := .f.	
			endIf	
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//ЁRegistro																  
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			cDescri += ' <ts:registro> '
			
				cDescri += ' <ts:tipoAcao>3</ts:tipoAcao> '
				cDescri += ' <ts:campos> '
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
					//ЁInclui campos														   
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
					for nI:=nPos to len(aSx3)
					  
						if aSx3[nI,7] == cAlias
						
							if aSx3[nI,nTam]
								//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
								//ЁRestricoes															   
								//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
								cRestri := ""
								if Len(aSx3[nI,9])>0
									cRestri := SubStr( aSx3[nI,9,1],1,At('-',aSx3[nI,9,1])-1 ) 
								endIf
								//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
								//ЁConteudo campo														   
								//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
								do case
									case aSx3[nI,3] == 'C'          
										cTipo := iIf(!empty(cRestri),cRestri,'0')
									case aSx3[nI,3] == 'N' .And. !Empty(aSx3[nI,5])
										cTipo := iIf(!empty(cRestri),cRestri,'00001')
									case aSx3[nI,3] == 'N'
										cTipo := iIf(!empty(cRestri),cRestri,'00001')
									case aSx3[nI,3] == 'D'      
										cTipo := '19000101'
									OtherWise
										cTipo := iIf(!Empty(cRestri),cRestri,'0')
								endCase	
								//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
								//ЁMontando Tag															   
								//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
								cDescri += '    <ts:'+AllTrim(aSx3[nI,2])+'>'+cTipo+'</ts:'+AllTrim(aSx3[nI,2])+'> '
							endIf
						else 
							exit
						endIf	
					next              
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				//ЁFecha campos e dados													   
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				cDescri += ' </ts:campos> '
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				//ЁBloqueio/Desbloqueio													   
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				if lBloDes				
					cDescri += ' <ts:bloqueioDesbloqueio> '
						cDescri += ' <ts:tipo>0</ts:tipo>'
						cDescri += ' <ts:data>19000101</ts:data>'
						cDescri += ' <ts:observacao>exemplo de bloqueio</ts:observacao>'
					cDescri += ' </ts:bloqueioDesbloqueio> '
				endIf
			cDescri += ' </ts:registro> '
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//ЁGrava conteudo														   
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			PLGRVARQ(cDescri)	
			cDescri := ''
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//ЁVerifica se tem mais algum alias										   
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		if len(aSx2)>=(nY+1)
			loop
		endIf						
	endIf
next
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁFechamento dos alias													   
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
for nY:=Len(aSx2) to 1 step -1
	if aSx2[nY,nTamII]
		cDescri += ' </ts:'+AllTrim(aSx2[nY,1])+'> '
	endIf
next			
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁFechamento do corpo													   
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
cDescri += ' </ts:corpo> '      
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁAbertura do rodape													   
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
cDescri += ' <ts:rodape> '                        
cDescri += ' <ts:dataHoraProcessamento>19000101-01:01</ts:dataHoraProcessamento> '
cDescri += ' <ts:observacao>Texto Livre</ts:observacao> '
cDescri += ' </ts:rodape>
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁFechamento Raiz														   
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
cDescri += ' </ts:sincronizador> '
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁGravacao Arquivo Tmp	em XML												   
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if PLGRVARQ(cDescri,'XML')	
	cDir += cTab
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁFim da funcao														   
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
return   
  
/*/{Protheus.doc} PLGERCSV
Cria CSV de exemplo

@author Alexander Santos
@since 05/08/2014
@version P11
/*/
function PLGERCSV()
local nI,nY			:= 0
local nPos			:= 0
local nTam			:= Iif( Len(aSx3)>0 , Len(aSx3[1]) ,0)
local nTamII			:= Iif( Len(aSx2)>0 , Len(aSx2[1]) ,0)
local lFirst			:= .t.	
local lBloDes			:= .f.
local cTipo			:= ""
local cDescri			:= ""                      
local cAlias			:= ""
local cArqXsd			:= lower(iIf(aT('XSD',upper(cDirAlt))>0,cDirAlt,cTab))
local cCabCSV			:= 'STATUS@;OBSOOPERADOR@'
local cContCSV		:= '0;observacao do operador'
local cCabCampos		:= ''
local cContCampos	:= ''
local cCsv			:= ''
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Nome do Arquivo															 
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
cTab := ""
for nI:=1 to len(aSx2)
	if aSx2[nI,nTamII]
		cTab += "-"+aSx2[nI,1]
	endIf	
next
                    
if !empty(cTab)
	cTab := 'sincronizador'+allTrim(cTab)+'-'+dtos(date())+"-exemplo.csv"
else 
	msgAlert(STR0051)//"Nenhuma tabela foi selecionada!"
	return
endIf

cDir := subStr(cDir,1,rAt('\',cDir))
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Verifica se o arquivo xml existe										 
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if file(cDir+cTab)       
	if msgYesNo(STR0052)//"Existe um arquivo CSV, com o mesmo nome gerado nesta pasta. Deseja deletar o arquivo?"
		if fErase(cDir+cTab) == -1
			PlsLogFil(STR0053+cDir+cTab+"]",__cArqLog)//"NЦo foi possМvel deletar arquivo ["
		endIf 
	else
		return
	endIf	
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁCorpo							   
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
for nY:=1 to len(aSx2)

	if aSx2[nY,nTamII]
		cAlias		:= aSx2[nY,1]	
		nPos 		:= aScan( aSx3,{|x| upper(x[7])==cAlias} )
		lBloDes	:= aSx2[nY,4]

		cCabCSV	+= ';'+cAlias+'OBSPROCESSAMENTO@;'+cAlias+'TIPOACAO@;'+cAlias+'CHAVE@'
		cContCSV 	+= ';observacao do processamento '+cAlias+';3;000010002'
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//ЁInclui campos														   
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		for nI:=nPos to len(aSx3)
		  
			if aSx3[nI,7] == cAlias
			
				if aSx3[nI,nTam]
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
					//ЁRestricoes															   
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
					cRestri := ""
					if Len(aSx3[nI,9])>0
						cRestri := SubStr( aSx3[nI,9,1],1,At('-',aSx3[nI,9,1])-1 ) 
					endIf
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
					//ЁConteudo campo														   
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
					do case
						case aSx3[nI,3] == 'C'          
							cTipo := iIf(!empty(cRestri),cRestri,'0')
						case aSx3[nI,3] == 'N' .And. !Empty(aSx3[nI,5])
							cTipo := iIf(!empty(cRestri),cRestri,'00001')
						case aSx3[nI,3] == 'N'
							cTipo := iIf(!empty(cRestri),cRestri,'00001')
						case aSx3[nI,3] == 'D'      
							cTipo := '19000101'
						OtherWise
							cTipo := iIf(!Empty(cRestri),cRestri,'0')
					endCase	
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
					//ЁMontando cab e conteudo															   
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
					cCabCampos		+= ';'+allTrim(aSx3[nI,2])
					cContCampos 	+= ';'+cTipo
				endIf
			else 
				exit
			endIf	
		next              
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//ЁBloqueio/Desbloqueio													   
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		if lBloDes				
			cCabCSV	+= ';'+cAlias+'BLODES@;'+cAlias+'DATBLO@'
			cContCSV 	+= ';0;19000101'
		endIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//ЁCabecalho e conteudo do csv														   
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		cCabCSV  += cCabCampos
		cContCSV += cContCampos
		
		cCabCampos  := '' 
		cContCampos := ''
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//ЁVerifica se tem mais algum alias										   
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		if len(aSx2)>=(nY+1)
			loop
		endIf						
	endIf
next
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁGrava conteudo														   
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
PLGRVARQ(cCabCSV+chr(10)+cContCSV)	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁGravacao Arquivo Tmp	em XML												   
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if PLGRVARQ('','CSV')	
	cDir += cTab
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁFim da funcao														   
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
return     
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLGRVARQ   Ё Autor Ё Alexander         Ё Data Ё 03.05.2009 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Gravacao do XSD e XML								      Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLGRVARQ(cConteudo,cTipo,cFile,cDirInfo,lBuffer)
local lRet		   := .f.
default cConteudo	:= ""      
default cTipo		:= ""         
default cFile		:= ""
default cDirInfo		:= ""
default lBuffer		:= .f.

if !empty(cDirInfo)
	cDir := cDirInfo
endIf

if !empty(cFile)
	cTab := cFile
endIf

cDir := subStr(cDir,1,rAt('\',cDir))

PlsLogFil(strTran(strTran(cConteudo,chr(13),''),"> ","> "+chr(10)),cDir+cFileTmp,lBuffer,,.f.)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Final do Processo														 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !empty(cTipo) 
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica se o tmp existe												 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	if file(cDir+cFileTmp)       
		if fREname(cDir+cFileTmp , cDir+cTab ) == -1
		   MsgAlert(STR0029+cTipo) //"ImpossМvel criar arquivo de "
		else
		   lRet := .T.
		   MsgAlert(STR0030+cTipo+STR0031) //"Arquivo "###" gerado com sucesso!"
		endIf
	endIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Deleta TMP																 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	if FErase(cDir+cFileTmp) == -1
		PlsLogFil(STR0032+cDir+cFileTmp+"]",__cArqLog) //"NЦo foi possМvel deletar arquivo temporario ["
	endIf 
endIf	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da rotina															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
return lRet
