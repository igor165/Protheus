#INCLUDE 'PROTHEUS.CH'
#INCLUDE "rwmake.ch"
#INCLUDE "LOJA863.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ LOJA863  บAutor  ณMicrosiga           บ Data ณ  21/01/2013 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina para mostrar o Log de erro de Importacao            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Webservice                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function LOJA863()

Local nOpcA                       //Variavel para confirmacao de gravacao
Local aObj                        //Matriz para dimensionamento de tela do dialogo
Local aSizeAut                    //Matriz para dimensionamento de tela do dialogo
Local aInfo                       //Matriz para dimensionamento de tela do dialogo
Local aPObj                       //Matriz para dimensionamento de tela do dialogo
Local oDlg                        //Objeto do dialogo
Local oCbx                        //Objeto do combobox dos webservices
Local oCbx1                       //Objeto do combobox dos metodos dos webservices
Local oCbs

Local  nCor      := 239           //Cor do painel
Local  cAlias	 := "MEZ"         //Alias principal do cadastro

Local  cMeto     := ""            //Metodo selecionado para filtragem
Local  cStatus   := ""            //Status selecionado para filtragem
Local  cEcFlag	 := ""				//Flag e-commerce
Local  cChaveEC	 := space(MEY->(TamSx3("MEY_ECCCHV"))[1])			  //Chave e-commerce  
Local  aRet		:= {}

Private cCadastro
Private aRotina
  

cCadastro := STR0001  //"Cadastro Log de Importa็ใo"

aRotina   := {}   // Usado no Perfil do Log
AAdd(aRotina,{ STR0002    ,"AxPesqui()" , 0, 1})    //"Pesquisar"
AAdd(aRotina,{ STR0003    ,'AxVisual()' , 0, 2})    //"Visualizar"

nOpcA:=0

dbSelectArea(cAlias)
dbSetOrder(2)

MEZ->(DbGoTop())

cQuery := "SELECT MEZ_FILIAL, MEZ_ECFLAG," 
cQuery += "MEZ_ECWS, MEZ_ECMETO FROM "+RetSQLName("MEZ")+" MEZ " 
cQuery += " WHERE MEZ.D_E_L_E_T_ <> '*'  "  
cQuery += "GROUP BY MEZ_FILIAL, MEZ_ECFLAG,  MEZ_ECWS,  MEZ_ECMETO"

If  (Select("TEMP") > 0)
	TEMP->( DbCloseArea() )
EndIf

cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TEMP', .T., .T.)

dbSelectArea("TEMP")

aStatus   := {}
aWS       := {STR0006}       //"Todos"
aMeto     := {STR0006}       //"Todos"
aListMeto := {}

Do While !(EoF())                    

	If RTrim(TEMP->MEZ_ECFLAG) == "A"
		cEcFlag := RTrim(TEMP->MEZ_ECFLAG) + "-"+STR0004  //"Aberto"
	Else 
		cEcFlag := RTrim(TEMP->MEZ_ECFLAG) + "-"+STR0005	//Concluido"
	EndIf
	
	nPos  := Ascan(aStatus, cEcFlag)
	nPos1 := Ascan(aWs, TEMP->MEZ_ECWS)
	nPos2 := Ascan(aMeto, TEMP->MEZ_ECMETO)
	
	If (nPos = 0)
		aadd(aStatus, cEcFlag)
	Endif
	
	If (nPos1 = 0)
		aadd(aWs, TEMP->MEZ_ECWS)
	Endif
	
	If (nPos2 = 0)
		aadd(aListMeto, TEMP->({MEZ_ECWS, MEZ_ECMETO}))
	Endif
	
	dbSkip() 
	
Enddo

If  (Len(aStatus) > 0)
	cStatus := aStatus[1]
Endif

cWS := aWs[1]
cMeto := aMeto[1]
cFiltro := ""
dDeDt := CTOD("01/01/2013")
dAtDt := CTOD("31/12/2049")

dbCloseArea()

dbSelectArea(cAlias)
dbSetOrder(2)
DbGoTop()

aObj := {}

aSizeAut  := MsAdvSize(.t.)

// Serแ utilizado tr๊s แreas na janela
// 1- Enchoice, sendo 80 pontos pixel
// 2- MsGetDados, o que sobrar em pontos pixel ้ para este objeto
// 3- Rodap้ que ้ a pr๓pria janela, sendo 15 pontos pixel

AADD( aObj, { 100, 030, .T., .F. })
AADD( aObj, { 355, 200, .F., .T. })

aInfo := { aSizeAut[1], aSizeAut[2], aSizeAut[3], aSizeAut[4], 3, 3 }

aPObj := MsObjSize( aInfo, aObj) 


LJ863Filtra(nil, nil, NIl,cStatus,cWs, cMeto, dDeDt, dAtDt, cChaveEC)

DEFINE MSDIALOG oDlg TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	oPanel:= tPanel():New(aPObj[1,1], aPObj[1,2], "", oDlg,,,,,RGB(nCor,nCor,nCor), (aPObj[1,4]-aPObj[1,2]), (aPObj[1,3]-aPObj[1,1]),.T.,.F.)
	@004,001  SAY STR0007	  SIZE 30, 09 OF oPanel PIXEL     //"FILTROS:"
	@004,040  SAY STR0008     SIZE 30, 09 OF oPanel PIXEL     //"STATUS  "
	@004,105  SAY STR0009     SIZE 35, 25 OF oPanel PIXEL     //"WEBSERVICE "
	@004,170  SAY STR0010     SIZE 30, 09 OF oPanel PIXEL     //"METODOS "
	@004,235  SAY STR0011 + " " + STR0012     SIZE 30, 09 OF oPanel PIXEL     //"DATA "
	@012,235  MSGET dDeDt     SIZE 40, 09 OF oPanel PIXEL  
	@004,285 SAY STR0013     SIZE 10, 09 OF oPanel PIXEL     //"Ate: "
	@012,285  MSGET dAtDt     SIZE 40, 09 OF oPanel PIXEL  
	@004,335  SAY STR0032     SIZE 56, 09 OF oPanel PIXEL     //"CHAVE E-COMMERCE" 
	@012,335  MSGET cChaveEC     SIZE 100, 09 OF oPanel PIXEL  
		
	oSButton := SButton():New( 015,455,17,{|x| LJ863Filtra(@oDlg,@oCbx1,@oBrowse,cStatus,cWs,cMeto,dDeDt,dAtDt, cChaveEC)},oDlg,.T.,,) 
		
	oCbs := TComboBox():New( 015,040,{|u| if( Pcount( )>0, cStatus:= u, cStatus )},aStatus,050,017,oDlg,,{|x| LJ863Filtra(@oDlg,@oCbx1,@oBrowse,cStatus,cWs,cMeto,dDeDt,dAtDt, cChaveEC)},,,,.T.,,,,,,,,,"cStatus")
	oCbx := TComboBox():New( 015,105,{|u| if( Pcount( )>0, cWs:= u, cWs )},aWs,050,026,oDlg,,{|x| LJ863MdaCbx(@oDlg, cWs, @oCbx1, aListmeto)},,,,.T.,,,,,,,,,"cWs")
	oCbx1:= TComboBox():New( 015,170,{|u| if( Pcount( )>0, cMeto:= u, cMeto )},aMeto,050,026,oDlg,,{|x| LJ863Filtra(@oDlg,@oCbx1,@oBrowse,cStatus,cWs,cMeto,dDeDt,dAtDt, cChaveEC)},,,,.T.,,,,,,,,,"cMeto")
		
	oBrowse := BrGetDDB():New( aPObj[2,1],aPObj[2,2],(aPObj[1,4]-aPObj[1,2]),aPObj[2,3]-aPObj[2,1],,,,oDlg,,,,,{|x| LJ863Detalhe()},,,,,,,.F.,cAlias,.T.,,.F.,,, )
	oBrowse:AddColumn( TCColumn():New(STR0014  ,{||MEZ->MEZ_FILIAL },"@!",,,"LEFT",,,.F.,,,,,))      //"Filial"
	oBrowse:AddColumn( TCColumn():New(STR0015  ,{||MEZ->MEZ_ECFLAG },"@!(1)",,,"LEFT",,,.F.,,,,,))   //"Status"
	oBrowse:AddColumn( TCColumn():New(STR0016  ,{||MEZ->MEZ_ECWS },"@!(10)",,,"LEFT",,,.F.,,,,,))    //"WebService"
	oBrowse:AddColumn( TCColumn():New(STR0017  ,{||MEZ->MEZ_ECMETO },"@!(10)",,,"LEFT",,,.F.,,,,,))  //"Metodo"
	oBrowse:AddColumn( TCColumn():New(STR0018  ,{||MEZ->MEZ_ECDATA },,,,"LEFT",,,.F.,,,,,))          //"Data"
	oBrowse:AddColumn( TCColumn():New(STR0019  ,{||MEZ->MEZ_ECHORA },,,,"LEFT",,,.F.,,,,,))          //"Hora" 
	oBrowse:AddColumn( TCColumn():New("Chave e-Commerce"  ,{|| aRet:={"",""}, aRet := GetAdvFVal('MEY', {'MEY_ECCCHV', 'MEY_ECVCHV'},  xFilial('MEY') + MEZ->MEZ_ECREFE ,1, {"",""} ), aRet[1] },,,,"LEFT",,,.F.,,,,,))          //"Chave EC" 
	oBrowse:AddColumn( TCColumn():New("Chave Interna"  ,{||  aRet[2] },,,,"LEFT",,,.F.,,,,,))          //"Chave EC" 

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpcA := 1, oDlg:End()},{||oDlg:End()},,,,)

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJ863MdaCbxบAutor ณMicrosiga           บ Data ณ  31/01/13   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณSeleciona os metodos do webservice selecionado pelo usuario บฑฑ
ฑฑบ          ณpara o combobox de metodos                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oDlg  - Objeto do Dialogo                                  บฑฑ
ฑฑบ          ณ cWs   - WebService selecionado para a filtragem            บฑฑ
ฑฑบ          ณ oCbx1 - Objeto do combobox dos metodos                     บฑฑ
ฑฑบ          ณ aListmeto - matriz com todos os metodos encontrados        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function LJ863MdaCbx(oDlg, cWs, oCbx1, aListmeto)

Local aMeto := {STR0006}     //Matriz dos metodos de filtragem     //"Todos"
Local nx    := 0             //contador do comando For

Default oDlg      := nil
Default cWs       := ""
Default oCbx1     := nil
Default aListmeto := {}

For nx := 1 to Len(aListmeto)
	If Alltrim(aListmeto[nx][1]) == Alltrim(cWs)
		aadd(aMeto, aListmeto[nx][2])
	Endif
Next
                       
If  (oDlg <> nil)
	oCbx1:SetItems(aMeto)  
	oCbx1:Refresh()
	oDlg:Refresh()
EndIf	

return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJ863FiltraบAutor ณMicrosiga           บ Data ณ  31/01/13   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta a condicao de filtragem                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oDlg    - Objeto do Dialogo                                บฑฑ
ฑฑบ          ณ oBrowse - Objeto do browse                                 บฑฑ
ฑฑบ          ณ cStatus - Status selecionado para a filtragem              บฑฑ
ฑฑบ          ณ cWs     - WebService selecionado para a filtragem          บฑฑ
ฑฑบ          ณ cMeto   - Metodo selecionado para a filtragem              บฑฑ
ฑฑบ          ณ dDeDt   - Data inicial para a filtragem                    บฑฑ
ฑฑบ          ณ dAtDt   - Data final para a filtragem                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function LJ863Filtra(oDlg, oCbx1, oBrowse, cStatus,;
                             cWs, cMeto, dDeDt, dAtDt,;
                             cChaveEC)

Local cFiltro := ""   //Condicao de filtragem 
Local aRet	  := {} //Retorno do Filtro

Default oDlg    := nil
Default oBrowse := nil
Default cStatus := ""
Default cWs     := ""
Default cMeto   := ""
Default dDeDt   := CtoD(Space(8))
Default dAtDt   := CtoD(Space(8))           
Default cChaveEC := ""


dbSelectArea("MEZ")
dbSetOrder(2)                                                              
	
If  (Upper(cWs) == Upper(AllTrim(STR0006))) .And. (Upper(cMeto) == Upper(AllTrim(STR0006)))    //"Todos"
	cFiltro := "MEZ_ECFLAG = '"+SubStr(cStatus,1,1)+"'"
Endif

If  (Upper(cWs) <> Upper(AllTrim(STR0006))) .And. (Upper(cMeto) == Upper(AllTrim(STR0006)))    //"Todos"
	cFiltro := "MEZ_ECFLAG = '"+SubStr(cStatus,1,1)+"' .And. MEZ_ECWS = '"+cWs+"'"
Endif

If  (Upper(cWs) == Upper(AllTrim(STR0006))) .And. (Upper(cMeto) <> Upper(AllTrim(STR0006)))    //"Todos"
	cFiltro := "MEZ_ECFLAG = '"+SubStr(cStatus,1,1)+"' .And. MEZ_ECMETO = '"+cMeto+"'"
Endif

If  (Upper(cWs) <> Upper(AllTrim(STR0006))) .And. (Upper(cMeto) <> Upper(AllTrim(STR0006)))    //"Todos"
	cFiltro := "MEZ_ECFLAG = '"+SubStr(cStatus,1,1)+"' .And. MEZ_ECWS = '"+cWs+"' .And. MEZ_ECMETO = '"+cMeto+"'"
Endif

If  !( Empty(dDeDt) ) .And. !( Empty(dAtDt) )
    cFiltro += " .And. DTOS(MEZ_ECDATA) >= '"+DTOS(dDeDt)+"' .And. DTOS(MEZ_ECDATA) <= '"+DTOS(dAtDt)+"'"
EndIf                         


If Substr(cStatus,3) <> STR0006
	If !Empty(cFiltro)
		cFiltro += " .And. ( aRet := {'',''}, aRet := GetAdvFVal('MEY', {'MEY_ECFLAG','MEY_ECCCHV'} ,  xFilial('MEY') + MEZ->MEZ_ECREFE ,1, {'X',''} ),  !( Empty(aRet[1]) .Or. aRet[1] " + IIF(SubStr(cStatus,1,1) <> "X", " = 'X'  ", " $ 'EX'") +"))"
	Else
	
		cFiltro += "  ( aRet := {'',''}, aRet := GetAdvFVal('MEY', {'MEY_ECFLAG', 'MEY_ECCCHV'},  xFilial('MEY') + MEZ->MEZ_ECREFE ,1, {'X',''} ),  !(Empty(aRet[1]) .Or. aRet[1] " + IIF(SubStr(cStatus,1,1) <> "X", " = 'X'", " $ 'EX'") + "))"
	EndIf 
	
	If !Empty(cChaveEC)
		cFiltro += " .And. RTrim(aRet[2]) == '" + RTrim(cChaveEC) + "'"
	EndIf
ElseIf !Empty(cChaveEC)
	If !Empty(cFiltro)
		cFiltro += "  .And. ( aRet := {'',''}, aRet := GetAdvFVal('MEY', {'MEY_ECFLAG','MEY_ECCCHV'} ,  xFilial('MEY') + MEZ->MEZ_ECREFE ,1, {'X',''} ) , ( !Empty(aRet[1]) .And. aRet[1] <> 'X'  ) ) "
	Else
	
		cFiltro += "  ( aRet := {'',''}, aRet := GetAdvFVal('MEY', {'MEY_ECFLAG', 'MEY_ECCCHV'},  xFilial('MEY') + MEZ->MEZ_ECREFE ,1, {'X',''} ),  ( Empty(aRet[1]) .And. aRet[1] <> 'X' ) ) "
	EndIf 
	

	cFiltro += " .And. RTrim(aRet[2]) == '" + RTrim(cChaveEC) + "'"

Else
	If !Empty(cFiltro)
		
		cFiltro += " .And. !Empty(GetAdvFVal('MEY', 'MEY_ECFLAG' ,  xFilial('MEY') + MEZ->MEZ_ECREFE ,1, '' ) ) " 
	Else
	
		cFiltro += " !Empty(GetAdvFVal('MEY', 'MEY_ECFLAG',  xFilial('MEY') + MEZ->MEZ_ECREFE ,1, '' ) ) "
	EndIf
EndIf
	
SET FILTER TO &(cFiltro) 

DbSelectArea("MEZ")
DbGotop()

If  (oDlg <> nil)
	oBrowse:refresh()
	oDlg:Refresh()
EndIf
	
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJ863DetalheบAutorณMicrosiga           บ Data ณ  01/31/13   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela com os detalhes do log de erro                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function LJ863Detalhe()

Local oDlg1                                 //Objeto do Dialogo
Local aAreaMEZ	:= MEZ->(GetArea())        //Salva a area da tabela MEZ
Local cStatus	:= MEZ->MEZ_ECFLAG          //Status do log de erro
Local cNvl		:= MEZ->MEZ_ECNVL           //Nivel da execucao do log de erro
Local cSeq		:= MEZ->MEZ_ECSEQ           //Codigo sequencial do log de erro
Local cRef		:= MEZ->MEZ_ECREFE          //Codigo de referencia a tabela intermediaria
Local cWs		:= MEZ->MEZ_ECWS            //WebService do log de erro
Local cMetWs	:= MEZ->MEZ_ECMETO          //Metodo do log de erro
Local cData		:= MEZ->MEZ_ECDATA          //Data do log de erro
Local cHora		:= MEZ->MEZ_ECHORA          //Hora do log de erro
Local cDetalhe	:= MEZ->MEZ_ECMENS          //Mensagem do log de erro
Local cJob		:= MEZ->MEZ_ECJOB           //Job que gerou o log de erro
Local cSoldt	:= MEZ->MEZ_ECDTS           //Data da Solucao do log de erro
Local cSolHr	:= MEZ->MEZ_ECHRS           //Hora da solucao do log de erro
Local cUser		:= MEZ->MEZ_ECUSER          //Usuario que processou a solucao do log de erro
Local cXML		:= ""                       //XML do log de erro
Local nOpcA     := 0                        //Confirmacao da gravacao  
Local cChaveEC	:= ""
Local cChaveERP := ""

DbSelectArea("MEY")
DbSetOrder(1)
If DbSeek(xFilial("MEY")+cRef) .And.  MEY->MEY_ECFLAG <> 'X'
	cXML := StrTran(MEY->MEY_ECXML,"><",">"+CRLF+"<")  
	cChaveEC := MEY->MEY_ECCCHV
	cChaveERP	:=  MEY->MEY_ECVCHV
EndIf	

DEFINE MSDIALOG oDlg1 TITLE STR0020 Style DS_MODALFRAME FROM 0,0 TO 640,585 OF oMainWnd PIXEL    //"Detalhe do LOG"
 
oDlg1:lEscClose:=.F.

@010,010 Say STR0021 Size 30, 09 Of oDlg1 Pixel     //"Status:"
If cStatus == "A"
	@009,030 ComboBox oCombo Var cStatus Items {"A-"+STR0004,"X-"+STR0005} Size 45, 09 Of oDlg1 Pixel  //"Aberto"##"Concluido"
Else
	@009,030 ComboBox oCombo Var cStatus Items {"X-"+STR0005} Size 45, 09 Of oDlg1 Pixel   //"Concluido"
EndIf	                                         

@010,080 Say STR0022 Size 30,09 Of oDlg1 Pixel            //"Nํvel:"
@009,095 MsGet cNvl When .F. Size 20,09 Of oDlg1 Pixel 
@010,120 Say STR0023 Size 30,09 Of oDlg1 Pixel            //"Sequencial:"
@009,150 MsGet cSeq When .F. Size 50,09 Of oDlg1 Pixel 
@010,205 Say STR0024 Size 30,09 Of oDlg1 Pixel            //"Referencia:"
@009,235 MsGet cRef When .F. Size 50,09 Of oDlg1 Pixel 

@035,010 Say STR0025 Size 40,09 Of oDlg1 Pixel            //"WebService:"
@034,042 MsGet cWs When .F. Size 110,09 Of oDlg1 Pixel 
@035,153 Say STR0026 Size 40,09 Of oDlg1 Pixel            //"Metodo:"
@034,175 MsGet cMetWs When .F. Size 110,09 Of oDlg1 Pixel

@060,010 Say STR0027 Size 30,09 Of oDlg1 Pixel            //"Data:"
@059,025 MsGet cData When .F. Size 40,09 Of oDlg1 Pixel 
@060,075 Say STR0028 Size 30,09 Of oDlg1 Pixel            //"Hora:"
@059,090 MsGet cHora When .F. Size 30,09 Of oDlg1 Pixel
@060,130 Say STR0029 Size 20,09 Of oDlg1 Pixel            //"Job:"
@059,145 MsGet cJob When .F. Size 130,09 Of oDlg1 Pixel           


//Chave e-commece //Chave Protheus
@085,010 Say STR0033 Size 45,09  Of oDlg1 Pixel     //"Chave EC:"
@084,040 MsGet cChaveEC When .F. Size 100,09 Of oDlg1 Pixel
@085,145 Say STR0034 Size 50,09 Of oDlg1 Pixel     //"Chave Interna:"
@084,185 MsGet cChaveERP When .F. Size 100,09 Of oDlg1 Pixel


@105,010 TO 135,285 LABEL STR0030 OF oDlg1 PIXEL          //"Solu็ใo"
@115,015 Say STR0027 Size 30,09 Of oDlg1 Pixel            //"Data:"
@114,030 MsGet cSoldt When .F. Size 40,09 Of oDlg1 Pixel 
@115,080 Say STR0028 Size 30,09 Of oDlg1 Pixel            //"Hora:"
@114,095 MsGet cSolHr When .F. Size 30,09 Of oDlg1 Pixel
@115,135 Say STR0031 Size 30,09 Of oDlg1 Pixel            //"Usuแrio:"
@114,158 MsGet cUser When .F. Size 120,09 Of oDlg1 Pixel

@135,010 TO 235,285 LABEL "XML" OF oDlg1 PIXEL
oTMultiget1 := tMultiget():new(145,015, {| u | If( PCount() > 0, cXML := u, cXML ) }, oDlg1, 262,085, ,.T. , , , , .T.,,,,,,,,,,,,,,,,,,,,.T. )

oTMultiget2 := tMultiget():new(240,010, {| u | If( PCount() > 0, cDetalhe := u, cDetalhe ) }, oDlg1, 275,065, , .t., , , , .T.,,,,,,,,,,,,,,,,,,,,.T.  )

ACTIVATE MSDIALOG oDlg1 CENTER ON INIT EnchoiceBar(oDlg1,{|| nOpcA := 1, IIF(LJECMATU(oDlg1,cStatus,cSeq,cRef,nOpcA, cXML),oDlg1:End(),NIL)},{||oDlg1:End()},,,,)
                                  
RestArea(aAreaMEZ)

Return       

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ LJECMATU   บAutorณMicrosiga           บ Data ณ  31/01/13   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gravacao da alteracao de Status do Log de erro             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oDlg1   - Objeto do Dialogo                                บฑฑ
ฑฑบ          ณ cStatus - Novo Status a ser gravado                        บฑฑ
ฑฑบ          ณ cSeq    - Codigo sequencial do log de erro                 บฑฑ
ฑฑบ          ณ cRef    - Codigo de referencia a tabela intermediaria      บฑฑ
ฑฑบ          ณ nOpcA   - Confirmacao da gravacao                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function LJECMATU(oDlg1, cStatus, cSeq, cRef,;
                         nOpcA, cXML)
 
Local lRet   := .F.                 //Retorna verdadeiro se gravou sem problemas.
Local cOrig  := MEZ->MEZ_ECFLAG     //Status original antes da gravacao.
Local cUser  := __cUserID           //Codigo do usuario que esta alterando o Status do log de erro.
Local cNomUs := ""                  //Nome do usuario que esta alterando o Status do log de erro.

Default oDlg1   := nil
Default cStatus := ""
Default cSeq    := ""
Default cRef    := ""
Default nOpcA   := 0
Default cXML    := "" 

PswOrder(2)
If  PswSeek(alltrim(cUser))
	cNomUs := PswRet(1)[1][2] 
EndIf
 
If nOpcA == 1
	If SubStr(cStatus,1,1) <> cOrig .And. SubStr(cStatus,1,1) == "X"
	    DbSelectArea("MEZ")
	    DbSetOrder(1)
    	If DbSeek(xFilial("MEZ")+cOrig+cSeq)
    		RecLock("MEZ",.F.)
    		MEZ->MEZ_ECFLAG := "X"
    		MEZ->MEZ_ECDTS	:= Date()
			MEZ->MEZ_ECHRS	:= Time()
			MEZ->MEZ_ECUSER	:= cUser+" - "+cNomUs
    		MsUnLock()
    		DbSelectArea("MEY")
    		DbSetOrder(1)
    		If DbSeek(xFilial("MEY")+cRef)
    			RecLock("MEY",.F.)
    			MEY->MEY_ECFLAG := "Z" 
    			MEY->MEY_NPROCE := 0 
    			cXML := StrTran(MEY->MEY_ECXML,">"+CRLF+"<","><")   //Desformata o XML para a rotina de re-processamento nใo deletแ-lo
    			MEY->MEY_ECXML := cXML
    			MsUnLock()
    		EndIf
            lRet := .T.
        Else
            lRet := .F.
        EndIf    
    Else
    	lRet := .T.
    EndIf
EndIf

If  (oDlg1 <> nil)
    oDlg1:Refresh()
EndIf    

Return lRet                      