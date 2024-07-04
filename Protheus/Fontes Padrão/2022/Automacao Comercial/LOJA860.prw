#INCLUDE 'PROTHEUS.CH'
#INCLUDE "rwmake.ch"
#INCLUDE "LOJA860.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ LOJA860  บAutor  ณMicrosiga           บ Data ณ  21/01/2013 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina para mostrar o Log de erro de Exportacao            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Webservice                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Function LOJA860()

Local nOpcA       // Variavel para a confirmacao de grava็ao
Local aObj        // matriz para dimensionamento da tela
Local aSizeAut    // matriz para dimensionamento da tela
Local aInfo       // matriz para dimensionamento da tela
Local aPObj       // matriz com as posicoes calculadas pela funcao de dimensionamento da tela
Local oDlg        // objeto do dialogo de tela
Local oCbx        // Objeto Combobox referente ao webservice
Local oCbx1       // Objeto Combobox referente ao metodo
Local oCbs        // Objeto Combobox referente ao status
Local oBrowse	// Browse
Local nCor      := 239
Local cMeto     := ""
Local aRet		:= {} 
Local cEcvChv	:= space(TamSx3("MF3_ECVCHV")[1]) //Chave interna 
Local aPObj2	:= {} //Matriz com as posi็๕es calculadas pela fun็ใo de dimensionamento da tela

Private cCadastro := STR0001        //"Cadastro Log de Exporta็ใo"
Private aRotina   := {}   // Usado no Perfil do Log
  
AAdd(aRotina,{ STR0002    ,"AxPesqui()" , 0, 1})     //"Pesquisar"
AAdd(aRotina,{ STR0003    ,'AxVisual()' , 0, 2})     //"Visualizar"

nOpcA:=0

cQuery := "SELECT MF4_ECWS, MF4_ECMETO FROM "+RetSQLName("MF4")+" MF4 "
cQuery += "WHERE D_E_L_E_T_ <> '*'"
cQuery += "GROUP BY  MF4_ECWS,  MF4_ECMETO"

If  (Select("TEMP") > 0)
	TEMP->( DbCloseArea() )
EndIf

cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TEMP', .T., .T.)

dbSelectArea("TEMP")

aStatus   := {"A-"+STR0004, "X-"+STR0005, "Z-"+STR0006}     //"Ativo"##"Reabrir"##"Encerrar"
aWS       := {STR0007}      //"Todos"
aMeto     := {STR0007}      //"Todos"
aListMeto := {}

cStatus := aStatus[1]

Do While !(EoF())
	
	nPos1 := Ascan(aWs, TEMP->MF4_ECWS)
	nPos2 := Ascan(aMeto, TEMP->MF4_ECMETO)
	
	If (nPos1 = 0)
		aadd(aWs, TEMP->MF4_ECWS)
	Endif
	
	If (nPos2 = 0)
		aadd(aListMeto, TEMP->({MF4_ECWS, MF4_ECMETO}))
	Endif
	
	dbSkip() 
	
Enddo

dbCloseArea()

cWS 	:= aWs[1]
cMeto 	:= aMeto[1]
cFiltro := ""  
dDeDt 	:= CTOD("01/01/2013")
dAtDt 	:= CTOD("31/12/2049")  

aObj := {}

aSizeAut  := MsAdvSize(.T.)

// Serแ utilizado tr๊s แreas na janela
// 1- Enchoice, sendo 80 pontos pixel
// 2- MsGetDados, o que sobrar em pontos pixel ้ para este objeto
// 3- Rodap้ que ้ a pr๓pria janela, sendo 15 pontos pixel

AADD( aObj, { 100, 030, .T., .F. })
AADD( aObj, { 355, 100, .F., .T. })

aInfo := { aSizeAut[1], aSizeAut[2], aSizeAut[3], aSizeAut[4], 3, 3 }

aPObj := MsObjSize( aInfo, aObj)

LJ860Filtra(@oDlg, @oCbx1, @oBrowse, cStatus, ;
			cWs, 	cMeto,	dDeDt,	dAtDt,;
			cEcvChv) 

DEFINE MSDIALOG oDlg TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
    
	aPObj2 := MsObjSize( aInfo, aObj, .T., .T.)

	oPanel:= tPanel():New(aPObj[1,1], aPObj[1,2], "", oDlg,,,,,RGB(nCor,nCor,nCor), (aPObj[1,4]-aPObj[1,2]), (aPObj[1,3]-aPObj[1,1]),.T.,.F.)	
	
	@004,001  SAY STR0008	 SIZE 30, 09 OF oPanel PIXEL      //"FILTROS:"
	@004,045  SAY STR0009    SIZE 30, 09 OF oPanel PIXEL      //"STATUS  "
	@004,108  SAY STR0010    SIZE 35, 25 OF oPanel PIXEL      //"WEBSERVICE "
	@004,173  SAY STR0011    SIZE 30, 09 OF oPanel PIXEL      //"METODOS "
	@004,240  SAY STR0012 + " " + STR0013   SIZE 30, 09 OF oPanel PIXEL      //"DATA "
	@012,240  MSGET dDeDt    SIZE 40, 09 OF oPanel PIXEL    
	@004,290  SAY STR0014    SIZE 10, 09 OF oPanel PIXEL      //"Ate: "
	@012,290  MSGET dAtDt    SIZE 40, 09 OF oPanel PIXEL 
	@004,340   SAY STR0035    SIZE 100,09 OF oPanel PIXEL     //"CHAVE Interna"
	@012,340   MSGET cEcvChv     SIZE 100,09 OF oPanel PIXEL  
	

	oSButton := SButton():New( 015,450,17,{|x| LJ860Filtra(@oDlg, @oCbx1, @oBrowse, cStatus, cWs, cMeto,dDeDt,dAtDt, cEcvChv)},oDlg,.T.,,) 
	
	oCbs := TComboBox():New( 015,045,{|u| if( Pcount( )>0, cStatus:= u, cStatus )},aStatus,050,017,oDlg,,{|x| LJ860Filtra(@oDlg, @oCbx1, @oBrowse, cStatus, cWs, cMeto,dDeDt,dAtDt, cEcvChv)},,,,.T.,,,,,,,,,"cStatus")
	oCbx := TComboBox():New( 015,110,{|u| if( Pcount( )>0, cWs:= u, cWs )},aWs,050,026,oDlg,,{|x| LJ860MdaCbx(@oDlg, cWs, @oCbx1, aListmeto)},,,,.T.,,,,,,,,,"cWs")
	oCbx1:= TComboBox():New( 015,175,{|u| if( Pcount( )>0, cMeto:= u, cMeto )},aMeto,050,026,oDlg,,{|x| LJ860Filtra(@oDlg, @oCbx1, @oBrowse, cStatus, cWs, cMeto,dDeDt,dAtDt, cEcvChv)},,,,.T.,,,,,,,,,"cMeto")
			
	oBrowse := BrGetDDB():New( aPObj[2,1],aPObj[2,2],(aPObj[1,4]-aPObj[1,2]),(aPObj[2,3] - aPObj[2,1]),,,,oDlg,,,,,{|x| LJ860Detalhe(aStatus)},,,,,,,.F.,"MF4",.T.,,.F.,,, )
	oBrowse:AddColumn( TCColumn():New(STR0015    ,{||MF4->MF4_FILIAL },"@!",,,"LEFT",,,.F.,,,,,))        //"Filial"
	oBrowse:AddColumn( TCColumn():New(STR0016    ,{||MF4->MF4_ECFLAG },"@!(1)",,,"LEFT",,,.F.,,,,,))     //"Status"
	oBrowse:AddColumn( TCColumn():New(STR0017    ,{||MF4->MF4_ECWS },"@!(10)",,,"LEFT",,,.F.,,,,,))      //"WebService"
	oBrowse:AddColumn( TCColumn():New(STR0018    ,{||MF4->MF4_ECMETO },"@!(10)",,,"LEFT",,,.F.,,,,,))    //"Metodo"
	oBrowse:AddColumn( TCColumn():New(STR0019    ,{||MF4->MF4_ECDATA },,,,"LEFT",,,.F.,,,,,))            //"Data"
	oBrowse:AddColumn( TCColumn():New(STR0020    ,{||MF4->MF4_ECHORA },,,,"LEFT",,,.F.,,,,,))            //"Hora"
	oBrowse:AddColumn( TCColumn():New(STR0036   ,{|| aRet:={"",""}, aRet := GetAdvFVal('MF3', {'MF3_ECVCHV', 'MF3_ECCCHV' },  xFilial('MF3') + MF4->MF4_ECREFE ,1, {"",""} ), aRet[1] },,,,"LEFT",,,.F.,,,,,))            //"Chave Interna"
	oBrowse:AddColumn( TCColumn():New(STR0037   ,{|| aRet[2] },,,,"LEFT",,,.F.,,,,,))            //"Expressใo da Chave"


ACTIVATE MSDIALOG oDLG ON INIT EnchoiceBar(oDlg,{|| nOpcA := 1, oDlg:End()},{||oDlg:End()},,,,)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJ860MdaCbxบAutor  ณMicrosiga           บ Data ณ  01/31/13   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que retorna a lista de metodos do webservice.         บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oDLG  = Objeto do dialogo ativo                             บฑฑ
ฑฑบ          ณ cWS   = WebService do parametro de filtragem.               บฑฑ
ฑฑบ          ณ oCbx1 = Combobox que ira receber os metodos do webservice.  บฑฑ
ฑฑบ          ณ aListmeto = Vetor com todos os metodos dos registros de Log.บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function LJ860MdaCbx(oDLG, cWs, oCbx1, aListmeto)

Local aMeto := {STR0007}    //"Todos"  //vetor com os metodos do webservice passado no parametro.
Local nx    := 0                       //Contado do comando For.

Default oDLG      := Nil
Default cWS       := ""
Default oCbx1     := Nil
Default aListmeto := {}


For nx := 1 to Len(aListmeto)
	If Alltrim(aListmeto[nx][1]) == Alltrim(cWs)
		aadd(aMeto, aListmeto[nx][2])
	Endif
Next
                  
If  (oDLG <> Nil)
	oCbx1:SetItems(aMeto)
	oCbx1:Refresh()
	oDLG:Refresh()
EndIf	

return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJ860FiltraบAutor  ณMicrosiga           บ Data ณ  01/31/13   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que monta a condicao de filtro e processa o filtro.   บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oDLG  = Objeto do dialogo ativo                             บฑฑ
ฑฑบ          ณ oCbx1 = Combobox que ira receber os metodos do webservice.  บฑฑ
ฑฑบ          ณ oBrowse = Objeto do browse do dialogo.                      บฑฑ
ฑฑบ          ณ cStatus = Status do parametro de filtragem.                 บฑฑ
ฑฑบ          ณ cWS     = WebService do parametro de filtragem.             บฑฑ
ฑฑบ          ณ cMeto   = Metodo do parametro de filtragem.                 บฑฑ
ฑฑบ          ณ dDeDt   = Data inicial do parametro de filtragem.           บฑฑ
ฑฑบ          ณ dAtDt   = Data final do parametro de filtragem.             บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function LJ860Filtra(oDlg, oCbx1, oBrowse, cStatus, ;
							cWs, cMeto, dDeDt, dAtDt,;
							cEcvChv)

Local cFiltro := ""  //Condicao do filtro
Local aRet		:= {} 
Local aAreaMF3	:= MF3->(GetArea())
Local aArea		:= GetArea()


Default oDlg    := Nil
Default oCbx1   := Nil
Default oBrowse := Nil
Default cStatus := ""
Default cWs     := ""
Default cMeto   := ""
Default dDeDt   := CtoD(space(8))
Default dAtDt   := CtoD(space(8))
Default cEcvChv := ""      

dbSelectArea("MF4")
dbSetOrder(2)

If  (Upper(cWs) == Upper(AllTrim(STR0007))) .And. (Upper(cMeto) == Upper(AllTrim(STR0007)))    //"Todos"
	cFiltro := "MF4_ECFLAG == '"+SubStr(cStatus,1,1)+"'"
EndIf

If  (Upper(cWs) <> Upper(AllTrim(STR0007))) .And. (Upper(cMeto) == Upper(AllTrim(STR0007)))    //"Todos"
	cFiltro := "MF4_ECFLAG == '"+SubStr(cStatus,1,1)+"' .AND. MF4_ECWS = '"+cWs+"'"
EndIf
    
If  (Upper(cWs) == Upper(AllTrim(STR0007))) .And. (Upper(cMeto) <> Upper(AllTrim(STR0007)))    //"Todos"
	cFiltro := "MF4_ECFLAG == '"+SubStr(cStatus,1,1)+"' .AND. MF4_ECMETO = '"+cMeto+"'"
EndIf

If  (Upper(cWs) <> Upper(AllTrim(STR0007))) .And. (Upper(cMeto) <> Upper(AllTrim(STR0007)))    //"Todos"
	cFiltro := "MF4_ECFLAG == '"+SubStr(cStatus,1,1)+"' .AND. MF4_ECWS = '"+cWs+"' .AND. MF4_ECMETO = '"+cMeto+"'"
EndIf

If  !( Empty(dDeDt) ) .And. !( Empty(dAtDt) )
    cFiltro += " .AND. DTOS(MF4_ECDATA) >= '"+DTOS(dDeDt)+"' .AND. DTOS(MF4_ECDATA) <= '"+DTOS(dAtDt)+"'"
EndIf 

If !Empty(Left(cStatus,1))  .AND. Left(cStatus,1) <> "Z"
	If !Empty(cFiltro)
		cFiltro += " .AND. "
	EndIf
	cFiltro +=  "  ( aRet := {'',''}, aRet := GetAdvFVal('MF3', {'MF3_ECFLAG', 'MF3_ECVCHV'},  xFilial('MF3') + MF4->MF4_ECREFE ,1, {'',''} ), aRet[1]  == '" + IIf(Left(cStatus,1) == "A", "E", "A") + "') "
	If !Empty(cEcvChv)
		cFiltro += " .AND. RTrim(aRet[2]) ='" + RTrim(cEcvChv) + "'"
	EndIf
ElseIf !Empty(cEcvChv)

	If !Empty(cFiltro)
		cFiltro += " .AND. "
	EndIf
	cFiltro +=  " GetAdvFVal('MF3',  'MF3_ECVCHV',  xFilial('MF3') + MF4->MF4_ECREFE ,1, '' ) == '" + RTrim(cEcvChv) + "' "
	
	
EndIf

SET FILTER TO &(cFiltro)
DbGotop()
                                 
If  oDLG <> NIL .AND. oBrowse <> NIL
	oBrowse:refresh()
	oDLG:Refresh()   
EndIf  

RestArea(aAreaMF3)
RestArea(aArea)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJ860DetalheบAutor  ณMicrosiga           บ Data ณ  01/31/13   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que apresenta os dados do registro de Log.             บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ aStatus  = Lista de status permitidos para o registro de Log.บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function LJ860Detalhe(aStatus)

Local nA                                //Contador para o comando For.
Local oDlg1                             //Objeto de dialogo
Local aAreaMF4	:= MF4->(GetArea())    //Salva a area para o MF4
Local cStatus	:= MF4->MF4_ECFLAG     //Obtem o Status do registro de Log.
Local cSeq		:= MF4->MF4_ECSEQ      //Obtem o codigo sequencial do registro de Log.
Local cRef		:= MF4->MF4_ECREFE     //Obtem a referencia da tabela intermediaria.
Local cWs		:= MF4->MF4_ECWS       //Obtem o webservice do registro de Log. 
Local cOrd		:= MF4->MF4_ECORD      //Obtem a ordem do registro de Log. 
Local cMetWs	:= MF4->MF4_ECMETO     //Obtem o metodo do registro de Log. 
Local cData		:= MF4->MF4_ECDATA     //Obtem a data do registro de Log. 
Local cHora		:= MF4->MF4_ECHORA     //Obtem a hora do registro de Log. 
Local cDetalhe	:= MF4->MF4_ECMENS     //Obtem a mensagem de erro do registro de Log. 
Local cJob		:= MF4->MF4_ECJOB      //Obtem Job que gerou o registro de Log. 
Local cSoldt	:= MF4->MF4_ECDTS      //Obtem a data da solucao do registro de Log. 
Local cSolHr	:= MF4->MF4_ECHRS      //Obtem a hora da solucao do registro de Log. 
Local cUser		:= MF4->MF4_ECUSER     //Obtem o usuario da solucao do registro de Log. 
Local nOpcA     := 0                   //Variavel de confirmacao de gravacao
Local cAlias    := ""                  //Alias do cadastro do Protheus que gerou o registro de Log.
Local nRecno    := 0                   //Numero do registro do alias do cadastro do Protheus que gerou o registro de Log.
Local lAchou    := .F.                 //variavel que indica se o registro da tabela intermediaria foi encontrado.

If  !( Empty(MF4->MF4_ECREFE) )
	MF3->( DbSetOrder(1) ) //MF3_FILIAL+MF3_ECSEQ
	
	If  MF3->( DbSeek(xFilial("MF3")+MF4->MF4_ECREFE) .And. !(Empty(MF3_ECVCHV)) )
		lAchou := .T.
		cDetalhe := STR0021 + Alltrim(MF3->MF3_ECCCHV) + ": " + Alltrim(MF3->MF3_ECVCHV) + CRLF + CRLF + cDetalhe   //"Chave: "
	EndIf	
EndIf

If  !( lAchou ) .And. !( Empty(MF4->MF4_ECCHAV) )

	cAlias := Left(MF4->MF4_ECCHAV,3)
	nRecno := Val(SubStr(MF4->MF4_ECCHAV,4))
	
	(cAlias)->( DbGoTo(nRecno) )
	
	SIX->( DbSetOrder(1) )
	SIX->( DbSeek(cAlias) )
	
	cDetalhe := STR0021 + Alltrim(SIX->CHAVE) + ": " + Alltrim((cAlias)->(&(Alltrim(SIX->CHAVE)))) + CRLF + CRLF + cDetalhe    //"Chave: "
	
EndIf

For nA := 1 to Len(aStatus)
    If  (Left(aStatus[nA],1) == cStatus)
    	cStatus := aStatus[nA]
    EndIf
Next nA

DEFINE MSDIALOG oDlg1 TITLE STR0022 Style DS_MODALFRAME FROM 0,0 TO 490,585 OF oMainWnd PIXEL      //"Detalhe do LOG"
 
oDlg1:lEscClose:=.F.

@010,010 Say STR0023 Size 30, 09 Of oDlg1 Pixel      //"Status:"
@009,030 ComboBox oCombo Var cStatus Items aStatus Size 45, 09 Of oDlg1 Pixel

@010,080 Say STR0024 Size 30,09 Of oDlg1 Pixel           //"Ordem:"
@009,100 MsGet cOrd When .F. Size 15,09 Of oDlg1 Pixel 
@010,120 Say STR0025 Size 30,09 Of oDlg1 Pixel           //"Sequencial:"
@009,150 MsGet cSeq When .F. Size 50,09 Of oDlg1 Pixel 
@010,205 Say STR0026 Size 30,09 Of oDlg1 Pixel           //"Referencia:"
@009,235 MsGet cRef When .F. Size 50,09 Of oDlg1 Pixel 

@035,010 Say STR0027 Size 40,09 Of oDlg1 Pixel           //"WebService:"
@034,042 MsGet cWs When .F. Size 110,09 Of oDlg1 Pixel  
@035,153 Say STR0028 Size 40,09 Of oDlg1 Pixel           //"Metodo:"
@034,175 MsGet cMetWs When .F. Size 110,09 Of oDlg1 Pixel

@060,010 Say STR0029 Size 30,09 Of oDlg1 Pixel           //"Data:"
@059,025 MsGet cData When .F. Size 40,09 Of oDlg1 Pixel 
@060,075 Say STR0030 Size 30,09 Of oDlg1 Pixel           //"Hora:"
@059,090 MsGet cHora When .F. Size 30,09 Of oDlg1 Pixel
@060,130 Say STR0031 Size 20,09 Of oDlg1 Pixel           //"Job:"
@059,145 MsGet cJob When .F. Size 130,09 Of oDlg1 Pixel    

@080,010 TO 115,285 LABEL STR0033 OF oDlg1 PIXEL         //"Solu็ใo"
@095,015 Say STR0029 Size 30,09 Of oDlg1 Pixel           //"Data:"
@094,030 MsGet cSoldt When .F. Size 40,09 Of oDlg1 Pixel 
@095,080 Say STR0030 Size 30,09 Of oDlg1 Pixel           //"Hora:"
@094,095 MsGet cSolHr When .F. Size 30,09 Of oDlg1 Pixel
@095,135 Say STR0033 Size 30,09 Of oDlg1 Pixel           //"Usuแrio:"
@094,158 MsGet cUser When .F. Size 120,09 Of oDlg1 Pixel

oTMultiget1 := tMultiget():new(125,010, {| u | If( PCount() > 0, cDetalhe := u, cDetalhe ) }, oDlg1, 275,100, , , , , , .T. )

ACTIVATE MSDIALOG oDlg1 CENTER ON INIT EnchoiceBar(oDlg1,{|| nOpcA := 1, IIF(LJ860ECMATU(oDlg1,cStatus,nOpcA),oDlg1:End(),NIL)},{||oDlg1:End()},,,,)
                                  
RestArea(aAreaMF4)

Return       

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJ860ECMATU บAutor  ณMicrosiga           บ Data ณ  01/31/13   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que grava a alteracao de status no registro de Log.    บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oDLG1  = Objeto do dialogo ativo                             บฑฑ
ฑฑบ          ณ cStatus = Status alterado pelo usuario.                      บฑฑ
ฑฑบ          ณ cSeq    = WebService do parametro de filtragem.              บฑฑ
ฑฑบ          ณ nOpcA   = Variavel com a confirmacao de gravacao.            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function LJ860ECMATU(oDlg1, cStatus, nOpcA)
 
Local lRet   := .F.              //Retorno da funcao
Local cOrig  := MF4->MF4_ECFLAG  //Status inicial do registro de Log.
Local cUser  := __cUserID        //Codigo do Usuario que ira mudar o Status do registro de Log.
Local cNomUs := ""               //Nome do Usuario que ira mudar o Status do registro de Log.

Default oDlg1   := Nil
Default cStatus := ""
Default nOpcA   := 0

If  (cOrig != 'A')
	Alert(STR0034)      //"Nใo pode alterar log com Status diferente de Ativo!"
    Return .F.
EndIf    

PswOrder(2)
If PswSeek(alltrim(cUser))
	  cNomUs := PswRet(1)[1][2] 
EndIf
 
If  (nOpcA == 1)

    lRet := .T.

	If  (Left(cStatus,1) <> cOrig)
	    If !Empty(MF4->MF4_ECREFE)
			MF3->( DbSetOrder(1) ) //MF3_FILIAL+MF3_ECSEQ
			If  MF3->(DbSeek(xFilial("MF3")+MF4->MF4_ECREFE) .And. SoftLock("MF3") )
				MF3->MF3_ECFLAG := If(Left(cStatus,1)=="X", "A", Left(cStatus,1))  ////Caso escolha X-Reabrir ira voltar o Status para A para reprocessar.
	    		MF3->( MsUnLock() )
	    	Else
	       		lRet := .F.		
	   		EndIf
	   	EndIf	
   		If lRet
    		RecLock("MF4",.F.)
    		MF4->MF4_ECFLAG := Left(cStatus,1) //Caso escolha X-Reabrir ira voltar o Status para A para reprocessar.
    		MF4->MF4_ECDTS	:= Date()
			MF4->MF4_ECHRS	:= Time()
			MF4->MF4_ECUSER	:= cUser+" - "+cNomUs
    		MsUnLock()
        EndIf    
    EndIf
EndIf
          
If  (oDlg1 <> Nil)
	oDlg1:Refresh()
EndIf	

Return lRet