#INCLUDE "PROTHEUS.CH"
#include "fwmvcdef.ch"
#INCLUDE "APWIZARD.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "TOTVS.CH"

Static oArqTemp  := NIL
Static oArqTemp2 := Nil

Static lAG870AA8 := ExistBlock("AG870AA8") //Ponto de Entrada para adicionar clausulas no select que traz os Lotes para selecionar.
Static lAG870AA9 := ExistBlock("AG870AA9") //Ponto de Entrada para tratamento de visualização dos lotes na tela de seleção de lotes conforme filtros
Static lAG87Dire := (TableInDic('ND5') .AND. TableInDic('ND6')) //Variavel para validar se a estrutura de Direcionamento já encontra-se na base
//-------------------------------------------------------------------
/*/{Protheus.doc} AGRA870A
Executa a tela a partir da opção alterar/incluir do AGRA870
Mostra as liberações de pedidos que estão aprovadas e que podem ser 
feitas as liberações de Lotes para agendamento
@author Marcelo R. Ferrari	
@since 20/11/2016
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
Function AGRA870A( cOrdCar, cSeqCar )
	If IsInCallStack("AGRA870")
		AGRA870B(NIL, pOrdCar)
	Else
		AGRA870B(pChave)
	EndIf
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} AGRA870B
Mostra as liberações de pedidos que estão aprovadas e que podem ser 
feitas as liberações de Lotes para agendamento
@author Marcelo R. Ferrari	
@since 20/11/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function AGRA870B( pChave )

	Local bKeyF4   := SetKey(VK_F4)
	Local bKeyF5   := SetKey(VK_F5)

	Local oDlg
	Local oSize
	Local aPos
	Local aNewButton := {}
	Local aRet  := {}
	Local aCarga    := {}
	Local cCct      := "||"
	Local cDriver   := TCGetDB()
	Local oObjOwner := Nil
	Local k	 	 := 0
	Local l 	 := 0
	Local aProp  := Nil
	Local aParOb := Nil
	Local aObj   := Nil
	Local cTp    := ""

	Local bInstr := Nil
	
	Private lChvDAK := FWIsInCallStack("AGRA870C")

	Private aAllObj := {}  //Array que irá conter o conjunto de instruções para adicionar o TSAY, TGET e TBUTTON.
	//Cada linha do array corresponde a inclusão de um objeto no painel

	Private nOpcA := -1
	Private oMark
	Private _aMKB       := {}
	Private _acpMKB      := {}

	Private _aMKB2      := {}   //Estrutura da tabela temporária
	Private _acpMKB2     := {}  //Campos das tabelas de origem -> Tabela temporária
	Private _aHeadMKB2 := {}    //Header da tabela temporária
	Private aHeader     := {}   //Array de dados do cabeçalho para msGetDb()

	Private cCadastro := "Seleção de Lotes"   //STR0001
	Private cMarca    := GetMark()
	Private oGetDb
	Private _lChgDocs := .F.	// Indica se houve alteração nos documentos de carga do romaneio
	Private _cAliMKB  := ""
	Private _cAliMKB2 := ""
	Private oPanelB
	Private oPanelE

	Private oSayQtde := Nil
	Private oGetQtde := Nil
	Private oSayLocal:= Nil
	Private oGetLocal:= Nil
	Private oSayEnder:= Nil
	Private oGetEnder:= Nil
	Private oSayLote := Nil
	Private oGetLote := Nil
	Private oSaySLote:= Nil
	Private oGetSLote:= Nil
	Private oSayCultr:= Nil
	Private oGetCultr:= Nil
	Private oSayCltVa:= Nil
	Private oGetCltVa:= Nil
	Private oSayCateg:= Nil
	Private oGetCateg:= Nil
	Private oSayPene := Nil
	Private oGetPene := Nil

	//Campos Editavies  -> {"QTDE","LOCAL","ENDERECO","LOTECT","NMLOTE","CULTRA","CULTVAR","CATEG","PENE"}
	Private _cProdutoLote := ""
	Private _nQtde     := 0

	//Atribui o tamanho das variáveis para inicializar os objetos TGET
	Private _cLocal    := Replicate(" ", TamSx3("NJ6_LOCAL")[1])
	Private _cEndereco := Replicate(" ", TamSx3("NJ6_END")[1])
	Private _cLoteCT   := Replicate(" ", TamSx3("NJ6_LOTECT")[1])
	Private _cNmLote   := Replicate(" ", TamSx3("NJ6_NMLOTE")[1])
	Private _cCultra   := Replicate(" ", TamSx3("NJ6_CULTRA")[1])
	Private _cCultvar  := Replicate(" ", TamSx3("NJ6_CTVAR")[1])
	Private _cCateg    := Replicate(" ", TamSx3("NJ6_CATEG")[1])
	Private _cPene     := Replicate(" ", TamSx3("NJ6_PENE")[1])
	Private _cRese     := Replicate(" ", TamSx3("NJ6_RESERV")[1])
	Private _cGermin   := Replicate(" ", TamSx3("NJ6_GERMIN")[1])
	Private cOrdCar  := Replicate(" ", TamSx3("C9_CARGA")[1]) 
	Private cSeqCar  := Replicate(" ", TamSx3("C9_SEQCAR")[1])

	If cDriver = "MSSQL"
		cCct := "+"  //Caracter de concatenaçao 
	EndIF

	//Busca a Carga 
	aCarga := Agra870aCG(pChave,,lChvDAK)   

	If !(aCarga[1])
		ApMsgAlert("Carga nao Localizada!")	
		Return aCarga
	EndIf

	cOrdCar := aCarga[2]
	cSeqCar := aCarga[3]

	// Obs: este array aRotina foi inserido apenas para permitir o
	// funcionamento das rotinas internas da MSGETDB
	If Type("aRotina") != "A"
		Private aRotina := { { "aRotina Falso", "AxAltera", 0 , 4} }
	Endif	

	SetKey(VK_F4,{|| AGRA870AF4()})
	
	IF lAG87Dire
		SetKey(VK_F5,{|| AGRA870AF5()})
	EndIF
	
	//Cria a estrutura temporária e dos Grid´s
	AGR870ASTT()
	Processa({|lEnd| AGR870AMKB()},"Processando Informações","Aguarde") //STR0002   //STR0003

	CursorWait()   //Define o ponteiro do mouse como ampulheta.
	//Criação da tela
	nProp := 45
	oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ENCHOICE", 100, nProp, .T., .T. ) // Adiciona enchoice
	oSize:lLateral     := .F.  // Calculo vertical	
	oSize:Process() //executa os calculos
	aPos := {oSize:GetDimension("ENCHOICE","LININI"),; 
	oSize:GetDimension("ENCHOICE","COLINI"),;
	oSize:GetDimension("ENCHOICE","XSIZE"),;
	oSize:GetDimension("ENCHOICE","YSIZE")}

	DEFINE MSDIALOG oDlg TITLE cCadastro STYLE DS_MODALFRAME;
	FROM oSize:aWindSize[1],oSize:aWindSize[2] ;
	TO oSize:aWindSize[3],oSize:aWindSize[4] ; 
	Of oMainWnd COLORS 0, 16777215 PIXEL	

	oDlg:lEscClose := .F.

	oPnlCnt := tPanel():New(aPos[1],aPos[2],,oDlg,,,,,,aPos[3],aPos[4],.F.,.F.)
	//----- Painel superior da tela principal -----//

	//----- Splitter para permitir ao usuario movimentar os paineis dos browses -----//	
	oSplitter := tSplitter():New( 0,0,oPnlCnt,80,80,1 ) 
	oSplitter:Align := CONTROL_ALIGN_ALLCLIENT

	oObjOwner := @oSplitter
	//----- Painel superior da tela, para o browse de Liberação de pedidos SC9 -----//
	nWd := 00  //largura
	nHg := 00  //Altura
	oPanelB := TPanel():New(01,01,,oObjOwner,,,,,RGB(67,70,87),nWd,nHg,.F.,.T.)
	oPanelB:Align := CONTROL_ALIGN_TOP

	//----- Painel superior do browse para colocar o titulo -----//
	oPnlBtn:=TPanel():New(00,00,,oPanelB,,,,,RGB(67,70,87),12,12,.F.,.F.)
	oPnlBtn:Align := CONTROL_ALIGN_TOP
	oFont12B := TFont():New('Arial',,-12,,.T.)
	@ 03,14  Say "Selecione Itens Liberados" Of oPnlBtn COLOR CLR_WHITE Pixel font oFont12B  //STR0004 

	//----- Painel lateral do browse para adicionar botoes -----//
	oPnlBtn1:=TPanel():New(00,00,,oPanelB,,,,,RGB(67,70,87),15,15,.F.,.F.)
	oPnlBtn1:Align := CONTROL_ALIGN_LEFT

	//------ Botao para adicionar registros na tabela temporária grid inferior-----//
	oBtnAdd  := TBtnBmp():NewBar("PMSSETADOWN","PMSSETADOWN",,,,{||AGR870AADD()},,oPnlBtn1,,,"",,,,,"")
	oBtnAdd:cToolTip := "Adicionar"     //STR0005
	oBtnAdd:Align    := CONTROL_ALIGN_TOP

	//------ Botao para Filtro do Documento-----//			
	//oBtnFiltro			:= TBtnBmp():NewBar("brw_filtro","brw_filtro",,,,{|| AGR870AFIL()},,oPnlBtn1,,,"",,,,,"")
	//oBtnFiltro:cToolTip := "Filtrar"
	//oBtnFiltro:Align    := CONTROL_ALIGN_TOP

	//Botão para selecionar todos os documentos de carga
	oBtnChk := TBtnBmp():NewBar("CHECKED","CHECKED",,,,{||AGR870ACHK(1)},,oPnlBtn1,,,"",,,,,"")
	oBtnChk:cToolTip := "Marca todos os registros em tela"  //STR0006
	oBtnChk:Align    := CONTROL_ALIGN_TOP

	//Botão para desselecionar todos os documentos de carga
	oBtnDChk := TBtnBmp():NewBar("UNCHECKED","UNCHECKED",,,,{||AGR870ACHK(2)},,oPnlBtn1,,,"",,,,,"")
	oBtnDChk:cToolTip := "Desmarca todos os registros em tela"  //STR0007
	oBtnDChk:Align    := CONTROL_ALIGN_TOP

	//-----Painel inferior com o rodapé---//
	oPanelE := TPanel():New(00,00,,oPanelB,,,,,RGB(67,70,87),12,28,.F.,.F.)
	oPanelE:Align := CONTROL_ALIGN_BOTTOM 

	//-------Campos rodapé painel superior ---------------//

	nLeft := 12

	aAdd(aAllObj, {nil, Nil })
	aAllObj[1][2] :=  {"TSAY", {05, LeftPos(@nLeft,0,0) ,{||"Quant."},oPanelE,,TFont():New('Arial',,-12,,.T.),,,,.T.,CLR_WHITE,CLR_WHITE,100,20 }}
	aAdd(aAllObj, {nil, Nil, _nQtde, "NJ6_QTDE" })
	aAllObj[2][2] := {"TGET", { 15, nLeft           ,bSetGet( aAllObj[2][3] ) ,oPanelE, 40, 08,'999999.999', {||A870aVldSF()} ,,,,,,.T.,,,{|| AGRRETTRUE()} ,,,,.F.,,/*'???'*/ ,"aAllObj[2][3]",,,,,.T.,.T.,'',,,,'' }}//

	aAdd(aAllObj, {nil, Nil })
	aAllObj[3][2] :=  {"TSAY", {05, LeftPos(@nLeft) ,{||"Lote"},oPanelE,,TFont():New('Arial',,-12,,.T.),,,,.T.,CLR_WHITE,CLR_WHITE,100,20} }
	aAdd(aAllObj, {nil, Nil, _cLoteCT, "NJ6_LOTECT" })	
	aAllObj[4][2] :=  {"TGET", {15, nLeft, bSetGet( aAllObj[4][3] ),oPanelE, 60, 08,'@!', {||A870aVldSF()},,CLR_GRAY,,,,.T.,,,{|| !AGRRETTRUE()},,,,.F.,,/*'???'*/ ,'aAllObj[4][3]',,,,,.T.,.T.,'',,,,''} }	

	nLeft := nLeft + 10
	//------ Botao para adicionar registros na tabela temporária grid inferior-----//
	aAdd(aAllObj, {nil, Nil })
	aAllObj[5][2] := {"TBUTTON", ;
	{15, (LeftPos(@nLeft,-10)), "Lote",oPanelE,{||AGRA870AF4()}, 15,10,,,.F.,.T.,.F.,,.F.,,,.F.}, ;
	{ {"cToolTip","Pesquisar Lote"} } }

	nLeft := nLeft - 23
	aAdd(aAllObj, {nil, Nil })
	aAllObj[6][2] :=  {"TSAY", {05, (LeftPos(@nLeft)) ,{||"Local"},oPanelE,,TFont():New('Arial',,-12,,.T.),,,,.T.,CLR_WHITE,CLR_WHITE,100,20 }}
	aAdd(aAllObj, {nil, Nil, _cLocal, "NJ6_LOCAL" })
	aAllObj[7][2] := {"TGET", {15, nLeft           ,bSetGet( aAllObj[7][3] ),oPanelE, 40, 08,'@!', {||A870aVldSF()},,CLR_GRAY,,,,.T.,,,{|| AGRRETTRUE()},,,,.F.,,/*'???'*/ ,"aAllObj[7][3]",,,,,.T.,.T.,'',,,,'' }} 

	aAdd(aAllObj, {nil, Nil })
	aAllObj[8][2] :=  {"TSAY", {05, LeftPos(@nLeft) ,{||"Endereço"},oPanelE,,TFont():New('Arial',,-12,,.T.),,,,.T.,CLR_WHITE,CLR_WHITE,100,20 }}
	aAdd(aAllObj, {nil, Nil, _cEndereco, "NJ6_END" })
	aAllObj[9][2] := {"TGET", {15, nLeft           ,bSetGet( aAllObj[9][3] ),oPanelE, 40, 08,'@!', {||A870aVldSF()},,CLR_GRAY,,,,.T.,,,{|| !AGRRETTRUE()},,,,.F.,,/*'???'*/ ,"aAllObj[9][3]",,,,,.T.,.T.,'',,,,'' }} 

	aAdd(aAllObj, {nil, Nil })
	aAllObj[10][2] :=  {"TSAY", {05, LeftPos(@nLeft) ,{||"Sub-lote"},oPanelE,,TFont():New('Arial',,-12,,.T.),,,,.T.,CLR_WHITE,CLR_WHITE,100,20}}
	aAdd(aAllObj, {nil, "", _cNmLote, "NJ6_NMLOTE" })
	aAllObj[11][2] := {"TGET", {15, nLeft           ,bSetGet( aAllObj[11][3] ),oPanelE, 40, 08,'@!', {||A870aVldSF()},,CLR_GRAY,,,,.T.,,,{|| !AGRRETTRUE()},,,,.F.,,/*'???'*/ ,"aAllObj[11][3]",,,,,.T.,.T.,'',,,,'' }} 

	aAdd(aAllObj, {nil, Nil })
	aAllObj[12][2] :=  {"TSAY", {05, LeftPos(@nLeft) ,{||"Cultura"},oPanelE,,TFont():New('Arial',,-12,,.T.),,,,.T.,CLR_WHITE,CLR_WHITE,100,20 }} //STR0011
	aAdd(aAllObj, {nil, Nil, _cCultra, "NJ6_CULTRA" })
	aAllObj[13][2] := {"TGET", {15, nLeft           ,bSetGet( aAllObj[13][3] ),oPanelE, 40, 08,'@!', {||A870aVldSF()},,CLR_GRAY,,,,.T.,,,{|| !AGRRETTRUE()},,,,.F.,,/*'???'*/ ,"aAllObj[13][3]",,,,,.T.,.T.,'',,,,'' }}

	aAdd(aAllObj, {nil, Nil })
	aAllObj[14][2] :=  {"TSAY", {05, LeftPos(@nLeft) ,{||"Cultivar"},oPanelE,,TFont():New('Arial',,-12,,.T.),,,,.T.,CLR_WHITE,CLR_WHITE,100,20 }}
	aAdd(aAllObj, {nil, Nil, _cCultvar, "NJ6_CTVAR" })
	aAllObj[15][2] := {"TGET", {15, nLeft           ,bSetGet( aAllObj[15][3] ),oPanelE, 40, 08,'@!', {||A870aVldSF()},,CLR_GRAY,,,,.T.,,,{|| !AGRRETTRUE()},,,,.F.,,/*'???'*/ ,"aAllObj[15][3]",,,,,.T.,.T.,'',,,,''}} 

	aAdd(aAllObj, {nil, Nil })
	aAllObj[16][2] :=  {"TSAY", {05, LeftPos(@nLeft) ,{||"Categoria"},oPanelE,,TFont():New('Arial',,-12,,.T.),,,,.T.,CLR_WHITE,CLR_WHITE,100,20 }}
	aAdd(aAllObj, {nil, Nil, _cCateg, "NJ6_CATEG" })
	aAllObj[17][2] := {"TGET", {15, nLeft           ,bSetGet( aAllObj[17][3] ),oPanelE, 40, 08,'@!', {||A870aVldSF()},,CLR_GRAY,,,,.T.,,,{|| !AGRRETTRUE()},,,,.F.,,/*'???'*/ ,"aAllObj[17][3]",,,,,.T.,.T.,'',,,,'' }} 

	aAdd(aAllObj, {nil, Nil })
	aAllObj[18][2] :=  {"TSAY", {05,LeftPos(@nLeft) ,{||"Peneira"},oPanelE,,TFont():New('Arial',,-12,,.T.),,,,.T.,CLR_WHITE,CLR_WHITE,100,20 }}
	aAdd(aAllObj, {nil, Nil, _cPene, "NJ6_PENE" })
	aAllObj[19][2] := {"TGET", {15,nLeft           ,bSetGet( aAllObj[19][3] ),oPanelE, 40, 08,'@!', {||A870aVldSF()},,CLR_GRAY,,,,.T.,,,{|| !AGRRETTRUE()},,,,.F.,,/*'???'*/ ,"aAllObj[19][3]",,,,,.T.,.T.,'',,,,'' }} 

	aAdd(aAllObj, {nil, Nil })
	aAllObj[20][2] :=  {"TSAY", {05,LeftPos(@nLeft) ,{||"Reserva"},oPanelE,,TFont():New('Arial',,-12,,.T.),,,,.T.,CLR_WHITE,CLR_WHITE,100,20 }}
	aAdd(aAllObj, {nil, Nil, _cRese, "NJ6_RESERV" })
	aAllObj[21][2] := {"TGET", {15,nLeft           ,bSetGet( aAllObj[21][3] ),oPanelE, 40, 08,'@!', {||A870aVldSF()},,CLR_GRAY,,,,.T.,,,{|| !AGRRETTRUE()},,,,.F.,,/*'???'*/ ,"aAllObj[21][3]",,,,,.T.,.T.,'',,,,'' }} 

/*Germinacao  By Proj Expedicao----------------------------------------------------- */
	aAdd(aAllObj, {nil, Nil })
	aAllObj[22][2] :=  {"TSAY", {05,LeftPos(@nLeft) ,{||"Germinação"},oPanelE,,TFont():New('Arial',,-12,,.T.),,,,.T.,CLR_WHITE,CLR_WHITE,100,20 }}
	aAdd(aAllObj, {nil, Nil, _cGermin, "NJ6_GERMIN" })
	aAllObj[23][2] := {"TGET", {15,nLeft           ,bSetGet( aAllObj[23][3] ),oPanelE, 40, 08,'999999.999', {||AllwaysTrue()},,CLR_GRAY,,,,.T.,,,{|| !AGRRETTRUE()},,,,.F.,,/*'???'*/ ,"aAllObj[23][3]",,,,,.T.,.T.,'',,,,'' }} 
  //vALID SGL u_agr87sg1

	//INCLUIR PONTO DE ENTRADA PARA PODER ADICIONAR/EDITAR OBJETOS DA TELA
	If ExistBlock("AG870AA7")
		//Cada linha do array deve contar 1 novo objeto da tela
		//O primeiro item do vetor armazena o proprio objeto como retorno da funcao tObj():New()
		//O segundo item do vetor deve conter: o tipo do objeto; todo o conjunto de parâmetros da funcao New() do respectivo objeto;
		//                                     Demais propriedades que podes ser alteradas, do objeto 
		//O terceiro item deve ter o valor inicial da variável. O valor deve conter o comprimento do campo para o objeto tGet.
		//O quarto parâmetro deve ter o nome do campo (NJ6) que está associado ao objeto
		aAllObj := ExecBlock("AG870AA7",.f.,.f.,{aAllObj, @nLeft })
	EndIf     

	//Agora executar a instrucao N x e adicionar os objetos a tela
	For k := 1 to len(aAllObj)
		aObj := aAllObj[k][2]
		cTp := aObj[1]
		aParOb := aObj[2]
		If len(aObj) > 2
			aProp := aObj[3]
		EndIF  

		IF cTp ==  "TSAY"
			aAllObj[k][1] := tSay():New( aParOb[1], aParOb[2], aParOb[3], aParOb[4], aParOb[5], aParOb[6], aParOb[7], aParOb[8], aParOb[9], aParOb[10], aParOb[11], aParOb[12], aParOb[13], aParOb[14])   
		EndIf

		IF cTp ==  "TGET"
			aAllObj[k][1] := tGet():New( aParOb[1], aParOb[2], aParOb[3], aParOb[4], aParOb[5], aParOb[6], aParOb[7], aParOb[8], aParOb[9], aParOb[10], ;
			aParOb[11], aParOb[12], aParOb[13], aParOb[14], aParOb[15], aParOb[16], aParOb[17], aParOb[18], aParOb[19], aParOb[20], ;
			aParOb[21], aParOb[22], aParOb[23], aParOb[24], aParOb[25], aParOb[26], aParOb[27], aParOb[28], aParOb[29], aParOb[30], ;
			aParOb[31], aParOb[32], aParOb[33], aParOb[34])

		EndIf

		IF cTp ==  "TBUTTON"
			aAllObj[k][1] := tButton():New( aParOb[1], aParOb[2], aParOb[3], aParOb[4], aParOb[5], aParOb[6], aParOb[7], aParOb[8], aParOb[9], aParOb[10], aParOb[11], aParOb[12], aParOb[13], aParOb[14])   
		EndIf      

		If !Empty(aProp)
			for l := 1 to len(aProp)
				bInstr := &("{ || aAllObj["+AllTrim(Str(k))+"][1]:"+aProp[l][1]+":='"+aProp[l][2]+"'}") 
				Eval(bInstr)
			Next l
		EndIf

		cTp := ""
		aProp := Nil
		aParOb := Nil
		aObj := Nil
	Next k

	//---------------- Fim do painel superior da tela ------------------//

	//----- Painel inferior da tela, para o browse de documentos relacionados -----//
	oPanelC := TPanel():New(01,01,,oObjOwner,,,,,RGB(127,127,127) /*amarelo*/,0,0,.F.,.T.)
	oPanelC:Align := CONTROL_ALIGN_BOTTOM

	//--------StatusBar onde serão apresentados os valores totais referente aos documentos de carga relacionados--------------------//
	oPanelD := TPanel():New(00,00,,oPanelC,,,,,RGB(67,70,87),12,18,.F.,.F.)
	oPanelD:Align := CONTROL_ALIGN_TOP 
	oSayOrdCar := tSay():New(05,18 ,{||"Ordem Carregamento:"},oPanelD,,TFont():New('Arial',,-12,,.T.),,,,.T.,CLR_WHITE,CLR_WHITE,100,20) //STR0011
	//TGet():New([nRow],[nCol],[ bSetGet ]                            ,[oWnd] ,[nWidth],[nHeight ],[cPict]    ,[bValid]        ,[nClrFore],[nClrBack],[oFont],[uParam12],[uParam13],[lPixel],[uParam15],[uParam16],[bWhen] ,[uParam18],[uParam19],[bChange]                  ,[lReadOnly],[lPassword],[uParam23],[ cReadVar],[uParam25],[uParam26],[uParam27],[lHasButton],[lNoButton],[uParam30],[cLabelText],[nLabelPos],[oLabelFont],[nLabelColor],[cPlaceHold])
	oGetOrdCar := TGet():New(  04,   80   ,bSetGet( cOrdCar ),oPanelD, 50     ,   8                           ,'@!'       ,{||A870aVldSF()},          ,          ,       ,          ,          ,.T.     ,          ,          ,{|| !AGRRETTRUE()},          ,          ,                           ,.F.        ,           ,/*'DAK'*/ ,"cOrdCar"  ,          ,          ,          ,            ,.T.        ,.T.       ,''          ,           ,            ,             ,''          ) 

	oSaySeqCar := tSay():New(05,160 ,{||"Sequencia:"},oPanelD,,TFont():New('Arial',,-12,,.T.),,,,.T.,CLR_WHITE,CLR_WHITE,100,20) //STR0011
	oGetSeqCar := TGet():New(04,160   ,bSetGet( cSeqCar ),oPanelD, 50     ,   8                           ,'@!'       ,{||A870aVldSF()},          ,          ,       ,          ,          ,.T.     ,          ,          ,{|| !AGRRETTRUE()},          ,          ,                           ,.F.        ,           ,/*'DAK'*/ ,"cOrdCar"  ,          ,          ,          ,            ,.T.        ,.T.       ,''          ,           ,            ,             ,''          ) 

	//--------Fim do Statusbar			


	//----- Painel superior do browse de documentos relacionados, para colocar o titulo -----//	
	oPnlBtn3:=TPanel():New(00,00,,oPanelC,,,,,RGB(127,127,127),15,15,.F.,.F.)
	oPnlBtn3:Align := CONTROL_ALIGN_TOP
	oFont12B := TFont():New('Arial',,-12,,.T.)
	@ 03,14  Say "Documentos Relacionados" Of oPnlBtn3 COLOR CLR_WHITE Pixel font oFont12B  //STR0008

	//----- Painel lateral do browse de documentos relacionados, para adicionar botoes -----//
	oPnlBtn2:=TPanel():New(00,00,,oPanelC,,,,,RGB(127,127,127) /*laranja*/,15,0,.F.,.F.)
	oPnlBtn2:Align := CONTROL_ALIGN_LEFT

	//------ Botao para excluir relacionamento do Documento de carga com o romaneio -----//			
	oBtnDel  := TBtnBmp():NewBar("PMSSETAUP","PMSSETAUP",,,,{||AGR870ADEL()},,oPnlBtn2,,,"",,,,,"")
	oBtnDel:cToolTip := "Excluir"    //STR0009
	oBtnDel:Align    := CONTROL_ALIGN_TOP

	//Botão para desselecionar todos os documentos de carga
	oBtnGrv := TBtnBmp():NewBar("SALVAR","SALVAR",,,,{||AGR870AGRV()},,oPnlBtn2,,,"",,,,,"")
	oBtnGrv:cToolTip := "Grava as alterações no registro corrente"   //STR0010
	oBtnGrv:Align    := CONTROL_ALIGN_TOP					

	//----- Painel Direito do browse de documentos relacionados, para colocar o GRID -----//	
	//oPnlGrid:=TPanel():New(00,00,,oPanelC,,,,,RGB(67,70,87),12,12,.F.,.F.)
	nRw := 15   //Linha
	nCl := 15   //Coluna
	nWd := 800  //largura
	nHg := 125  //Altura
	oPnlGrid:=TPanel():New(nRw,nCl,,oPanelC,,,,,RGB(255,255,255),nWd,nHg,.F.,.F.)
	nAl := 5 //CONTROL_ALIGN_CLIENT
	oPnlGrid:Align := nAl
	//--------------- Fim do painel do grid -----------------------//

	//--------------- Fim do painel inferior da tela principal-----------------------//

	//--1----- Seleciona a temp-table de Documentos de cargas que nao foram relacionados ao romaneio e cria o browse -----// 	
	dbSelectArea(_cAliMKB)
	dbSetOrder(01)
	dbGoTop()
	oMark := MsSelect():New(_cAliMKB,"OK",,_aCpMKB,,@cMarca,{0,0,0,0},,,oPanelB)
	oMark:oBrowse:cToolTip := "Seleção de Lotes"    //STR0012
	oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oMark:oBrowse:bLDblClick := {|| AGR870ACLK()}
	
	
	//--------------Fim 1 -- criado o browse---------------//

	//--2----- Seleciona a temp-table de Documentos de cargas que ja foram relacionados ao romaneio e cria o browse -----// 
	dbSelectArea(_cAliMKB2)
	dbSetOrder(01)
	dbGoTop()
	aHeader := _aHeadMKB2
	nFt := 0.36
	//nBt := (oPnlGrid:nClientHEIGHT - 4 ) / 2   // oPnlGrid:NHEIGHT* nFt  //Altura
	nBt := oPnlGrid:NHEIGHT * nFt  //Altura
	nRg := (oPnlGrid:nClientWidth - 4 ) / 2  // oPnlGrid:NWIDTH * nFt + 10  //largura
	oGetDb := MsGetDB():New(0,0,nBt,nRg, ;   //nTop,nLeft,nBottom,nRight,
	/*nOpc*/ 1, ;
	/*cLinhaOk*/"AGR870ALOK", ;
	/*cTudoOk*/"AGR870AAOK", ;
	/*cIniCpos*/"", ;
	/*lDelete*/ .F.,  ;
	/*aAlter*/{},; //{"QTDE","LOCAL","ENDERECO","LOTECT","NMLOTE","CULTRA","CULTVAR","CATEG","PENE"},;
	/*nFreeze*/ , ;
	/*lEmpty*/.F., ;
	/*uPar1*/, ;
	_cAliMKB2, ;
	/*cFieldOk*/, ; 
	/*uPar2*/.F.,;
	/*lAppend*/ .F., ;
	/*oWnd*/ oPnlGrid)
	oGetDB:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	//If cParamF12 == 1 //Exibe tela de filtro antes da abertura do programa
	//	AGR870AFIL()
	//EndIf

	//Alterar o cursor do Mouse para Seta
	CursorArrow()

	//Ponto de entrada para adicionar botões no menu de acoes relacionadas
	If ExistBlock("AG870AA1")
		//Exemplo para aNewButton: Aadd(aNewButton, {"gacimg32", {|| GFEA071BT()}, "Detalhes",  "Detalhes."})
		aNewButton := ExecBlock("AG870AA1",.f.,.f.,{aNewButton})
	EndIf 	    

	//ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(ODlg,{||nOpcA := 1, If(AGR870AAOK(), ODlg:End(), NIL)},{||nOpcA := 0, ODlg:End()},,aNewButton) CENTERED
	///ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(ODlg,{|| IF(Agra870aEx(),ODlg:End(), fTopGrid() ) } ,{||nOpcA := 0, ODlg:End()},,aNewButton) CENTERED
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(ODlg,{|| IF(Agra870aEx(),ODlg:End(), fTopGrid() ) } ,{|| Agr870Canc( oDLG )},,aNewButton) CENTERED

	//Depois de limpar as temp-table é necessário selecionar uma tabela, para que não ocorra erros//
	dbSelectArea("NJ5")
	SetKey(VK_F4, bKeyF4)
	
	IF lAG87Dire
		SetKey(VK_F5, bKeyF5)
	EndIF

	//Elimina a tabela temporária
	AGRDLTPTB(oArqTemp )	
	AGRDLTPTB(oArqTemp2)

	//Variáveis de Retorno
	aAdd(aRet, (nOpcA == 1) )   //<= 0 Fechou a tela sem confirmar; = 1 FEchou a tela com "Confirmar"
	aAdd(aRet, cOrdCar) //Código da Ordem de carregamento gravado.
	aAdd(aRet, cSeqCar) //Código da Ordem de carregamento gravado.

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AGR870AMKB
Acrescenta os registros na tabela temporaria para que eles sejam exibidos na tela
@author Marcelo Ferrari
@since nov/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AGR870AMKB()
	Local cDriver := TCGetDB()
	Local cSqlCompl := ""
	Local cQuery := ""
	Local i := 0
	Local j := 0
	Local aSql := {}  //Array q contém as partes do SQL
	//Sendo o indice 1 para SELECT, 2 para o FROM
	//3 para WHERE, 4 para Group By, 5 para Having
	//e 6 para ORDER/union, etc

	If Select(_cAliMKB) > 0
		dbSelectArea(_cAliMKB)
		ZAP
	EndIf

	If Select(_cAliMKB2) > 0
		dbSelectArea(_cAliMKB2)
		ZAP
	EndIf

	aAdd(aSql, {})
	aAdd(aSql[1], {})

	If cDriver = "MSSQL"
		cSqlCompl := "( SELECT ISNULL( (SELECT SUM(NJ6S.NJ6_QTDE) NJ6_QTDS " 
		cSqlCompl += " FROM " + RetSqlName("NJ6") + " NJ6S "
		cSqlCompl += " WHERE NJ6S.NJ6_FILIAL = C9_FILIAL "
		cSqlCompl += " AND NJ6S.NJ6_NUMPV = C9_PEDIDO "
		cSqlCompl += " AND NJ6S.NJ6_ITEM = C9_ITEM  "
		cSqlCompl += " AND NJ6S.NJ6_SEQUEN = C9_SEQUEN "
		cSqlCompl += " AND NJ6S.NJ6_PRODUT = C9_PRODUTO "
		cSqlCompl += " AND NJ6S.D_E_L_E_T_ = ' ' ) , 0 ) )"
	ElseIf cDriver = "ORACLE"
		cSqlCompl := "( SELECT NVL( (SELECT SUM(NJ6S.NJ6_QTDE) NJ6_QTDS " 
		cSqlCompl += " FROM " + RetSqlName("NJ6") + " NJ6S "
		cSqlCompl += " WHERE NJ6S.NJ6_FILIAL = C9_FILIAL "
		cSqlCompl += " AND NJ6S.NJ6_NUMPV = C9_PEDIDO "
		cSqlCompl += " AND NJ6S.NJ6_ITEM = C9_ITEM  "
		cSqlCompl += " AND NJ6S.NJ6_SEQUEN = C9_SEQUEN "
		cSqlCompl += " AND NJ6S.NJ6_PRODUT = C9_PRODUTO "
		cSqlCompl += " AND NJ6S.D_E_L_E_T_ = ' ' ) , 0 ) FROM DUAL )"
	EndIf 	

	aSql[1][1] := "SELECT DISTINCT C9_OK OK, C9_FILIAL FILPED, C9_CARGA CODCARGA, C9_SEQCAR SEQCAR, C9_PEDIDO PEDIDO, C9_ITEM ITEM, C9_SEQUEN SEQUENCIA,"
	aSql[1][1] += " C9_PRODUTO PRODUTO, C6_UM UM, C9_QTDLIB QTDE, C6_LOCAL LOCAL, SC5.C5_CODSAF SAFRA, C6_CULTRA CULTRA, "
	aSql[1][1] += " C6_CTVAR CULTVAR, C6_CATEG CATEG , C6_PENE PENE, B1_DESC DSPRODUTO, "
	aSql[1][1] += "	SC9.D_E_L_E_T_, SC9.R_E_C_N_O_, SC9.R_E_C_D_E_L_ "
	
	IF lAG87Dire
		aSql[1][1] += ", ( SELECT CASE WHEN REGISTRO >= 1 THEN 'SIM' ELSE 'NAO' END FROM  ( "
        aSql[1][1] += "		SELECT Count(ND5.ND5_PEDIDO) REGISTRO "
		aSql[1][1] += "		FROM " + RetSqlName("ND5") + " ND5 "
		aSql[1][1] += "		INNER JOIN " + RetSqlName("ND6") + " ND6 "
		aSql[1][1] += "		ON ND6.D_E_L_E_T_ = ' '	"					
		aSql[1][1] += "		AND ND6.ND6_FILIAL	= ND5.ND5_FILIAL "	
		aSql[1][1] += "		AND ND6.ND6_PEDIDO	= ND5.ND5_PEDIDO "
		aSql[1][1] += "		AND ND6.ND6_ITEMPV	= ND5.ND5_ITEM "
		aSql[1][1] += "	AND ND6.ND6_CODSAF	= SC5.C5_CODSAF "
		
		aSql[1][1] += "		AND	ND6.ND6_CODIGO	= ND5.ND5_CODIGO "
		aSql[1][1] += "		WHERE "
		aSql[1][1] += "		ND5.D_E_L_E_T_ = ' ' "
		aSql[1][1] += "		AND	ND5.ND5_FILIAL	= '" + FwxFilial('ND5') + "' "
		aSql[1][1] += "		AND ND5.ND5_PEDIDO	= C9_PEDIDO "
		aSql[1][1] += "		AND ND5.ND5_ITEM	= C9_ITEM "
		aSql[1][1] += "		AND ND5.ND5_STATUS	= '1' ) XXX ) "
		aSql[1][1] += " USADIR,'1' DIRECI "
	EndIF
	
	aSql[1][1] += ", ( C9_QTDLIB - " + cSqlCompl + " ) SALDO  "

	//Germinação By Proj Expedicao
	aSql[1][1] += " , " + fGetGerm()
	
	aAdd(aSql, {})
	aAdd(aSql[2], {})
	aSql[2,1] := "FROM " +RetSqlName("SC9") +" SC9 "
	
	aSql[2,1] += "INNER JOIN " +RetSqlName("SC5") +" SC5 ON SC5.D_E_L_E_T_ = ' ' AND SC9.C9_FILIAL = SC5.C5_FILIAL AND C9_PEDIDO = SC5.C5_NUM "

	aSql[2,1] += " INNER JOIN " + RetSqlName("SC6") +" SC6 ON C9_FILIAL = C6_FILIAL AND "
	aSql[2,1] += "  C9_PEDIDO = C6_NUM AND C9_ITEM = C6_ITEM AND C9_PRODUTO = C6_PRODUTO "

	aSql[2,1] += " LEFT JOIN " + RetSqlName("NJ5") +" NJ5 ON C9_FILIAL = NJ5_FILIAL AND "
	aSql[2,1] += " C9_PEDIDO = NJ5_NUMPV AND C9_ITEM = NJ5_ITEM AND " 
	aSql[2,1] += " C9_SEQUEN = NJ5_SEQUEN AND C9_PRODUTO = NJ5_PRODUT "

	aSql[2,1] += " LEFT JOIN " + RetSqlName("NJ6") +" NJ6 ON C9_FILIAL = NJ6_FILIAL AND "
	aSql[2,1] += " C9_PEDIDO = NJ6_NUMPV AND C9_ITEM = NJ6_ITEM AND " 
	aSql[2,1] += " C9_SEQUEN = NJ6_SEQUEN AND C9_PRODUTO = NJ6_PRODUT "

	aSql[2,1] += " LEFT JOIN " + RetSqlName("SB1") +" SB1 ON B1_FILIAL = '" + FwxFilial('SB1') + "' AND "
	aSql[2,1] += " C9_PRODUTO = B1_COD AND SB1.D_E_L_E_T_ = ' '"

	aAdd(aSql, {})
	aAdd(aSql[3], {})

	aSql[3,1] := "WHERE 1=1 "
	aSql[3,1] += " AND SC9.C9_FILIAL = '" + FwxFilial('SC9') + "' "
	aSql[3,1] += " AND SC9.C9_BLCRED = ' ' "
	aSql[3,1] += " AND NJ5.NJ5_STATUS IN ( '2', '3' ) "

	aSql[3,1] += " AND SC9.C9_QTDLIB > " + cSqlCompl
	aSql[3,1] += " AND SC9.D_E_L_E_T_ = ' ' "
	aSql[3,1] += " AND ( ( SC6.D_E_L_E_T_ = ' '   AND SC9.D_E_L_E_T_ = ' '    AND NJ5.D_E_L_E_T_ = ' ' ) "
	aSql[3,1] += " OR ( SC6.D_E_L_E_T_ = ' '   AND SC9.D_E_L_E_T_ = ' '    AND NJ5.D_E_L_E_T_ IS NULL ) "
	aSql[3,1] += " OR ( SC6.D_E_L_E_T_ IS NULL AND SC9.D_E_L_E_T_ IS NULL  AND NJ5.D_E_L_E_T_ IS NULL ) "
	aSql[3,1] += " OR ( SC6.D_E_L_E_T_ = ' '   AND SC9.D_E_L_E_T_ = ' '    AND NJ5.D_E_L_E_T_ = '*' ) "
	aSql[3,1] += " OR ( SC6.D_E_L_E_T_ = ' '   AND SC9.D_E_L_E_T_ = '*'    AND NJ5.D_E_L_E_T_ = '*' ) "
	aSql[3,1] += " OR ( SC6.D_E_L_E_T_ = ' '   AND SC9.D_E_L_E_T_ = '*'    AND NJ5.D_E_L_E_T_ IS NULL ) "
	aSql[3,1] += " ) "

	//FILTRO ORDEM DE CARREGAMENTO
	aSql[3,1] += " AND C9_CARGA = '" + cOrdCar + "' "
	aSql[3,1] += " AND C9_SEQCAR = '" + cSeqCar + "' " 

	//Ponto de entrada para Alteração da consulta SQL
	If ExistBlock("AG870AA2")
		//Exemplo: aSql[1,1] -> "SELECT ..."
		//         aSql[2,1] -> "FROM ..."
		//         aSql[3,1] -> "WHERE ..."
		//         aSql[4,1] -> "GROUP BY ..."
		//         aSql[5,1] -> "HAVING ..."
		//         aSql[6,1] -> "ORDER ..."
		aSql := ExecBlock("AG870AA2",.f.,.f., {aSql} )
	EndIf 	

	For i := 1 to len(aSql)
		If ValType(aSql[i]) = 'A'
			For j := 1 TO Len(aSql[i])
				If !Empty(aSql[i,j])
					cQuery := cQuery + " " + aSql[i,j]
				EndIF
			Next j
		Else
			If !Empty(aSql[i,j])
				cQuery := cQuery + " " + aSql[i]
			EndIF
		EndIf 
	Next i

	If cDriver = "ORACLE"
		cQuery := "SELECT * FROM ( " + cQuery + " ) X1 "
		cQuery += "WHERE X1.CODCARGA = '" + cOrdCar + "' "
		cQuery += "AND X1.SEQCAR = '" + cSeqCar + "' "
	EndIf 

	///EECVIEW(cquery,'consulta')

	//Executa a Query e adiciona os dados
	AGRSql2Trb(cQuery, _aMKB, _cAliMKB, .F.)

	aSql := {}

	aAdd(aSql, {})
	aAdd(aSql[1], {""})

	aSql[1,1] := "SELECT NJ6_SEQLT SEQLT, NJ6_FILIAL FILPED, NJ6_CODCAR CODCAR, "
	If ExistSX3("NJ6_SEQCAR")
		aSql[1,1] += "NJ6_SEQCAR SEQCAR, "
	Else
		aSql[1,1] += "'  ' SEQCAR, "
	EndIf
	aSql[1,1] += "NJ6_NUMPV PEDIDO, NJ6_ITEM ITEM , NJ6_SEQUEN SEQUENCIA, "
	aSql[1,1] += " NJ6_PRODUT PRODUTO, B1_DESC DSPRODUTO, NJ6_UM UM, NJ6_QTDE QTDE, NJ6_RESERV RESERVA, "
	aSql[1,1] += " NJ6_LOCAL LOCAL, NJ6_END ENDERECO, NJ6_LOTECT LOTECT, NJ6_NMLOTE NMLOTE,  "
	aSql[1,1] += " NJ6_CULTRA CULTRA, NJ6_CTVAR CULTVAR, NJ6_CATEG CATEG, NJ6_PENE PENE "

	//GEMINACAO By Proj Expedicao
	aSql[1,1] += " ,NJ6_GERMIN GERMIN"


	aAdd(aSql, {})
	aAdd(aSql[2], {""})
	aSql[2,1] := "FROM " +RetSqlName("NJ6") +" NJ6 "
	aSql[2,1] += " LEFT JOIN " + RetSqlName("SB1") +" SB1 ON B1_FILIAL = '" + FwxFilial('SB1') + "' AND "
	aSql[2,1] += " NJ6_PRODUT = B1_COD AND SB1.D_E_L_E_T_ = ' ' "

	aAdd(aSql, {})
	aAdd(aSql[3], {""})
	aSql[3,1] := " WHERE 1 = 1" 
	//Adicionar condições de relacionamento para liberações que já foram
	//Agendados e/ou realizado montagem da carga
	aSql[3,1] += " AND NJ6.NJ6_FILIAL = '" + FwxFilial('NJ6') + "' "
	aSql[3,1] += " AND NJ6.NJ6_CODCAR = '" + cOrdCar + "' "
	If ExistSX3("NJ6_SEQCAR")
		aSql[3,1] += "AND NJ6_SEQCAR = '" + cSeqCar + "' "
	EndIf

	aSql[3,1] += " AND NJ6.D_E_L_E_T_ = ' ' "

	//Ponto de entrada para Alteração da consulta SQL
	If ExistBlock("AG870AA3")
		//Exemplo: aSql[1,1] -> "SELECT ..."
		//         aSql[2,1] -> "FROM ..."
		//         aSql[3,1] -> "WHERE ..."
		//         aSql[4,1] -> "GROUP BY ..."
		//         aSql[5,1] -> "HAVING ..."
		//         aSql[6,1] -> "ORDER ..."
		aSql := ExecBlock("AG870AA3",.f.,.f., {aSql} )
	EndIf 	
	cQuery := ""
	For i := 1 to len(aSql)
		If ValType(aSql[i]) = 'A'
			For j := 1 TO Len(aSql[i])
				If !Empty(aSql[i,j])
					cQuery := cQuery + " " + aSql[i,j]
				EndIF
			Next j
		Else
			If !Empty(aSql[i,j])
				cQuery := cQuery + " " + aSql[i]
			EndIF
		EndIf 
	Next i

	///EECVIEW(cQuery,'consulta1')
	
	AGRSql2Trb(cQuery, _aMKB2, _cAliMKB2)   

	dbSelectArea(_cAliMKB)
	dbGoTOp()
	If !Empty(oMark)
		oMark:oBrowse:Refresh()
	EndIf

	dbSelectArea(_cAliMKB2)
	dbGoTOp()
	If !Empty(oGetDb)
		oGetDb:ForceRefresh()
	EndIf		

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} AGR870ALOK
Valida a linha e grava os dados alterados do registro corrente na NJ6
@author Marcelo R. Ferrari
@since 20/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function AGR870ALOK()
	Local lvalid := .T.
	local nQtde   := AGR870ASQT(2)
	Local nQtdLib := AGR870AQTDL()
	Local nSaldo  := 0

	nSaldo := nQtdLib - nQtde
	If nSaldo < 0
		//		ApMsgAlert("A quantidade informada não pode ser maior que o saldo disponível para a liberação") //STR0012 / STR0013
		lvalid := .F.
	EndIf 

Return lvalid

//-------------------------------------------------------------------
/*/{Protheus.doc} AGR870AAOK
Valida todas as linhas e grava os dados alterados da NJ6
@author Marcelo R. Ferrari
@since 20/11/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function AGR870AAOK()
	Local lvalid 		:= .T.
	Local aArea 		:= GetArea()
	Local lAG870CONF	:= ExistBlock('AG870CONF')

	If !(IsInCallStack("AGR870AGRV"))
		If !(MsgYesNo('Confirma a seleção de lotes?'))
			Return .F.
		EndIf

		If lAG870CONF
			lRet := ExecBlock('AG870CONF',.F.,.F.,)
			If !lRet
				Return .F.
			Endif
		Endif
	eNDif
	
	//Atualiza os registros da NJ6 com as informações do Grid antes de sair
	DbSelectArea(_cAliMKB2)
	(_cAliMKB2)->(dbgotop())

	DbSelectArea("NJ6")
	NJ6->( dbSetOrder(2) )
	While !(_cAliMKB2)->(Eof())
		//Valida a linha atual antes de confirmar
		If !(AGR870ALOK())
			Return .F.
		EndIf

		NJ6->(dbgotop())
		IF NJ6->( dbSeek( xFilial('NJ6') + (_cAliMKB2)->CODCAR /*cod carregamento*/ + ;
		(_cAliMKB2)->PEDIDO + (_cAliMKB2)->ITEM + (_cAliMKB2)->SEQUENCIA + ;
		(_cAliMKB2)->PRODUTO + (_cAliMKB2)->SEQLT ) )
			RECLOCK("NJ6", .F.)
			NJ6->NJ6_LOTECT  := (_cAliMKB2)->LOTECT
			NJ6->NJ6_QTDE    := (_cAliMKB2)->QTDE
			NJ6->NJ6_LOCAL   := (_cAliMKB2)->LOCAL
			NJ6->NJ6_CULTRA  := (_cAliMKB2)->CULTRA
			NJ6->NJ6_CTVAR   := (_cAliMKB2)->CULTVAR
			NJ6->NJ6_CATEG   := (_cAliMKB2)->CATEG
			NJ6->NJ6_PENE    := (_cAliMKB2)->PENE
			MSUNLOCK()
		EndIf
		(_cAliMKB2)->( dbSkip() )
	EndDo
	
	RestArea(aArea)
Return lvalid


//-------------------------------------------------------------------
/*/{Protheus.doc} AGR870AADD
Adicionar o registro selecionado nas tabelas NJ6
@author Marcelo R. Ferrari
@since 20/11/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function AGR870AADD() 
	Local aTmpArea := GetArea()
	Local nQtde    := 0
	Local nQtdeNJ6 := 0
	Local nSaldo   := 0
	Local lExiste  := .F. 
	Local lReserva := .F.
	Local nQtRec   := 0 
	Local nSaveSx8 := GetSx8Len()
	Local cReserva := ""
	Local lExit    := .F.
	Local k        := 0
	Local lAG870OK := EXISTBLOCK ("AG870OK") 

	//VAlida se os campos estão preenchidos
	If Empty(cOrdCar) 
		ApMsgAlert("O campo Ordem de carregamento precisa ser preenchido")
		Return .F.
	EndIf

	If !Empty( aAllObj[2][1])
		If Empty( aAllObj[2][3])  // _nQtde 
			ApMsgAlert("O campo Quantidade precisa ser preenchido")
			Return .F.
		EndIf
	EndIf

	If !Empty( aAllObj[4][1])
		If Empty( aAllObj[4][3])  //_cLoteCT
			ApMsgAlert("O campo Lote precisa ser preenchido")
			Return .F.
		EndIF
	EndIf


	If !Empty( aAllObj[7][1])
		If Empty( aAllObj[7][3])  // _cLocal
			ApMsgAlert("O campo Local precisa ser preenchido")
			Return .F.
		EndIF
	EndIf

	If (Rastro((_cAlimkb)->PRODUTO ,"S"))
		If !Empty( aAllObj[7][1])
			If ( aAllObj[7][3] == '99')  //_cLocal
				lRet := .F.
				ApMsgAlert("Local de processos não aceito para faturamento")
			EndIf
		EndIf

		If !Empty( aAllObj[9][1])
			If Empty( aAllObj[9][3])  //_cEndereco 
				ApMsgAlert("O campo Endereço precisa ser preenchido")
				Return .F.
			EndIF
		EndIf
	EndIF

	If !Empty( aAllObj[13][1])
		If Empty( aAllObj[13][3])  // _cCultra
			ApMsgAlert("O campo Cultura precisa ser preenchido")
			Return .F.
		EndIF
	EndIf

	If !Empty( aAllObj[15][1])
		If Empty( aAllObj[15][3])  // _cCultvar
			ApMsgAlert("O campo Cultivar precisa ser preenchido")
			Return .F.
		EndIF
	EndIf

	If !Empty( aAllObj[17][1])
		If Empty( aAllObj[17][3]) //_cCateg 
			ApMsgAlert("O campo Categoria precisa ser preenchido")
			Return .F.
		EndIF
	EndIf

	If !Empty( aAllObj[19][1])
		If Empty( aAllObj[19][3])  //_cPene 
			ApMsgAlert("O campo Peneira precisa ser preenchido")
			Return .F.
		EndIF
	EndIf

	dbSelectArea(_cAliMKB)
	(_cAliMKB)->( dbGoTop() )
	While !(_cAliMKB)->( Eof() )
		If (_cAliMKB)->OK == cMarca
			If !(_cProdutoLote == (_cAliMKB)->PRODUTO)
				dbSelectArea(_cAliMKB)
				(_cAliMKB)->( dbSkip() )
				lExiste := .F.
				Loop
			EndIf
			nQtRec++
			dbSelectArea("NJ6")
			NJ6->( dbSetOrder(1) )
			If ( NJ6->( dbSeek( (_cAlimkb)->(FILPED+cOrdCar+cSeqCar+PEDIDO+ITEM ) ) ) )
				While !(NJ6->(Eof()))
					If (_cAlimkb)->(FILPED+cOrdCar+cSeqCar+PEDIDO+ITEM+SEQUENCIA ) = NJ6->(NJ6_FILIAL+NJ6_CODCAR+NJ6_SEQCAR+NJ6_NUMPV+NJ6_ITEM+NJ6_SEQUEN)

						If (NJ6->NJ6_END=aAllObj[9][3]) .AND. (NJ6->NJ6_LOTECT=aAllObj[4][3]) .AND. (NJ6->NJ6_NMLOTE=aAllObj[11][3]) .AND. ;
						(NJ6->NJ6_LOCAL=aAllObj[7][3]) .AND. (NJ6->NJ6_CULTRA=aAllObj[13][3]) .AND. (NJ6->NJ6_CTVAR=aAllObj[15][3]) .AND. ;
						(NJ6->NJ6_CATEG=aAllObj[17][3]) .AND. (NJ6->NJ6_PENE=aAllObj[19][3])

							ApMsgAlert("Já existe um Lote separado com estas configurações")  //STR0014
							lExiste := .T.
							Exit
						EndIF
					Else
						Exit
					EndIf            
					NJ6->(DbSkip())
				End 
			EndIf

			If !lExiste		
				nQtde := AGR870ASQT()
				nSaldo := (_cAlimkb)->QTDE - nQtde

				If aAllObj[2][3] > 0
					If aAllObj[2][3] > nSaldo
						nQtdeNJ6 := nSaldo
					Else
						nQtdeNJ6 := aAllObj[2][3]
					EndIf
				Else
					nQtdeNJ6 := nSaldo 
				EndIf

				//aAllObj[2][3] := nQtdeNJ6
				If lAG870OK
					If !ExecBlock("AG870OK",.F.,.F.)
						Return .F.
					Endif
				Endif

				BEGIN TRANSACTION
					lExit := .F.
					If Empty(_cRese)
						// efetua reserva de faturamento para produto
						//----------------------------
						// Pega um numero de reserva                                          
						//----------------------------
						cReserva := GetSx8Num("SC0","C0_NUM")
						While (GetSX8Len() > nSaveSx8)
							ConfirmSx8()
							dbSkip()
						End

						//-------------------------
						// Efetua a Reserva
						//-------------------------

						lReserva := a430Reserv({1,"CL",POSICIONE("SC5", 1, FWXFILIAL("SC5") + (_cAlimkb)->PEDIDO, "C5_CLIENTE"),UsrRetName(__cUserId),FWXFILIAL("SC0")},;
						cReserva,(_cAlimkb)->PRODUTO,aAllObj[7][3], nQtdeNJ6 /*aAllObj[2][3]*/,{"", aAllObj[4][3], aAllObj[9][3], ""})  
					Endif
					//-------------------------------
					// Se o retorno for ok, atualiza
					//-------------------------------
					If !lReserva
						MsgInfo("Reserva do lote não pôde ser efetuada, Favor averiguar Lote: " + aAllObj[4][3] +" - Produto: " + (_cAlimkb)->PRODUTO) //Aviso #"Reserva do lote não pôde ser efetuada.")
						//Help(,, "Aviso",,"Reserva do lote não pôde ser efetuada, Favor averiguar Lote: " + _cLoteCT +" - Produto: " + (_cAlimkb)->PRODUTO, 1, 0 ) //Aviso #"Reserva do lote não pôde ser efetuada."
						DisarmTransaction()
						Break
						lExit := .T.							
					Else

						RecLock("NJ6", .T.)
						NJ6->NJ6_FILIAL  := xFilial('NJ6')
						NJ6->NJ6_CODCAR  := cOrdCar
						IF ExistSX3("NJ6_SEQCAR")
							NJ6->NJ6_SEQCAR  := cSeqCar
						EndIF
						NJ6->NJ6_NUMPV   := (_cAlimkb)->PEDIDO
						NJ6->NJ6_ITEM    := (_cAlimkb)->ITEM
						NJ6->NJ6_SEQUEN  := (_cAlimkb)->SEQUENCIA
						NJ6->NJ6_PRODUT  := (_cAlimkb)->PRODUTO
						NJ6->NJ6_SEQLT   := AGR870ASLT()
						NJ6->NJ6_UM      := (_cAlimkb)->UM
						NJ6->NJ6_RESERV  := IIF(Empty(_cRESE),cReserva,_cRESE)
						NJ6->NJ6_AUTRES  := IIF(Empty(_cRESE),.T.,.F.) //verifica se ja tinha reserva para o lote

						For k := 1 to Len(aAllObj)
							If (aAllObj[k][2][1] = "TGET") .AND. (!Empty( aAllObj[k]))
								If ValType(aAllObj[k][3]) = 'N'
									if aAllObj[k][4] == "NJ6_QTDE"
										bInstr := &("{|| NJ6->"+aAllObj[k][4]+":="+STR(nQtdeNJ6)+"}" )
									elseIf aAllObj[k][4] == "NJ6_RESERV"
										//NÃO FAZ NADA POIS A RESERVA JÁ FOI PERSISTIDA ACIMA. 
										//PORTANTO, CASO O CAMPO ESTEJA EM BRANCO, ELE SOBREPOE O QUE FOI PERSISTIDO ACIMA.
									else 
										bInstr := &("{|| NJ6->"+aAllObj[k][4]+":="+STR(aAllObj[k][3])+"}" )
									endIf					    
								Else
									bInstr := &("{|| NJ6->" + aAllObj[k][4] + ":='" + AllTrim(aAllObj[k][3]) + "' }")
								EndIf
								Eval(bInstr)
							EndIf
						Next k

						NJ6->NJ6_RESERV  := IIF(Empty(_cRESE),cReserva,_cRESE)

						NJ6->(MsUnLock())
					EndIF
				END TRANSACTION

				aAllObj[2][3] -= nQtdeNJ6
			EndIf
			If lExit 
				Exit
			EndIF
			lExiste := .F.
		EndIf
		dbSelectArea(_cAliMKB)
		(_cAliMKB)->( dbSkip() )		
	EndDo

	If nQtRec == 0
		ApMsgAlert("Nenhum registro foi marcado para seleção de lotes")  //STR0014
	EndIf

	RestArea(aTmpArea)
	AGR870AMKB()
	If AllTrim((_cAliMKB)->( IndexKey() )) == "OK"
		(_cAliMKB)->( dbSetOrder(1) )
	EndIf 
	
	AGR870AGRV()
	
	//Limpa os campos de inclusão para grid da NP6
	IF nQtRec > 0
		For k := 1 to Len(aAllObj)
			If (aAllObj[k][2][1] = "TGET") .AND. (!Empty( aAllObj[k]))
				If ValType(aAllObj[k][3]) = 'N'
					aAllObj[k][3] := 0
				ElseIF ValType(aAllObj[k][3]) = 'D'
					aAllObj[k][3] := CTOD("//")
				ElseIF ValType(aAllObj[k][3]) = 'C'
					aAllObj[k][3] := ""
				EndIF
			EndIF
		Next k 
	EndIF
	
Return .T.  

//-------------------------------------------------------------------
/*/{Protheus.doc} AGR870ADEL
Monta o filtro para executar a função de deletar a NJ6
@author Marcelo R. Ferrari
@since 20/11/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AGR870ADEL()
	Local aFiltro  := {} 

	aAdd(aFiltro, FwxFilial("NJ6"))
	aAdd(aFiltro, PADL((_cAliMKB2)->CODCAR, TAMSX3("NJ6_CODCAR")[1], " "))
	aAdd(aFiltro, PADL((_cAliMKB2)->SEQCAR, TAMSX3("NJ6_SEQCAR")[1], " "))
	aAdd(aFiltro, PADL((_cAliMKB2)->PEDIDO, TAMSX3("NJ6_NUMPV")[1], " "))
	aAdd(aFiltro, PADL((_cAliMKB2)->ITEM, TAMSX3("NJ6_ITEM")[1], " "))
	aAdd(aFiltro, PADL((_cAliMKB2)->SEQUENCIA, TAMSX3("NJ6_SEQUEN")[1], " "))
	aAdd(aFiltro, PADL((_cAliMKB2)->PRODUTO, TAMSX3("NJ6_PRODUT")[1], " "))
	aAdd(aFiltro, PADL((_cAliMKB2)->SEQLT, TAMSX3("NJ6_SEQLT")[1], " "))

	lRet := Agr870ADE2(aFiltro)

Return lRet           

//-------------------------------------------------------------------
/*/{Protheus.doc} AGR870ADEL
Elimina a linha na tabela de seleção de lotes NJ6
@author Marcelo R. Ferrari
@since 20/11/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function Agr870ADE2(aChaveNJ6, lExibe)
	///Local aTmpArea := GetArea()
	Local lRet     := .T. 
	Local cFiltro  := ""
	Local lExiste  := .F.
	Local lExclui  := .F.

	Default lExibe := .T.

	cFiltro := PADL(aChaveNJ6[1], TAMSX3("NJ6_FILIAL")[1], " ") + ;
	PADL(aChaveNJ6[2], TAMSX3("NJ6_CODCAR")[1], " ") + ;
	PADL(aChaveNJ6[3], TAMSX3("NJ6_SEQCAR")[1], " ") + ;
	PADL(aChaveNJ6[4], TAMSX3("NJ6_NUMPV")[1], " ") + ;
	PADL(aChaveNJ6[5], TAMSX3("NJ6_ITEM")[1], " ") + ;
	PADL(aChaveNJ6[6], TAMSX3("NJ6_SEQUEN")[1], " ") + ;
	PADL(aChaveNJ6[7], TAMSX3("NJ6_PRODUT")[1], " ") + ;
	PADL(aChaveNJ6[8], TAMSX3("NJ6_SEQLT")[1], " ")  

dbSelectArea("NJ6")
	NJ6->(DbGoTop())
	NJ6->(dbSetOrder(1))
	If NJ6->(MsSeek( cFiltro )) 
		If !(NJ6->NJ6_STATUS = 'C') 
			lExiste := AGRIFDBSEEK("SC0",(NJ6->NJ6_RESERV + NJ6->NJ6_PRODUT + NJ6->NJ6_LOCAL),1,.F.) 
			if lExiste .and. NJ6->NJ6_AUTRES == .T.
				//Desfaz a reserva de faturamento
				BEGIN TRANSACTION 
					lExclui := a430Reserv({3,SC0->C0_TIPO,SC0->C0_DOCRES,SC0->C0_SOLICIT,SC0->C0_FILRES},SC0->C0_NUM,SC0->C0_PRODUTO,SC0->C0_LOCAL,SC0->C0_QUANT,;
					{SC0->C0_NUMLOTE,SC0->C0_LOTECTL,SC0->C0_LOCALIZ,SC0->C0_NUMSERI})
					If !(lExclui)	
						Help(,, "Aviso",,"Reserva do lote n?o pôde ser excluida, Favor averiguar Lote: " + aAllObj[4][3] +" - Produto: " + (_cAlimkb)->PRODUTO, 1, 0 ) //Aviso #"Reserva do lote n?o pôde ser efetuada."
						lRet := .F.
					Else
						RecLock("NJ6", .F.)
						dbDelete()
						MsUnLock()		
					EndIf
				END TRANSACTION               
				If lExibe 
					AGR870AMKB()
					If AllTrim((_cAliMKB)->( IndexKey() )) == "OK"
						(_cAliMKB)->( dbSetOrder(1) )
					EndIf
				EndIF
			ElseIf lExiste .and. NJ6->NJ6_AUTRES == .F.
					//Desfaz apenas a seleç?o de Lotes(NJ6)
				If NJ6->NJ6_AUTRES == .T.
					BEGIN TRANSACTION 
						RecLock("NJ6", .F.)
						dbDelete()
						MsUnLock()		
					END TRANSACTION  
				EndIf             
				If lExibe 
					AGR870AMKB()
					If AllTrim((_cAliMKB)->( IndexKey() )) == "OK"
						(_cAliMKB)->( dbSetOrder(1) )
					EndIf
				EndIF
			Else
				//Help(,, "Aviso",,"Reserva do lote n?o pôde ser encontrada." , 1, 0 )
				MsgAlert("Aviso - Reserva do lote n?o pôde ser encontrada.")
				lRet := .F.
			Endif
		Else
			MsgAlert("Aviso - Seleç?o de Lotes ja Confirmada")
			//Help(,, "Aviso",,"Seleç?o de Lotes ja Confirmada" , 1, 0 )
			lRet := .F.
		Endif
	Endif
	
	//RestArea(aTmpArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AGR870AGRV
Salva as alterações no Grid inferior sem fechar a janela
@author Marcelo R. Ferrari
@since 20/11/16
@version 1.0
/*/
Static Function AGR870AGRV()
	AGR870AAOK()
	AGR870AMKB()
	If !Empty(oMark)
		oMark:oBrowse:Refresh()
	EndIf
Return(.T.)

//-------------------------------------------------------------------       
/*
{Protheus.doc} AGR870ACHK
Função para marcar/desmarcar todos os registros do grid de Liberação SC9 - superior
@sample
AGR870ACHK(nOp)
nOp : 1 => Marca Todos
2 => Desmarca Todos
@author Marcelo R. Ferrari
@since 20/11/2016
@version 1.0
*/                
Static Function AGR870ACHK(nOp)

	dbSelectArea(_cAliMKB)
	(_cAliMKB)->( dbGoTop() )
	While !(_cAliMKB)->( Eof() )

		If If(nOp==1,!IsMark("OK",cMarca),IsMark("OK",cMarca))
			RecLock(_cAliMKB,.F.)
			(_cAliMKB)->OK := If(nOp==1, cMarca, " ")
			MsUnlock()
		EndIf
		dbSelectArea(_cAliMKB)
		(_cAliMKB)->( dbSkip() )
	EndDo

	DbSelectArea(_cAliMKB)
	(_cAliMKB)->(DbGoTop() )

	oMark:oBrowse:Refresh()
Return

/*
{Protheus.doc} AGR870ACLK
Função chamada no evento de duplo click para marcar/desmarcar a linha
@sample
AGR870ACLK()
@author Marcelo R. Ferrari
@since 20/11/2016
@version 1.0
*/              
Static Function AGR870ACLK()
	If !(_cAliMKB)->( Eof() )
		RecLock(_cAliMKB, .F.)
		(_cAliMKB)->OK := If(IsMark("OK",cMarca), " ", cMarca)
		MsUnlock()
		oMark:oBrowse:Refresh()

		If !Empty( aAllObj[4][3] )
			IF MsgYesNo("Deseja substituir os dados do Lote com as informações do pedido?")
				//Limpar os campos
				A870aCls()   
				IF (_cAliMKB)->OK == cMarca
					aAllObj[2][3]     := 0
					If (_cAliMKB)->LOCAL != '99'
						aAllObj[7][3] := (_cAliMKB)->LOCAL
					EndIf
					aAllObj[13][3]  := (_cAliMKB)->CULTRA
					aAllObj[15][3]  := (_cAliMKB)->CULTVAR
					aAllObj[17][3]  := (_cAliMKB)->CATEG
					aAllObj[19][3]  := (_cAliMKB)->PENE
				EndIF
			EndIf
		Else
			IF (_cAliMKB)->OK == cMarca
				aAllObj[2][3]     := 0
				If (_cAliMKB)->LOCAL != '99'
					aAllObj[7][3]    := (_cAliMKB)->LOCAL
				EndIf
				aAllObj[13][3]  := (_cAliMKB)->CULTRA
				aAllObj[15][3]  := (_cAliMKB)->CULTVAR
				aAllObj[17][3]  := (_cAliMKB)->CATEG
				aAllObj[19][3]  := (_cAliMKB)->PENE
			EndIF
		EndIf
		a870aRefs()		
	EndIf

Return

/*
{Protheus.doc} AGR870ASTT
Define as estruturas das tabelas temporárias e executa a instrução pra sua criação
@sample
AGR870ASTT()
@author Marcelo R. Ferrari
@since 20/11/2016
@version 1.0
*/              
Static Function AGR870ASTT()
	Local nX := 0
	Local aInd := {}

	//----------------------------------------------
	// Criacao da tabela temporaria p/ Markbrowse  
	//---------------------------------------------- 

	_aMKB := {;
	{"OK"       , "C", 02, 0},;
	{"FILPED"   , "C", TamSx3("NJ5_FILIAL")[1], 0},;
	{"CODCARGA" , "C", TamSx3("C9_CARGA")[1], 0},;
	{"SEQCAR"   , "C", TamSx3("C9_SEQCAR")[1], 0},;
	{"PEDIDO"   , "C", TamSx3("NJ5_NUMPV")[1], 0},;
	{"ITEM"     , "C", TamSx3("NJ5_ITEM")[1], 0},;
	{"SEQUENCIA", "C", TamSx3("NJ5_SEQUEN")[1], 0},;
	{"PRODUTO"  , "C", TamSx3("NJ5_PRODUT")[1], 0} ,;
	{"DSPRODUTO", "C", TamSx3("B1_DESC")[1], 0} ,;
	{"UM"       , "C", TamSx3("NJ5_UM")[1], 0},;
	{"QTDE"     , "N", TamSx3("NJ5_QTDE")[1], 3},;
	{"SALDO"    , "N", TamSx3("NJ5_QTDE")[1], 3},;
	{"LOCAL"    , "C", TamSx3("NJ5_LOCAL")[1], 0},;
	{"SAFRA"    , TamSx3("C5_CODSAF")[3], TamSx3("C5_CODSAF")[1], TamSx3("C5_CODSAF")[2]},;
	{"CULTRA"   , "C", TamSx3("NJ5_CULTRA")[1], 0},;
	{"CULTVAR"  , "C", TamSx3("NJ5_CTVAR")[1], 0},;
	{"CATEG"    , "C", TamSx3("NJ5_CATEG")[1], 0},;
	{"PENE"     , "C", TamSx3("NJ5_PENE")[1], 0} }

	//germinacao By Proj Expedicao
	aAdd( _aMKB,   {"GERMIN"    , 'C',20,0} )

	
	If lAG87Dire
		aAdd( _aMKB,    {"USADIR"   , "C", 3, 0} )
		aAdd( _aMKB,    {"DIRECI"   , "C", 2, 0} )
	EndIf

	_acpMKB := {;
	{"OK"       , NIL, "OK"         , "@!" },;
	{"FILPED"   , NIL, "Filial"     , "@!" },;
	{"CODCARGA" , NIL, "Cd.Carreg"  , "@!" },;
	{"SEQCAR"   , NIL, "Seq.Carreg" , "@!" },;
	{"PEDIDO"   , NIL, "Pedido"     , "@!" },;
	{"ITEM"     , NIL, "Item"       , "@!" },;
	{"SEQUENCIA", NIL, "Sequência"  , "@!" },;
	{"PRODUTO"  , NIL, "Produto"    , "@!" },;
	{"DSPRODUTO", NIL, "Produto"    , "@!" },;
	{"UM"       , NIL, "Un.Med"     , "@!" },;
	{"QTDE"     , NIL, "Qtde."      , "@E 999,999,999.99" },;
	{"SALDO"    , NIL, "Saldo"      , "@E 999,999,999.99" },;
	{"LOCAL"    , NIL, "Local"      , "@!" },;
	{"SAFRA"    , NIL, "SAFRA"      , X3Picture('C5_CDOSAF') },;
	{"CULTRA"   , NIL, "Cultura"    , "@!" },;
	{"CULTVAR"  , NIL, "Cultivar"   , "@!" },;
	{"CATEG"    , NIL, "Categoria"  , "@!" },;
	{"PENE"     , NIL, "Peneira"    , "@!" } }

	If lAG87Dire
		aAdd( _acpMKB,    {"USADIR"     , NIL, "Usa Dir."    , "@!" }  )
		aAdd( _acpMKB,    {"DIRECI"     , NIL, "Direc."    , "@BMP" }  )
	EndIf

	//Germinacao By Proj Expedicao
	aAdd( _acpMKB,    {"GERMIN"     , NIL, "GERMINAÇÃO"    , "@!" }  )

	
	aInd := {{"INDMKB1", "FILPED+PEDIDO+ITEM+SEQUENCIA+PRODUTO"}} 
	//Ponto de entrada para parametrização da estrutura e dos campos do grid 
	//Deve seguir o que foi definido na SQL da consulta para o grid da sc9
	If ExistBlock("AG870AA4")
		aRes := ExecBlock("AG870AA4",.f.,.f., {_aMKB, _acpMKB, aInd } )
		_aMKB   := aRes[1]
		_acpMKB := aRes[2]
		aInd    := aRes[3]
	EndIf     

	//-- Cria Indice de Trabalho
	_cAliMKB   := GetNextAlias()
	oArqTemp   := AGRCRTPTB(_cAliMKB, {_aMKB, aInd },,,,.F. ) 

	//----------------------------------------------
	// Criacao da tabela temporaria p/ MsGetDb() 
	//----------------------------------------------

	aAdd(_aMKB2, {"SEQLT"   , "C", TamSx3("NJ6_SEQLT")[1], 0} )
	aAdd( _aMKB2, {"FILPED"  , "C", TamSx3("NJ6_FILIAL")[1], 0} )
	aAdd( _aMKB2, {"CODCAR"  , "C", TamSx3("NJ6_CODCAR")[1], 0} )
	If ExistSX3("NJ6_SEQCAR")
		aAdd( _aMKB2,    {"SEQCAR"   , "C", TamSx3("C9_SEQCAR")[1], 0} )
	EndIf
	aAdd( _aMKB2, {"PEDIDO"  , "C", TamSx3("NJ6_NUMPV")[1], 0} )
	aAdd( _aMKB2, {"ITEM"    , "C", TamSx3("NJ6_ITEM")[1], 0} )
	aAdd( _aMKB2, {"SEQUENCIA", "C", TamSx3("NJ6_SEQUEN")[1], 0} )
	aAdd( _aMKB2, {"PRODUTO" , "C", TamSx3("NJ6_PRODUT")[1], 0} )
	aAdd( _aMKB2, {"DSPRODUTO","C", TamSx3("B1_DESC")[1], 0} )
	aAdd( _aMKB2, {"UM"      , "C", TamSx3("NJ6_UM")[1], 0} )
	aAdd( _aMKB2, {"QTDE"    , "N", TamSx3("NJ6_QTDE")[1], 3} )
	aAdd( _aMKB2, {"RESERVA" , "C", TamSx3("NJ6_RESERV")[1], 3} )	
	aAdd( _aMKB2, {"LOCAL"   , "C", TamSx3("NJ6_LOCAL")[1], 0} )
	aAdd( _aMKB2, {"ENDERECO", "C", TamSx3("NJ6_END")[1], 0} )
	aAdd( _aMKB2, {"LOTECT"  , "C", TamSx3("NJ6_LOTECT")[1], 0} )
	aAdd( _aMKB2, {"NMLOTE"  , "C", TamSx3("NJ6_NMLOTE")[1], 0} )
	aAdd( _aMKB2, {"CULTRA"  , "C", TamSx3("NJ6_CULTRA")[1], 0} )
	aAdd( _aMKB2, {"CULTVAR" , "C", TamSx3("NJ6_CTVAR")[1], 0} )
	aAdd( _aMKB2, {"CATEG"   , "C", TamSx3("NJ6_CATEG")[1], 0} )
	aAdd( _aMKB2, {"PENE"    , "C", TamSx3("NJ6_PENE")[1], 0} )                                  

//gERMINACAO By Proj Expedicao
	aAdd( _aMKB2, {"GERMIN"    , "N", TamSx3("NJ6_GERMIN")[1], 0} )

	//***************************************************
	// Dados da estrutura para grid  
	//***************************************************
	//                Nome campo Dicionário / Nome campo SELECT
	aAdd( _acpMKB2, {"NJ6_SEQLT",  "SEQLT"   } )
	aAdd( _acpMKB2, {"NJ6_FILIAL", "FILPED"   } )
	aAdd( _acpMKB2, {"NJ6_CODCAR", "CODCAR"   } )
	If ExistSX3("NJ6_SEQCAR")
		aAdd( _acpMKB2, {"NJ6_SEQCAR", "SEQCAR"   } )
	EndIf
	aAdd( _acpMKB2, {"NJ6_NUMPV",  "PEDIDO"   } )
	aAdd( _acpMKB2, {"NJ6_ITEM",   "ITEM"     } )
	aAdd( _acpMKB2, {"NJ6_SEQUEN", "SEQUENCIA"} )
	aAdd( _acpMKB2, {"NJ6_PRODUT", "PRODUTO"  } )
	aAdd( _acpMKB2, {"B1_DESC",   "DSPRODUTO"} )
	aAdd( _acpMKB2, {"NJ6_UM",     "UM"       } )
	aAdd( _acpMKB2, {"NJ6_QTDE",   "QTDE"     } )
	aAdd( _acpMKB2, {"NJ6_RESERV", "RESERVA"  } )
	aAdd( _acpMKB2, {"NJ6_LOCAL",  "LOCAL"    } )
	aAdd( _acpMKB2, {"NJ6_END",    "ENDERECO" } )
	aAdd( _acpMKB2, {"NJ6_LOTECT", "LOTECT"   } )
	aAdd( _acpMKB2, {"NJ6_NMLOTE", "NMLOTE"   } )
	aAdd( _acpMKB2, {"NJ6_CULTRA", "CULTRA"   } )
	aAdd( _acpMKB2, {"NJ6_CTVAR",	"CULTVAR"  } )
	aAdd( _acpMKB2, {"NJ6_CATEG",  "CATEG"    } )
	aAdd( _acpMKB2, {"NJ6_PENE",   "PENE"     } )
	
	//Germinacao By Proj Expedicao
	aAdd( _acpMKB2, {"NJ6_GERMIN",   "GERMIN"     } )

	aInd := {}
	aInd := {{"INDMKB02", "FILPED+CODCAR+PEDIDO+ITEM+SEQUENCIA+PRODUTO+SEQLT+LOCAL+LOTECT"}} 

	//Ponto de entrada para parametrização da estrutura e dos campos do grid 
	//Deve seguir o que foi definido na SQL da consulta para o grid da NJ6
	//Retorna um array contendo os parâmetros modificados
	If ExistBlock("AG870AA5")
		aRes     := ExecBlock("AG870AA5",.f.,.f., {_aMKB2, _acpMKB2, aInd } )
		_aMKB2   := aRes[1]
		_acpMKB2 := aRes[2]
		aInd     := aRes[3]
	EndIf 

	//-- Cria Indice de Trabalho
	_cAliMKB2   := GetNextAlias()
	oArqTemp2   := AGRCRTPTB(_cAliMKB2, {_aMKB2, aInd },,,,.F. ) 

	For nX := 1 To Len(_acpMKB2)
		Aadd(_aHeadMKB2,{ AllTrim(RetTitle(_acpMKB2[nX][1])),; 
		_acpMKB2[nX][2],;
		X3Picture(_acpMKB2[nX][1]),;
		TamSX3(_acpMKB2[nX][1])[1],;
		TamSX3(_acpMKB2[nX][1])[2],;
		X3Valid(_acpMKB2[nX][1]),;
		GetSX3Cache(_acpMKB2[nX][1],"X3_USADO"),;
		TamSX3(_acpMKB2[nX][1])[3],;
		"NJ6",;
		AGRRETCTXT("NJ6", _acpMKB2[nX][1]),;
		X3Ordem(_acpMKB2[nX][1]) })
	EndFor

Return .T.

/*
{Protheus.doc} AGR870ASLT
Busca a sequencia do lote na tabela de separação de lotes
@sample
AGR870ASLT()
@author Marcelo R. Ferrari
@since 20/11/2016
@version 1.0
*/              
Static Function AGR870ASLT()
	Local cSeqLote   := ""
	Local cAliasTmp  := GETNEXTALIAS()
	Local cQuery     := ""
	Local nNJ6_SEQLT  := 0

	cQuery := "SELECT MAX(NJ6_SEQLT) NJ6_SEQLT " + ;
	"FROM " +RetSqlName("NJ6") +" NJ6 " + ;
	"WHERE NJ6_FILIAL = '" + (_cAlimkb)->FILPED  + "' " + ;
	" AND NJ6_CODCAR  = '" + (_cAlimkb)->CODCARGA + "' " + ;
	IIF(ExistSX3("NJ6_SEQCAR"), " AND NJ6_SEQCAR  = '" + (_cAlimkb)->SEQCAR + "' ", "" ) +;
	" AND NJ6_NUMPV   = '" + (_cAlimkb)->PEDIDO + "' " + ;
	" AND NJ6_ITEM    = '" + (_cAlimkb)->ITEM + "' " + ;
	" AND NJ6_SEQUEN  = '" + (_cAlimkb)->SEQUENCIA + "' " + ;
	" AND NJ6_PRODUT  = '" + (_cAlimkb)->PRODUTO + "' " + ;
	" AND NJ6.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasTmp, .F., .T.)
	dbSelectArea(cAliasTmp)
	nNJ6_SEQLT:= VAL((cAliasTmp)->NJ6_SEQLT)
	If nNJ6_SEQLT = 0 
		cSeqLote := "001"
	Else
		cSeqLote := StrZero(nNJ6_SEQLT+1, 3)
	EndIf

	(cAliasTmp)->(dbclosearea())   

Return cSeqLote

/*
{Protheus.doc} AGR870ASQT
Soma a quantidade de um item específico da Separação de Lotes
que será usado para calcular o saldo do item/sequencia da Liberação (sc9)
@sample
AGR870ASQT()
@author Marcelo R. Ferrari
@since 20/11/2016
@version 1.0
*/              
Static Function AGR870ASQT(nOpc)
	Local aArea 	:= GetArea()
	Local cAliasTmp  := GETNEXTALIAS()
	Local cQuery     := ""
	Local nSomaQtde  := 0
	Local cAliasMkX := _cAlimkb
	Default nOpc := 1

	If nOpc = 2
		cAliasMkX := _cAlimkb2

	EndIf 

	RegToMemory(cAliasMkX, .F., .F.)

	cQuery := "SELECT SUM(NJ6_QTDE) NJ6_SQTDE " + ;
	"FROM " +RetSqlName("NJ6") +" NJ6 " + ;
	"WHERE NJ6_FILIAL = '" + fwXFilial("NJ6")  + "' " + ;
	" AND NJ6_CODCAR  = '" + cOrdCar + "' " + ;
	IIF(ExistSX3("NJ6_SEQCAR"), " AND NJ6_SEQCAR  = '" + cSeqCar + "' ", "" ) + ;
	" AND NJ6_NUMPV   = '" + (cAliasMkX)->PEDIDO + "' " + ;
	" AND NJ6_ITEM    = '" + (cAliasMkX)->ITEM + "' " + ;
	" AND NJ6_SEQUEN  = '" + (cAliasMkX)->SEQUENCIA + "' " + ;
	" AND NJ6_PRODUT  = '" + (cAliasMkX)->PRODUTO + "' " + ;
	" AND NJ6.D_E_L_E_T_ = ' ' "

	If nOpc = 2
		cQuery += " AND NJ6_SEQLT <> '" + (cAliasMkX)->SEQLT + "' "
	EndIf             

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasTmp, .F., .T.)
	dbSelectArea(cAliasTmp)
	IF !Empty( (cAliasTmp)->NJ6_SQTDE )
		nSomaQtde := (cAliasTmp)->NJ6_SQTDE
		If nOpc = 2
			nSomaQtde := nSomaQtde + M->QTDE
		EndIf
	EndIf
	(cAliasTmp)->(dbclosearea())
	RestArea(aArea)   
Return nSomaQtde

/*
{Protheus.doc} AGR870AQTDL
Busca a quantidade solicitada na tabela SC9 para o item selecionado
na separação de lote para comparação do saldo
@sample
AGR870AQTDL()
@author Marcelo R. Ferrari
@since 20/11/2016
@version 1.0
*/
Static Function AGR870AQTDL()
	Local aArea 	:= GetArea()
	Local cAliasTmp  := GETNEXTALIAS()
	Local cQuery     := ""
	Local nSomaQtde  := 0

	cQuery := "SELECT SUM(C9_QTDLIB) C9_SQTDLIB " + ;
	"FROM " +RetSqlName("SC9") +" SC9 " + ;
	"WHERE C9_FILIAL = '" + FwXFilial("SC9")  + "' " + ;
	" AND C9_PEDIDO  = '" + (_cAlimkb2)->PEDIDO + "' " + ;
	" AND C9_ITEM    = '" + (_cAlimkb2)->ITEM + "' " + ;
	" AND C9_SEQUEN  = '" + (_cAlimkb2)->SEQUENCIA + "' " + ;
	" AND C9_PRODUTO = '" + (_cAlimkb2)->PRODUTO + "' " + ;
	" AND SC9.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasTmp, .F., .T.)
	dbSelectArea(cAliasTmp)
	IF !Empty( (cAliasTmp)->C9_SQTDLIB )
		nSomaQtde := (cAliasTmp)->C9_SQTDLIB
	EndIf
	(cAliasTmp)->(dbclosearea())   
	RestArea(aArea)
Return nSomaQtde



/** ------------------------------------------------------------------------------------------
{Protheus.doc} A870aVldSF
Validação da Safra
@param: Nil
@author: TOTVS
@since: 27/03/2013
@Uso: AGRA615
------------------------------------------------------------------------------------------ **/
Function A870aVldSF()
	Local lRet := .T.

Return(lRet)


/** ------------------------------------------------------------------------------------------
{Protheus.doc} LeftPos
Retorna a posição padronizada para o TGet no formulário
@param: nLeft = variavel com a ultima posição utilizada
Adic  = Valor a ser adicionado além do padrão
@author: Marcelo R. Ferrari
@since: fev/2017
@Uso: AGRA870A
------------------------------------------------------------------------------------------ **/
Function LeftPos(nLeft, Adic, nPadrao)
	Default Adic := 0
	Default nPadrao := 45

	nLeft := nLeft + nPadrao + (Adic)
Return nLeft


Static Function A870aCls()
	Local k := 0

	For k := 1 to Len(aAllObj)
		If aAllObj[k][2][1]==  "TGET"
			If ValType(aAllObj[k][3]) = "N" 
				aAllObj[k][3] := 0
			Else
				aAllObj[k][3] := Replicate(" ", TamSx3(aAllObj[k][4])[1] ) 
			EndIf
		EndIf
	Next X

Return

Static Function a870aRefs()
	Local k := 0
	For k := 1 to len(aAllObj)
		If aAllObj[k][2][1]==  "TGET"
			aAllObj[k][1]:CtrlRefresh()
		EndIf
	Next k
Return

/*/{Protheus.doc} AGRF4Lote
Monta a tela de consulta de saldo
@type function
@version P12
@author: Aecio Ferreira Gomes
@since: 20/02/2013
@param cCod, character, Codigo do produto
@type function
/*/
Static Function AGRF4Lote(cCod)
	Local cQuery
	local cIndice 		:= ""
	local aIndex 		:= {"NP9_LOTE"}
	Local nIndice
	local cChaveA
	local lRastroS 		:= If(Rastro(cCod,"S"),.t.,.f.)
	local nx
	local ny
	local nSaldoL
	local nSaldoBF
	Local CodSaf 		:= GetDataSql("SELECT C5_CODSAF FROM " + RetSqlName("SC5") + " SC5 "+;
									" WHERE C5_FILIAL = '" + fwXFilial("SC5") + "' "+;
									" AND C5_NUM = '" + (_cAlimkb)->PEDIDO + "' ")
	Local aMatLote 		:= {}
	Local aSeek 		:= {}
	Local aColumns		:= {}
	//Local cQry 			:= nil
	Local aResultado 	:= FiltraResultados()
	Local cResult		:= ""
	Local cTypeDB		:= Upper( TcGetDb() )
	Local aSize 		:= {}
	Local lEmpPrev		:= If(SuperGetMV("MV_QTDPREV") = "S",.T.,.F.)
	Local cCliente      := ''
	
	Local cAliasQry		:= "" //Alias da Tabela Temporaria
	Local cQryTempo		:= "" //Montagem da query para carregar no temporário
	Local cAG870AA8		:= "" //Retorno do ponto de entrada AG870AA8	
	Local cAG870AA9		:= "" //Retorno do ponto de entrada AG870AA9
	Local cVld870A9		:= "" //Regra para validar se o registro deve ser mostrado em tela de lote
	Local cUm			:= '' //Ira conter a unidade de medida do pedido em questão
	Local cLoteDirec    := ''
	
	Local lUsouDire		:= IIF(lAG87Dire,fExistND6((_cAlimkb)->PEDIDO, (_cAlimkb)->ITEM, CodSaf), .F.) // Verificar se vai utilizar Direcionamento do item dos pedido
	
	aSize := MsAdvSize(.F.)	
	_cProdutoLote := cCod
	cQuery := " AND NP9_PROD ='"+cCod+"' AND NP9_CODSAF ='"+CodSaf+"' "
	cQuery += " AND NP9_STATUS  = '2'"
	DbSelectArea("SC6")
	SC6->(DBGoTop())
	If SC6->(DbSeek(fwxFilial("SC6")+(_cAlimkb)->(PEDIDO+ITEM+PRODUTO) ) )

		If !Empty(SC6->C6_CULTRA) 
			cQuery += " AND NP9.NP9_CULTRA = '" + SC6->C6_CULTRA + "' "
		EndIf

		If !Empty(SC6->C6_CTVAR) 
			cQuery += " AND NP9.NP9_CTVAR = '" + SC6->C6_CTVAR + "' "
		EndIf

		If !Empty(SC6->C6_CATEG) 
			cQuery += " AND NP9.NP9_CATEG = '" + SC6->C6_CATEG + "' "
		EndIf

		If !Empty(SC6->C6_PENE) 
			cQuery += " AND NP9.NP9_PENE = '" + SC6->C6_PENE + "' "
		EndIf

		If !Empty(SC6->C6_CLI)
			cCliente := SC6->C6_CLI
		EndIf

		cUM := SC6->C6_UM

	EndIf

	If !Empty( aAllObj[7][1]) .AND. !Empty(aAllObj[7][3])  //_cLocal
		cQuery += " AND SB8.B8_LOCAL = '" + aAllObj[7][3] + "' "
	EndIf
	

	//Campos de resultado que serao exibidos na Consulta de lotes
	For Nx := 1 to Len(aResultado)
		cResult += " , (SELECT "
		If cTypeDB == "MSSQL"
			cResult += " TOP 1 "	
		EndIf 
		cResult += aResultado[Nx][4] + " FROM " + RETSQLNAME('NPX') + " NPX WHERE NPX.NPX_FILIAL = '" + FWxFilial("NPX") + "'"
		cResult += " AND NPX.NPX_CODSAF ='"+CodSaf+"' "
		cResult += " AND NPX.NPX_LOTE = NP9.NP9_LOTE AND NPX.NPX_CODTA='"+aResultado[Nx][1]+"'  AND NPX.NPX_CODVA='"+aResultado[Nx][2]+"' "
		cResult += " AND NPX.D_E_L_E_T_= ' ' AND NPX.NPX_ATIVO='1'"
		If cTypeDB == "ORACLE"
			cResult += " AND ROWNUM = 1 "	 
		EndIf
		cResult += " ) as "+aResultado[Nx][3] 
	Next Nx

	cQryTempo := "SELECT NP9.NP9_FILIAL,NP9.NP9_PROD,NP9.NP9_CODSAF,NP9.NP9_LOTE,NP9.NP9_TRATO, NP9.NP9_TIPLOT,NP9.NP9_EMB,NP9.NP9_2UM, "
	cQryTempo += "NP9.NP9_CULTRA,NP9.NP9_CTVAR,NP9.NP9_CATEG,NP9.NP9_PENE,SB8.B8_DTVALID,SBF.BF_LOCALIZ,SB8.B8_LOCAL, "
	cQryTempo += "SBF.BF_NUMLOTE, SC0.C0_NUM, SC0.C0_QUANT, 'NAO' as LOTE_DIREC"
	cQryTempo += cResult+" " 
	cQryTempo += "FROM "+RetSqlName('SB8')+" SB8 "
	cQryTempo += "INNER JOIN "+RetSqlName('NP9')+" NP9 ON NP9.D_E_L_E_T_ = ' ' "
	cQryTempo += "       AND NP9.NP9_FILIAL	= '"+FWxFilial("NP9")+"' "  
	cQryTempo += "       AND NP9.NP9_LOTE	= SB8.B8_LOTECTL "
	cQryTempo += "       AND NP9.NP9_PROD	= SB8.B8_PRODUTO "
	cQryTempo += "LEFT JOIN "+RetSqlName('SC0')+" SC0 ON SC0.D_E_L_E_T_ = ' ' "
	cQryTempo += "      AND NP9.NP9_FILIAL	= SC0.C0_FILIAL "
	cQryTempo += "		AND NP9.NP9_PROD	= SC0.C0_PRODUTO "
	cQryTempo += "		AND NP9.NP9_LOTE	= SC0.C0_LOTECTL "
	cQryTempo += "		AND SC0.C0_QTDPED	= 0 " 
	cQryTempo += "		AND SC0.C0_QTDELIM	= 0 "
	///cQryTempo += "      AND SC0.C0_TIPO		= 'CL' "
	///cQryTempo += "      AND SC0.C0_DOCRES	= '"+cCliente+"' " 
	cQryTempo += "LEFT JOIN "+RetSqlName('SBF')+" SBF ON SBF.D_E_L_E_T_ = ' ' "							
	cQryTempo += "      AND	SBF.BF_FILIAL	= '"+FWxFilial("SBF")+"' "	
	cQryTempo += "		AND SBF.BF_LOCAL	= SB8.B8_LOCAL "
	cQryTempo += "		AND SBF.BF_PRODUTO	= '"+cCod+"' "	
	cQryTempo += "		AND SBF.BF_LOTECTL	= NP9.NP9_LOTE "
	cQryTempo += "		AND SBF.BF_LOCALIZ	= SC0.C0_LOCALIZ "	
	IF lAG87Dire .AND. lUsouDire //inclusão da query para atender a estrutura do Direcionamento de pedido de venda
		cQryTempo += "INNER JOIN "+RetSqlName('ND5')+" ND5 ON ND5.D_E_L_E_T_ = ' ' "							
		cQryTempo += "      AND	ND5.ND5_FILIAL	= '"+FWxFilial("ND5")+"' "	
		cQryTempo += "		AND ND5.ND5_PEDIDO	= '"+(_cAlimkb)->PEDIDO+"' "
		cQryTempo += "		AND ND5.ND5_ITEM	= '"+(_cAlimkb)->ITEM+"' "
		cQryTempo += "		AND ND5.ND5_PRODUT	= '"+cCod+"' "	
		cQryTempo += "		AND ND5.ND5_STATUS	= '1' "	
		cQryTempo += "INNER JOIN "+RetSqlName('ND6')+" ND6 ON ND6.D_E_L_E_T_ = ' ' "							
		cQryTempo += "      AND	ND6.ND6_FILIAL	= ND5.ND5_FILIAL "	
		cQryTempo += "      AND	ND6.ND6_CODIGO	= ND5.ND5_CODIGO "	
		cQryTempo += "		AND ND6.ND6_PEDIDO	= ND5.ND5_PEDIDO "
		cQryTempo += "		AND ND6.ND6_ITEMPV	= ND5.ND5_ITEM "
		cQryTempo += "		AND ND6.ND6_LOTE	= NP9.NP9_LOTE "
		cQryTempo += "		AND ND6.ND6_CODSAF	= NP9_CODSAF "	
	EndIF
	cQryTempo += "LEFT JOIN "+RetSqlName('NJ6')+" NJ6 ON NJ6.D_E_L_E_T_ = ' ' "	
	cQryTempo += "		AND SC0.C0_FILIAL	= NJ6.NJ6_FILIAL "
	cQryTempo += "		AND SC0.C0_PRODUTO	= NJ6.NJ6_PRODUT "
	cQryTempo += "		AND SC0.C0_LOCAL	= NJ6.NJ6_LOCAL "
	cQryTempo += "		AND SC0.C0_LOTECTL	= NJ6.NJ6_LOTECT "
	cQryTempo += "		AND SC0.C0_LOCALIZ	= NJ6.NJ6_END "
	cQryTempo += "		AND SC0.C0_NUM		= NJ6.NJ6_RESERV "
	cQryTempo += "WHERE "
	cQryTempo += "SB8.B8_FILIAL='"+FWxFilial("SB8")+"' "  
	cQryTempo += cQuery+" "
	cQryTempo += "AND SB8.D_E_L_E_T_ = ' ' "

    cQryTempo += "      AND (SC0.C0_TIPO		= 'CL'  AND SC0.C0_DOCRES	= '"+cCliente+"')"
	
	cQryTempo += "AND NJ6.NJ6_RESERV IS NULL "

	cQryTempo += "UNION

	cQryTempo += "SELECT NP9.NP9_FILIAL,NP9.NP9_PROD,NP9.NP9_CODSAF,NP9.NP9_LOTE,NP9.NP9_TRATO, NP9.NP9_TIPLOT,NP9.NP9_EMB,NP9.NP9_2UM, " 
	cQryTempo += "NP9.NP9_CULTRA,NP9.NP9_CTVAR,NP9.NP9_CATEG,NP9.NP9_PENE,SB8.B8_DTVALID,SBF.BF_LOCALIZ,SB8.B8_LOCAL, "
	cQryTempo += "SBF.BF_NUMLOTE, '' as C0_NUM, 0 as C0_QUANT, 'NAO' as LOTE_DIREC"
	cQryTempo += cResult+" " 
	cQryTempo += "FROM "+RetSqlName('SB8')+" SB8 "
	cQryTempo += "INNER JOIN "+RetSqlName('NP9')+" NP9 ON NP9.D_E_L_E_T_ = ' ' "
	cQryTempo += "		 AND NP9.NP9_FILIAL	= '"+FWxFilial("NP9")+"' " 
	cQryTempo += "		 AND NP9.NP9_LOTE	= SB8.B8_LOTECTL "
	cQryTempo += "		 AND NP9.NP9_PROD	= SB8.B8_PRODUTO "
	cQryTempo += "LEFT JOIN "+RetSqlName('SBF')+"  SBF ON SBF.D_E_L_E_T_ = ' ' "							
	cQryTempo += "		AND SBF.BF_FILIAL	= '"+FWxFilial("SBF")+"' " 	
	cQryTempo += "		AND SBF.BF_LOCAL	= SB8.B8_LOCAL "
	cQryTempo += "		AND SBF.BF_PRODUTO	= '"+cCod+"' "	
	cQryTempo += "		AND SBF.BF_LOTECTL	= NP9.NP9_LOTE "
	IF lAG87Dire .AND. lUsouDire //inclusão da query para atender a estrutura do Direcionamento de pedido de venda
		cQryTempo += "INNER JOIN "+RetSqlName('ND5')+" ND5 ON ND5.D_E_L_E_T_ = ' ' "							
		cQryTempo += "      AND	ND5.ND5_FILIAL	= '"+FWxFilial("ND5")+"' "	
		cQryTempo += "		AND ND5.ND5_PEDIDO	= '"+(_cAlimkb)->PEDIDO+"' "
		cQryTempo += "		AND ND5.ND5_ITEM	= '"+(_cAlimkb)->ITEM+"' "
		cQryTempo += "		AND ND5.ND5_PRODUT	= '"+cCod+"' "	
		cQryTempo += "		AND ND5.ND5_STATUS	= '1' "	
		cQryTempo += "INNER JOIN "+RetSqlName('ND6')+" ND6 ON ND6.D_E_L_E_T_ = ' ' "							
		cQryTempo += "      AND	ND6.ND6_FILIAL	= ND5.ND5_FILIAL "	
		cQryTempo += "      AND	ND6.ND6_CODIGO	= ND5.ND5_CODIGO "	
		cQryTempo += "		AND ND6.ND6_PEDIDO	= ND5.ND5_PEDIDO "
		cQryTempo += "		AND ND6.ND6_ITEMPV	= ND5.ND5_ITEM "
		cQryTempo += "		AND ND6.ND6_LOTE	= NP9.NP9_LOTE "
		cQryTempo += "		AND ND6.ND6_CODSAF	= NP9_CODSAF "	
	EndIF
	cQryTempo += "WHERE "
	cQryTempo += "SB8.B8_FILIAL='"+FWxFilial("SB8")+"' "  
	cQryTempo += cQuery+" "
	cQryTempo += "AND B8_SALDO > B8_EMPENHO "
	cQryTempo += "AND SB8.D_E_L_E_T_ = ' ' "

	//Ponto de Entrada para adicionar clausulas no select que traz os Lotes para selecionar.
	If lAG870AA8
		cAG870AA8 := ExecBlock( "AG870AA8",.F.,.F.,{cQryTempo, (_cAlimkb)->PEDIDO, (_cAlimkb)->ITEM,(_cAlimkb)->PRODUTO })
		IF ValType(cAG870AA8) == "C" .AND. !Empty(cAG870AA8)
			cQryTempo += cAG870AA8
		EndIF
	EndIF
	
	cQryTempo := ChangeQuery(cQryTempo)

	//EECView(cQryTempo,"Consulta de Lote")

	cAliasQry := "NP9TEMP"

    //Proteção pois estava estourando erro que ja existia esse Alias
	IF SELECT(cAliasQry) > 0
		(cAliasQry)->(dbCloseArea())
	EndIF

	dbUseArea( .T., "TOPCONN", TCGenQry(,,cQryTempo), cAliasQry, .F., .T.)
	TCSetField(cAliasQry, 'B8_DTVALID'   , 'D')
	
	//Cria estrutura de arquivo temporario
	aCamTRB :=	{ ;
	{"C0_NUM"    ,TamSX3("C0_NUM")[3]    ,TamSX3("C0_NUM")[1]     ,TamSX3("C0_NUM")[2]     ,"Reserva"     ,PesqPict("SC0","C0_NUM")      },;
	{"NP9_LOTE"},{"B8_LOCAL"},{"BF_LOCALIZ"},{"NP9_CULTRA"},{"NP9_CTVAR"},{"NP9_CATEG"},{"NP9_PENE"},{"NP9_2UM"},{"B8_DTVALID"},;
	{"B8_SALDO",TamSX3("B8_SALDO")[3],TamSX3("B8_SALDO")[1],TamSX3("B8_SALDO")[2],AGRTITULO("B8_SALDO"),PesqPict("SB8","B8_SALDO")},;
	{"BF_QUANT",TamSX3("BF_QUANT")[3],TamSX3("BF_QUANT")[1],TamSX3("BF_QUANT")[2],"Saldo Endereco",PesqPict("SBF","BF_QUANT")},;
	{"NJ6_QTDE",TamSX3("NJ6_QTDE")[3],TamSX3("NJ6_QTDE")[1],TamSX3("NJ6_QTDE")[2],"Qtd.Reserv.",PesqPict("NJ6","NJ6_QTDE")},;
	{"NP9_CULTRA",TamSX3("NP9_CULTRA")[3],TamSX3("NP9_CULTRA")[1],TamSX3("NP9_CULTRA")[2],AGRTITULO("NP9_CULTRA"),PesqPict("NP9","NP9_CULTRA")},;
	{"NP9_CTVAR",TamSX3("NP9_CTVAR")[3],TamSX3("NP9_CTVAR")[1],TamSX3("NP9_CTVAR")[2],AGRTITULO("NP9_CTVAR"),PesqPict("NP9","NP9_CTVAR")},;	
	{"NP9_CATEG",TamSX3("NP9_CATEG")[3],TamSX3("NP9_CATEG")[1],TamSX3("NP9_CATEG")[2],AGRTITULO("NP9_CATEG"),PesqPict("NP9","NP9_CATEG")},;
	{"NP9_PENE",TamSX3("NP9_PENE")[3],TamSX3("NP9_PENE")[1],TamSX3("NP9_PENE")[2],AGRTITULO("NP9_PENE"),PesqPict("NP9","NP9_PENE")},;
	{"NP9_TIPLOT",TamSX3("NP9_TIPLOT")[3],TamSX3("NP9_TIPLOT")[1],TamSX3("NP9_TIPLOT")[2],AGRTITULO("NP9_TIPLOT"),PesqPict("NP9","NP9_TIPLOT")},;
	{"NP9_TRATO",TamSX3("NP9_TRATO")[3],TamSX3("NP9_TRATO")[1],TamSX3("NP9_TRATO")[2],AGRTITULO("NP9_TRATO"),PesqPict("NP9","NP9_TRATO")},;
	{"NP9_EMB",TamSX3("NP9_EMB")[3],TamSX3("NP9_EMB")[1],TamSX3("NP9_EMB")[2],AGRTITULO("NP9_EMB"),PesqPict("NP9","NP9_EMB")     },;
	{"NP9_CODSAF",TamSX3("NP9_CODSAF")[3],TamSX3("NP9_CODSAF")[1],TamSX3("NP9_CODSAF")[2],AGRTITULO("NP9_CODSAF"),PesqPict("NP9","NP9_CODSAF")     },;
	{"LOTE_DIREC",'C',3,0,'Lote C/Direc.','@!'    }}

	//Campos de resultado que serao exibidos na Consulta de lotes
	For Nx := 1 to Len(aResultado)
		//aadd(aCamTRB,{ALLTRIM(aResultado[Nx][3])})
		aadd(aCamTRB,{ALLTRIM(aResultado[Nx][3]),TamSX3(aResultado[Nx][4])[3],TamSX3(aResultado[Nx][4])[1],TamSX3(aResultado[Nx][4])[2],aResultado[Nx][3],PesqPict("NPX",aResultado[Nx][4])})
	Next Nx

	aRet := AGRCRIATRB(,aCamTRB,aIndex,FunName(),.t.)
	cNomeTRB := aRet[3] //Nome do arquivo temporário
	cAliTRBL := aRet[4] //Nome do alias do arquivo temporario
	aArqTemp := aRet[5] //Matriz com a estrutura do arquivo temporario + label e picutre


	//Ponto de Entrada para tratamento de visualização dos lotes na tela de seleção de lotes conforme filtros
	If lAG870AA9
		cAG870AA9 := ExecBlock( "AG870AA9",.F.,.F.,{cQryTempo, cAliasQry, (_cAlimkb)->PEDIDO, (_cAlimkb)->ITEM,(_cAlimkb)->PRODUTO, lUsouDire } )
		IF ValType(cAG870AA9) == "C" .AND. !Empty(cAG870AA9)
			cVld870A9 := cAG870AA9
		EndIF
	EndIF	

	//Carrega os dados para o arquivo temporario
	ARGSETIFARQUI("NP9TEMP")
	While ("NP9TEMP")->(!Eof())
		nIndice := If(lRastroS,2,3)
		cChaveA := If(lRastroS,("NP9TEMP")->BF_NUMLOTE+("NP9TEMP")->NP9_LOTE+cCod+("NP9TEMP")->B8_LOCAL,cCod+("NP9TEMP")->B8_LOCAL+("NP9TEMP")->NP9_LOTE)
		//Germinacao By Proj Expedicao
		
		
		cGermSC6 := Posicione("SC6",1,FWxFilial("SB6")+(_cAlimkb)->PEDIDO+(_cAlimkb)->ITEM+(_cAlimkb)->PRODUTO, "C6_GERMINA")

		IF !Empty(cGermSC6) .and. ! GermNaFaix(cGermSC6, ("NP9TEMP")->NP9_LOTE, ("NP9TEMP")->NP9_CODSAF) = .T. //Verifica se a Germinação do Lote esta na faixa de Germinação indicada no PV
		   	("NP9TEMP")->(dbSkip())
				LOOP
        EndIF
		//
		IF lAG870AA9 .AND. !Empty(cVld870A9)
			IF &(cVld870A9)
				("NP9TEMP")->(dbSkip())
				LOOP
			EndIF
		EndIF
		
		If AGRIFDBSEEK("SB8",cChaveA,nIndice,.f.)
			nSaldoL  := SB8Saldo(.F.,!Empty(("NP9TEMP")->NP9_LOTE),NIL,NIL,NIL,lEmpPrev,NIL,ddatabase,)
			nSaldoBF := SaldoSBF(("NP9TEMP")->B8_LOCAL,("NP9TEMP")->BF_LOCALIZ,("NP9TEMP")->NP9_PROD,NIL,("NP9TEMP")->NP9_LOTE,NIL,.F.,NIL,.T.)

			//Abastecer a Coluna da consunta que indica se o Lote tem ou não direcionamento
			cLoteDirec := 'NAO'
			IF lAG87Dire .AND. lUsouDire 
			   cLoteDirec := 'SIM'
			ElseIF lAG87Dire .AND. !lUsouDire  //( lUsouDirec Indica que o pedido não usou direcionamento)    
			       //Se temos a estrutura de direcionamento e o pedido não utilizou direcionamento
				   //Verifico se o Lote esta direcionado para outro PV.
				    IF AGr870X1(("NP9TEMP")->NP9_CODSAF,("NP9TEMP")->NP9_LOTE,("NP9TEMP")->BF_NUMLOTE, cUM)
                       cLoteDirec := 'SIM'
					EndIF
			ENDIF

			//  (.F.)-> Retira o empenho
			//TODO VERIFICAR POR QUE ESTÁ CONSIDERANDO SALDO DE ENDEREÇÕ TEM QUE VERIFICAR  SE O PRODUTO ESTÁ TRABALHANDO COM ENDEREÇO
			If aScan(aMatLote,{|x| AllTrim(x[1]) = Alltrim(("NP9TEMP")->NP9_LOTE) .And. AllTrim(x[2]) = Alltrim(("NP9TEMP")->BF_LOCALIZ) .And.;
			AllTrim(x[3]) = Alltrim(("NP9TEMP")->B8_LOCAL)}) = 0 .And. !Empty(nSaldoL) .And. (nSaldoBF > 0 ) .And. ("NP9TEMP")->C0_NUM = ' '
				AGRGRAVA2T(cAliTRBL,"NP9TEMP")
				AGRGRAVAREG(cAliTRBL,{{'NP9_TRATO',(AGRRETSX3BOX("NP9_TRATO"	,("NP9TEMP")->NP9_TRATO))},;
				{'NP9_TIPLOT',(AGRRETSX3BOX("NP9_TIPLOT",("NP9TEMP")->NP9_TIPLOT))},;
				{'LOTE_DIREC',cLoteDirec},;
				{'NP9_EMB',(AGRRETSX3BOX("NP9_EMB",("NP9TEMP")->NP9_EMB))},{'B8_SALDO',nSaldoL},{'BF_QUANT',nSaldoBF}})

			ElseIf aScan(aMatLote,{|x| AllTrim(x[1]) = Alltrim(("NP9TEMP")->NP9_LOTE) .And. AllTrim(x[2]) = Alltrim(("NP9TEMP")->BF_LOCALIZ) .And.;
			AllTrim(x[3]) = Alltrim(("NP9TEMP")->B8_LOCAL)}) = 0 .And. !Empty(nSaldoL) .And. (nSaldoBF > 0 )
				AGRGRAVA2T(cAliTRBL,"NP9TEMP")
				AGRGRAVAREG(cAliTRBL,{{'NP9_TRATO',(AGRRETSX3BOX("NP9_TRATO"	,("NP9TEMP")->NP9_TRATO))},;
				{'NP9_TIPLOT',(AGRRETSX3BOX("NP9_TIPLOT",("NP9TEMP")->NP9_TIPLOT))},;
				{'LOTE_DIREC',cLoteDirec},;
				{'NP9_EMB',(AGRRETSX3BOX("NP9_EMB",("NP9TEMP")->NP9_EMB))},{'B8_SALDO',nSaldoL},{'BF_QUANT',("NP9TEMP")->C0_QUANT}})

			EndIf
		EndIf
		("NP9TEMP")->(dbSkip())
	EndDo

	// monta a estruta para index
	For nx := 1 To Len(aIndex)
		cIndice := aIndex[nx]
		cIndice := StrTran(cIndice," ","")
		cIndice := StrTran(cIndice,"Dtos(","")
		cIndice := StrTran(cIndice,"Descend(","")
		cIndice := StrTran(cIndice,")","")
		cDescIn := Space(1)
		vVetInT := {}
		While !Empty(cIndice)
			nPos := At("+",cIndice)
			cCam := If(nPos > 0,Alltrim(SubStr(cIndice,1,nPos-1)),Alltrim(SubStr(cIndice,1,Len(cIndice))))
			Aadd(vVetInT,cCam)
			cIndice := StrTran(cIndice,If(nPos > 0,cCam+"+",cCam),"")
		End
		cTamInd := 0
		For ny := 1 To Len(vVetInT)
			nPos1 := Ascan(aArqTemp,{|x| Alltrim(x[1]) == Alltrim(vVetInT[ny])})
			If nPos1 > 0
				cDescIn += Alltrim(aArqTemp[nPos1,5])+If(ny < len(vVetInT)," + ","")
				cTamInd += aArqTemp[nPos1,3]
			EndIf
		Next ny
		Aadd(aSeek,{cDescIn,{{"","C",cTamInd,0,' ',,}}})
	Next nx

	DEFINE MSDIALOG oDlgX TITLE "Consulta de Lote" FROM aSize[7],0 To aSize[6],aSize[5] PIXEL OF oMainWnd
	DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD
	// Instancia o layer
	oFWL1 := FWLayer():New()
	// Inicia o Layer
	oFWL1:init( oDlgX,.F.)
	// Cria uma linha unica para o Layer
	oFWL1:addLine( 'SUP', 10 , .F.)
	oFWL1:addLine( 'INF', 90 , .F.)
	// Cria colunas
	oFWL1:addCollumn('ESQ',100,.T.,'SUP' )
	oPnlLine1 := oFWL1:getLinePanel('INF')
	oPnDir    := oFWL1:getColPanel('ESQ','SUP')

	@ 004,010 SAY SM0->M0_CODIGO+"/"+FWCodFil()+" - "+SM0->M0_FILIAL+"/"+SM0->M0_NOME  Of oPnDir PIXEL SIZE 245,009
	@ 014,010 SAY Alltrim(cCod)+ " - "+ POSICIONE("SB1", 1, xFilial("SB1") + cCod, "B1_DESC") Of oPnDir PIXEL SIZE 245,009 FONT oBold
	
	//Adicionado informação na tela para mencionar se a estrutura de Direcionamento de pedido de venda está sendo utilizada
	IF lAG87Dire
		@ 024,010 SAY "Utilizou Direcionamento de Pedido de Venda: "+IIF(lUsouDire, "SIM", "NÃO") Of oPnDir PIXEL SIZE 245,009
	EndIF
	
	For nx := 1 To Len(aArqTemp)
		AAdd(aColumns,FWBrwColumn():New())
		aColumns[nx]:SetData(&("{||"+aArqTemp[nx,1]+"}"))
		aColumns[nx]:SetTitle	( Alltrim(aArqTemp[nx,5]))
		aColumns[nx]:SetPicture(Alltrim(aArqTemp[nx,6]))
		aColumns[nx]:SetType(Alltrim(aArqTemp[nx,2]))
		aColumns[nx]:SetSize(aArqTemp[nx,3])
		aColumns[nx]:SetReadVar(aArqTemp[nx,1])
	Next nx

	DEFINE FWFORMBROWSE oBrowsX DATA TABLE ALIAS cAliTRBL OF oPnlLine1
	oBrowsX:SetTemporary(.T.)
	oBrowsX:SetFieldFilter(AGRITEMCBRW(aArqTemp))
	oBrowsX:SetColumns(aColumns)
	oBrowsX:SetDBFFilter(.T.)
	oBrowsX:SetUseFilter(.T.)
	oBrowsX:DisableDetails(.F.)
	oBrowsX:SetProfileID( 'AGRA870AF4'	) 
	oBrowsX:SetSeek(,aSeek)
	oBrowsX:SetDoubleClick(&('{||AGRA870ADUP()}'))
	oBrowsX:AddButton("Sair",{|| oDlgX:end()},,9,0)
	ACTIVATE FWFORMBROWSE oBrowsX
	ACTIVATE MSDIALOG oDlgX CENTER

	AGRDELETRB(cAliTRBL,cNomeTRB)
	ARGCLOSEAREA("NP9TEMP")
	DbSelectArea("NPN")
Return .T.

//Atualiza os dados selecionados no formuário
function AGRA870ADUP()
Local cQryNpx		:= GetNextAlias()

	If !empty((cAliTRBL)->NP9_LOTE )
		M->NPN_LOTE := (cAliTRBL)->NP9_LOTE
		aAllObj[7][3]  := (cAliTRBL)->B8_LOCAL
		aAllObj[9][3]  := (cAliTRBL)->BF_LOCALIZ 
		aAllObj[4][3]  := M->NPN_LOTE // Sub-lote não é usado na consulta F4
		aAllObj[13][3] := (cAliTRBL)->NP9_CULTRA
		aAllObj[15][3] := (cAliTRBL)->NP9_CTVAR 
		aAllObj[17][3] := (cAliTRBL)->NP9_CATEG
		aAllObj[19][3] := (cAliTRBL)->NP9_PENE
		aAllObj[21][3] := (cAliTRBL)->C0_NUM

		//By Proj Expedicao
		//Tratando o campo de resultado Germinação
		BeginSQL Alias cQryNpx
			SELECT NPX_RESNUM
				FROM %Table:NPX% NPX
					INNER JOIN %Table:NPU% NPU 
						ON  NPU.%notDel%
						AND NPU.NPU_CODTA = NPX. NPX_CODTA 
						AND NPU.NPU_CODVA = NPX.NPX_CODVA 
						AND NPU.NPU_FILIAL = %xFilial:NPU% 
				WHERE NPX.NPX_FILIAL = %xFilial:NPX% 
				AND NPX.NPX_CODSAF =%exp:(cAliTRBL)->NP9_CODSAF%
				AND NPX.NPX_LOTE = %exp:(cAliTRBL)->NP9_LOTE%
				AND NPX.%notDel%
				AND NPX.NPX_ATIVO='1'
				AND NPU.NPU_TPRES = '1'  //Indica que a variavel se refere a um resultado de germinação
		EndSQL

		aAllObj[23][3] := (cQryNpx)->NPX_RESNUM

		( cQryNpx )->( DbCloseArea() )

		a870aRefs()
	Endif
	oDlgX:end()
Return


// -------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRA870AF4
Consulta de Saldos
@author: Aecio Ferreira Gomes
@since: 20/02/2013
@Uso: AGRA900
/*/
// -------------------------------------------------------------------------------------
Function AGRA870AF4()

	//Verifica se tem código de produto selecionado no Grid superior
	If !Empty( (_cAliMKB)->PRODUTO )
		AGRF4Lote((_cAliMKB)->PRODUTO)
	Else
		ApMsgAlert("Selecione um produto para pesquisar o lote")
	EndIf 
Return .T.

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRA870AF5
Consulta de Lotes Direcionados
@author: Agroindustri
@since: Agosto/2020
@Uso: AGRA870AF5
/*/
// -------------------------------------------------------------------------------------
Function AGRA870AF5()

	//Verifica se tem código de produto selecionado no Grid superior
	If !Empty( (_cAliMKB)->PEDIDO )
	    IF lAG87Dire .and. fExistND6((_cAlimkb)->PEDIDO, (_cAlimkb)->ITEM, (_cAlimkb)->SAFRA) // Verificar se vai utilizar Direcionamento do item dos pedido
		    UBSA020C((_cAliMKB)->PEDIDO, (_cAliMKB)->ITEM )
		else
		  ApMsgAlert("Não existe lotes direcionados para o Pedido : " + Alltrim( (_cAlimkb)->PEDIDO) + '-' + allTrim( (_cAlimkb)->ITEM ))
		EndIF
	Else
		ApMsgAlert("Selecione um Pedido para pesquisar os direcionamentos")
	EndIf 
Return .T.

/** {Protheus.doc} AGR870ASLD
Descrição: Retorna a instrução SQL para consulta de saldo e validação dos dados da NJ6
@param: 	Nil
@author: 	Marcelo R. Ferrari
@since: 	18/03/2016
@Uso: 		AGRA970 
*/
Function AGR870ASLD(cCodCar, cSeqCar, lSaldo, lSubSql )
	Local cSql    := ""
	Local cSqlCab := "" 
	Local cSqlCompl := "0"
	Local cDriver := TCGetDB()

	Default lSaldo := .F.
	Default lSubSql := .F.

	If (.NOT.(Empty(cCodCar)) ) .AND. (.NOT.(Empty(cSeqCar)) )
		If cDriver = "MSSQL"
			cSqlCompl := "( SELECT ISNULL( (SELECT SUM(NJ6S.NJ6_QTDE) NJ6_QTDS " + ; 
			" FROM " +RetSqlName("NJ6") +" NJ6S " + ;
			" WHERE NJ6S.NJ6_FILIAL = C9_FILIAL " + ;
			" AND NJ6S.NJ6_NUMPV = C9_PEDIDO " + ;
			" AND NJ6S.NJ6_ITEM = C9_ITEM  " + ;
			" AND NJ6S.NJ6_SEQUEN = C9_SEQUEN " + ;
			" AND NJ6S.NJ6_PRODUT = C9_PRODUTO " + ;
			" AND NJ6S.D_E_L_E_T_ = ' ' ) , 0 ) )"
		ElseIf cDriver = "ORACLE"
			cSqlCompl := "( SELECT NVL( (SELECT SUM(NJ6S.NJ6_QTDE) NJ6_QTDS " + ; 
			" FROM " +RetSqlName("NJ6") +" NJ6S " + ;
			" WHERE NJ6S.NJ6_FILIAL = C9_FILIAL " + ;
			" AND NJ6S.NJ6_NUMPV = C9_PEDIDO " + ;
			" AND NJ6S.NJ6_ITEM = C9_ITEM  " + ;
			" AND NJ6S.NJ6_SEQUEN = C9_SEQUEN " + ;
			" AND NJ6S.NJ6_PRODUT = C9_PRODUTO " + ;
			" AND NJ6S.D_E_L_E_T_ = ' ' ) , 0 ) FROM DUAL )"
		EndIf
	EndIf 	

	If !(lSaldo) 
		cSqlCab += "SELECT DISTINCT NJ6.NJ6_FILIAL, NJ6.NJ6_CODCAR, NJ6.NJ6_NUMPV, NJ6.NJ6_ITEM, NJ6.NJ6_SEQUEN, NJ6.NJ6_PRODUT, NJ6_SEQLT, "
		cSqlCab += " NJ6_LOCAL LOCAL, NJ6_END, NJ6_LOTECT LOTE, NJ6_CULTRA CULTRA,  NJ6_CTVAR CULTVAR, NJ6_CATEG CATEG , NJ6_PENE PENE, "
		cSqlCab += " C6_UM UM, C9_QTDLIB QTDE, "
		If ExistSX3("NJ6_SEQCAR")
			cSqlCab += " NJ6.NJ6_SEQCAR, "
		EndIF
		cSqlCab += " ( C9_QTDLIB - " + cSqlCompl + " ) SALDO  "
		If lSubSql
			cSqlCab += ', NJ6.D_E_L_E_T_ N6DEL '
		EndIf
	Else
		cSqlCab += "SELECT DISTINCT ( C9_QTDLIB - " + cSqlCompl + " ) SALDO  "
	EndIF
	cSql := cSQlCab
	cSql += "FROM " +RetSqlName("SC9") +" SC9 "
	cSql += " INNER JOIN " + RetSqlName("SC6") +" SC6 ON C9_FILIAL = C6_FILIAL AND "
	cSql += "  C9_PEDIDO = C6_NUM AND C9_ITEM = C6_ITEM AND C9_PRODUTO = C6_PRODUTO "

	cSql += " LEFT JOIN " + RetSqlName("NJ5") +" NJ5 ON C9_FILIAL = NJ5_FILIAL AND "
	cSql += " C9_PEDIDO = NJ5_NUMPV AND C9_ITEM = NJ5_ITEM AND " 
	cSql += " C9_SEQUEN = NJ5_SEQUEN AND C9_PRODUTO = NJ5_PRODUT "

	cSql += " LEFT JOIN " + RetSqlName("NJ6") +" NJ6 ON C9_FILIAL = NJ6_FILIAL AND "
	cSql += " C9_PEDIDO = NJ6_NUMPV AND C9_ITEM = NJ6_ITEM AND " 
	cSql += " C9_SEQUEN = NJ6_SEQUEN AND C9_PRODUTO = NJ6_PRODUT "

	cSql += "WHERE 1=1 "
	//cSql += " AND C9_BLEST = ' ' "
	cSql += " AND SC9.C9_BLCRED = ' ' "
	cSql += " AND NJ6.NJ6_FILIAL = '" + fwxFilial("NJ6") + "' "
	cSql += " AND NJ6.NJ6_CODCAR = '" + cCodCar + "' "

	If ExistSX3("NJ6_SEQCAR")
		cSql += " AND NJ6.NJ6_SEQCAR = '" + cSeqCar + "' "
	EndIF

	//cQuery += " AND C9_QTDLIB > " + cSqlCompl
	cSql += " AND SC9.D_E_L_E_T_ = ' ' "	
	cSql += " AND ( ( SC6.D_E_L_E_T_ = ' '   AND SC9.D_E_L_E_T_ = ' '    AND NJ5.D_E_L_E_T_ = ' ' ) " 
	cSql += " OR ( SC6.D_E_L_E_T_ = ' '   AND SC9.D_E_L_E_T_ = ' '    AND NJ5.D_E_L_E_T_ IS NULL ) " 
	cSql += " OR ( SC6.D_E_L_E_T_ = ' ' AND SC9.D_E_L_E_T_ IS NULL  AND NJ5.D_E_L_E_T_ IS NULL ) " 
	cSql += " OR ( SC6.D_E_L_E_T_ = ' '   AND SC9.D_E_L_E_T_ = ' '    AND NJ5.D_E_L_E_T_ = '*' ) " 
	cSql += " OR ( SC6.D_E_L_E_T_ = ' '   AND SC9.D_E_L_E_T_ = '*'    AND NJ5.D_E_L_E_T_ = '*' ) " 
	cSql += " OR ( SC6.D_E_L_E_T_ = ' '   AND SC9.D_E_L_E_T_ = '*'    AND NJ5.D_E_L_E_T_ IS NULL )  )  "	

	If lSubSql
		cSql := "SELECT * FROM ( " + cSql + " ) X1 "
		cSql += "WHERE X1.N6DEL = ' ' "
	EndIf 

Return cSql


Function Agra870aCG(aChave, lPergunta, lDAKChav)
	Local aRet := {}
	Local cCct    := "||"
	Local cCarga := ""
	Local cSql := {}
	Local cDriver := TCGetDB()

	Default lPergunta	:= .T.
	Default lDAKChav	:= .F.

	If cDriver = "MSSQL"
		cCct := "+"  //Caracter de concatenaçao 
	EndIF

	IF lDAKChav
		cSql := "SELECT distinct (C9_CARGA " + cCct + "','" + cCct + " C9_SEQCAR) CARGA "
		cSql += "FROM " + RetSqlName("SC9") + " SC9 "
		cSql += "WHERE 1=1 "
		cSql +=  "AND C9_FILIAL = '" + aChave[1] + "' "
		cSql +=  "AND C9_CARGA  = '" + aChave[2] + "' "
		cSql +=  "AND C9_SEQCAR = '" + aChave[3] + "' "
		cSql +=  "AND SC9.D_E_L_E_T_ = ' ' "
	Else

		cSql := "SELECT distinct (C9_CARGA " + cCct + "','" + cCct + " C9_SEQCAR) CARGA "
		cSql += "FROM " + RetSqlName("SC9") + " SC9 "
		cSql += "INNER JOIN " + RetSqlName("NJ5") + " NJ5 ON C9_FILIAL  = NJ5_FILIAL "
		cSql +=  "AND C9_PEDIDO  = NJ5_NUMPV "
		cSql +=  "AND C9_ITEM    = NJ5_ITEM "
		cSql +=  "AND C9_SEQUEN  = NJ5_SEQUEN "
		cSql +=  "AND C9_PRODUTO = NJ5_PRODUT "
		cSql +=  "AND NJ5.D_E_L_E_T_ = ' ' "
		cSql += "INNER JOIN " + RetSqlName("DAK") + " DAK ON C9_FILIAL  = DAK_FILIAL "
		cSql +=  "AND C9_CARGA   = DAK_COD "
		cSql +=  "AND C9_SEQCAR  = DAK_SEQCAR  "
		cSql +=  "AND DAK.D_E_L_E_T_ = ' ' "
		cSql += "INNER JOIN " + RetSqlName("GWN") + " GWN ON DAK_FILIAL = GWN_FILIAL "
		cSql +=  " AND DAK_COD " + cCct + " DAK_SEQCAR = GWN_NRROM "
		cSql +=  " AND GWN.D_E_L_E_T_ = ' ' "
		cSql += "INNER JOIN " + RetSqlName("GWV") + " GWV ON GWN_FILIAL = GWV_FILIAL "
		cSql +=  "AND GWN_NRROM  = GWV_NRROM "
		cSql +=  "AND GWV.D_E_L_E_T_ = ' ' "
		cSql += "INNER JOIN " + RetSqlName("GX4") + " GX4 ON GWV_FILIAL = GX4_FILIAL "
		cSql +=  "AND GWV_NRMOV  = GX4_NRMOV "
		cSql +=  "AND GX4.D_E_L_E_T_ = ' ' "
		cSql += "INNER JOIN " + RetSqlName("GX5") + " GX5 ON GX4_FILIAL = GX5_FILIAL "
		cSql +=  "AND GX4_NRMOV  = GX5_NRMOV "
		cSql +=  "AND GX4_CDPTCT = GX5_CDPTCT "
		cSql +=  "AND GX5.D_E_L_E_T_ = ' ' "
		cSql += "WHERE 1=1 "
		cSql +=  "AND SC9.D_E_L_E_T_ = ' ' "
		cSql +=  "AND GX4_FILIAL = '" + aChave[1] + "' "
		cSql +=  "AND GX4_NRMOV  = '" + aChave[2] + "' "
		cSql +=  "AND GX4_CDPTCT = '" + aChave[3] + "' "
		cSql +=  "AND GX5_SEQ    = '" + aChave[4] + "' " 
		If lPergunta
			cSql +=  "AND GX5_CDPERG = '" + aChave[5] + "' "
		EndIf
	EndIF
	
	cCarga :=  GetDataSql(cSql) 

	If Empty(cCarga)
		//Não encontrou dados
		//Variáveis de Retorno
		aAdd(aRet, .F. )   //<= 0 Fechou a tela sem confirmar; = 1 FEchou a tela com "Confirmar"
		aAdd(aRet, "") //Código da Ordem de carregamento gravado.
		aAdd(aRet, "") //Código da Ordem de carregamento gravado.
	Else
		aCarga := (StrTokArr(cCarga, ",")) 
		aAdd(aRet, .T.)
		aAdd(aRet, aCarga[1]) 
		aAdd(aRet, aCarga[2])
	EndIF

Return aRet

Function Agra870aEx()
	Local lRet 			:= .T.
	nOpcA := 1

	//Ponto de entrada para validação da tela - Confirmar
	If ExistBlock("AG870AA6")
		lRet := ExecBlock("AG870AA6",.f.,.f.,{_cAliMKB, _cAliMKB2})
	EndIf 	    

	If lRet
		lRet := AGR870AAOK()
	EndIf
	
	//validação para estrutura de Direcionamento de pedido de venda.
	If lRet .AND. lAG87Dire
		lRet := fVldSdND6()
		IF lRet
			lRet := fVldDrND6()
		EndIF
	EndIF
	
Return lRet

//Funcao executana ao cancelar a tela
//Essa função so existe pq. ao clicar em cancelar
//Sistema deixa as Reservas feitas gravadas.
//Então não posso deixar reservas que tenha direcionamento 
//Que não esteja em acordo com a  qt. do lote direcionado
//Recebe a tela para efetuar o End da Mesma

Function Agr870Canc( oDLG )
	Local lRet 			:= .T.


	//validação para estrutura de Direcionamento de pedido de venda.
	If lRet .AND. lAG87Dire
		lRet := fVldSdND6()
		IF lRet   
			lRet := fVldDrND6() // Verificando se um PV NAO DIRECIONADO, não esta utilizando QT. de Direcionada a Outro PV
		EndIF
	EndIF

	IF lRet //Qto ao direcionamento pode sair
	   nOpcA := 0
	   ODlg:End()
	Else 
	   fTopGrid()
	EndIF
	
Return lRet

Static Function FiltraResultados()
	Local aArea := GetArea()
	Local aRet := {}
	Local cTPCampo := ""
	NPW->(dbSetOrder(2))
	NPW->(dbGoTop())
	While NPW->(!Eof()).AND. NPW->NPW_FILIAL = FwxFilial("NPW") 
		If !Empty(NPW->NPW_DESRES) .and. NPW->NPW_INFFIS = "N" .and. !Empty(NPW->NPW_CODTA)
			IF AGRIFDBSEEK("NPU",(NPW->NPW_CODTA + NPW->NPW_CAMPO),1,.F.)
				If 		NPU->NPU_TIPOVA = '1'
					cTPCampo := "NPX_RESNUM"
				Elseif 	NPU->NPU_TIPOVA = '2'
					cTPCampo := "NPX_RESTXT"
				Elseif 	NPU->NPU_TIPOVA = '3'
					cTPCampo := "NPX_RESDTA"
				Endif
				aadd(aRet,{NPW->NPW_CODTA,NPW->NPW_CAMPO,NPW->NPW_DESRES,cTPCampo})
			Endif
		Endif
		NPW->(dbSkip())
	EndDo
	RestArea(aArea)
Return aRet

//Função para verificar se existe registros do Direcionamento liberados para uso
Static Function fExistND6(cCodPV, cItmPV, cSafPV)
	Local lRetND6	:= .F.
	Local cAliasND6	:= GetNextAlias()
	Local aAreaDN6 	:= GetArea()
	
	BeginSQL Alias cAliasND6
		Select COUNT(ND5.ND5_PEDIDO) REGISTRO 
		FROM
			%table:ND5% ND5
		INNER JOIN %table:ND6% ND6 
			ON ND6.%notDel% 						
			AND ND6.ND6_FILIAL	= ND5.ND5_FILIAL 	
			AND ND6.ND6_PEDIDO	= ND5.ND5_PEDIDO
			AND ND6.ND6_ITEMPV	= ND5.ND5_ITEM
			AND ND6.ND6_CODSAF	= %exp:cSafPV%
			AND	ND6.ND6_CODIGO	= ND5.ND5_CODIGO
		WHERE 
			ND5.%notDel%
			AND	ND5.ND5_FILIAL	= %xFilial:ND5%
			AND ND5.ND5_PEDIDO	= %exp:cCodPV%
			AND ND5.ND5_ITEM	= %exp:cItmPV%
			AND ND5.ND5_STATUS	= '1' 
	EndSQL
		
	lRetND6 := ( (cAliasND6)->REGISTRO > 0 )

	(cAliasND6)->(dbclosearea())   
	RestArea(aAreaDN6)
		
Return lRetND6

//Função para validar se o saldo de Direcionamento utilizado está disponivel.
Static Function fVldSdND6()
	Local aAreaDN6	:= GetArea()
	Local lRetVld	:= .T.
	Local cQrySum	:= ""
	Local cAliaSUM	:= GetNextAlias()
	Local nQtUsaND6	:=0
	Local nQtJaEmSel:=0
	Local cMsgErro	:= ""

	cQrySum := 'SELECT CODCAR, SEQCAR, PEDIDO, ITEM, LOTECT, NMLOTE, SUM(QTDE) QUANTIDADE '
	cQrySum += " from "+ oArqTemp2:GetRealName() 
	cQrySum += " GROUP BY CODCAR, SEQCAR,PEDIDO, ITEM, LOTECT,NMLOTE "
	
	MPSysOpenQuery( cQrySum, cAliaSUM )
	DbSelectArea(cAliaSUM)
	while (cAliaSUM)->(!eof()) 
		nQtUsaND6  :=  fQtdeND6((cAliaSUM)->PEDIDO, (cAliaSUM)->ITEM, (cAliaSUM)->LOTECT, (cAliaSUM)->NMLOTE )
		IF  nQtUsaND6 > 0 
		    nQtJaEmSel := fQtJaSel((cAliaSUM)->PEDIDO, (cAliaSUM)->ITEM, (cAliaSUM)->LOTECT,(cAliaSUM)->NMLOTE, (cAliaSUM)->CODCAR,(cAliaSUM)->SEQCAR )
		
		    IF ( ( (cAliaSUM)->QUANTIDADE  + nQtJaEmSel) >  nQtUsaND6 )
				cMsgErro += "Dados Complementares"+CRLF
				cMsgErro += "Pedido.............: "+ (cAliaSUM)->PEDIDO					+CRLF
				cMsgErro += "Item...............: "+ (cAliaSUM)->ITEM					+CRLF
				cMsgErro += "Lote...............: "+ (cAliaSUM)->LOTECT					+CRLF
				cMsgErro += "Qtde Seleção.......: "+ cValToChar((cAliaSUM)->QUANTIDADE)	+CRLF
				cMsgErro += "Qtde Selec.Anterior: "+ cValToChar(nQtJaEmSel)				+CRLF
				cMsgErro += "Qtde Direcionamento: "+ cValToChar(nQtUsaND6)				+CRLF
				cMsgErro += "Qtde DisP.P/Seleção: "+ cValToChar(nQtUsaND6 - nQtJaEmSel)	+CRLF+CRLF
				cMsgErro +=	"A rotina levou em consideração a somatória Pedido+Item+Lote+Qtde
				
				lRetVld := .F.
				Exit
			EndIF
		EndIF
		
		(cAliaSUM)->(dbskip()) 
	Enddo	
		
	IF !Empty(cMsgErro) .AND. !lRetVld
		MsgDtlhe("Inconsistência no Direcionamento", "Ocorreu inconsistência(s) no processo de validação do Direcionamento de Pedido de Venda."+CRLF+;
		   "Clique em 'Detalhes' para visualizar as informações.", cMsgErro)
	EndIF
	(cAliaSUM)->(dbclosearea())  	
	
	RestArea(aAreaDN6)
Return lRetVld

//Função para trazer quantidade de registros já com Direcionamento
Static Function fQtdeND6(cCodPV, cItmPV, cLotePV, cSublot )
	Local nRetND6	:= 0
	Local cAliasND6	:= GetNextAlias()
	Local aAreaDN6 	:= GetArea()
	
	BeginSQL Alias cAliasND6
		Select SUM(ND6.ND6_QT) QUANTIDADE 
		FROM
			%table:ND5% ND5
		INNER JOIN %table:ND6% ND6 
			ON ND6.%notDel% 						
			AND ND6.ND6_FILIAL	= ND5.ND5_FILIAL 	
			AND ND6.ND6_PEDIDO	= ND5.ND5_PEDIDO
			AND ND6.ND6_ITEMPV	= ND5.ND5_ITEM
			AND	ND6.ND6_CODIGO	= ND5.ND5_CODIGO
			AND ND6.ND6_LOTE	= %exp:cLotePV%
			AND ND6.ND6_SUBLOT	= %exp:cSublot%
		WHERE 
			ND5.%notDel%
			AND	ND5.ND5_FILIAL	= %xFilial:ND5%
			AND ND5.ND5_PEDIDO	= %exp:cCodPV%
			AND ND5.ND5_ITEM	= %exp:cItmPV%
			AND ND5.ND5_STATUS	= '1' 
	EndSQL

	nRetND6 := (cAliasND6)->QUANTIDADE

	(cAliasND6)->(dbclosearea())   
	RestArea(aAreaDN6)
		
Return nRetND6


//Função para trazer quantidade de registros do pedido que ja consta seleção de lotes
// proviniente de carregamentos parcias
Static Function fQtJaSel(cCodPV, cItmPV, cLotePV,cSubLot,cCodCar, cSeqCar)

	Local cAliasNJ6	:= GetNextAlias()
	Local nQtEmSelec := 0
	
    //QT do pedido e item do pedido que ja se encontram em outros possiveis carregamentos parciais
	BeginSQL Alias cAliasNJ6
		SELECT SUM(NJ6.NJ6_QTDE) QTEMSELECAO FROM %Table:NJ6% NJ6
			  WHERE NJ6.NJ6_LOTECT 	= %exp:cLotePV% 
				AND NJ6.NJ6_NMLOTE 	= %exp:cSubLot% 
				AND NJ6.NJ6_NUMPV	= %exp:cCodPV%
			    AND NJ6.NJ6_ITEM	= %exp:cItmPV%
				AND ( NJ6.NJ6_CODCAR != %exp:cCodCar% OR NJ6.NJ6_SEQCAR != %exp:cSeqCar% )
				AND NJ6.NJ6_FILIAL 	= %xFilial:NJ6% 
				AND NJ6.%notDel% 
	EndSQL


	nQtEmSelec := (cAliasNJ6)->QTEMSELECAO

	(cAliasNJ6)->(dbclosearea()) 

Return nQtEmSelec

//Função para validar que o lote utilizado não está direcionado para outro cliente
Static Function fVldDrND6()
	Local lRetND6 := .T.
	Local aAreaDN6	:= GetArea()
	Local cQrySum	:= ""
	Local cAliaSUM	:= GetNextAlias()
	
	cQrySum := "SELECT CODCAR, SEQCAR, PEDIDO, ITEM, LOTECT, NMLOTE, UM, SUM(QTDE) QUANTIDADE "
	cQrySum += " from "+ oArqTemp2:GetRealName() + " TMP "
	cQrySum += " Where 1 = 1 "
	cQrySum +=  " AND "
	cQrySum += 	" ( SELECT COUNT(ND5.ND5_PEDIDO) FROM "  +  RetSqlname('ND5') + " ND5 "
	cQrySum += 	" INNER JOIN " + RetSqlname('ND6') + " ND6 "
	cQrySum += 	" 	ON " + RetsqlCond('ND6')
	cQrySum += 	" 	AND ND6.ND6_PEDIDO	= ND5.ND5_PEDIDO "
	cQrySum += 	" 	AND ND6.ND6_ITEMPV	= ND5.ND5_ITEM   "
	cQrySum += 	" 	AND ND6.ND6_CODSAF	= ND5.ND5_CODSAF "
	cQrySum += 	" 	AND	ND6.ND6_CODIGO	= ND5.ND5_CODIGO "

	cQrySum += 	" INNER JOIN " + RetSqlname('SC5') + " SC5 "    //desconsideramos o direcionamento de pedidos Encerrados
    cQrySum += 	" 	ON " + RetsqlCond('SC5')
    cQrySum += 	" 	AND SC5.C5_NUM = ND5.ND5_PEDIDO  
	cQrySum += 	" 	AND NOT ( (SC5.C5_NOTA <> ' ' OR C5_LIBEROK = 'E') AND C5_BLQ = ' ')"

	cQrySum += 	" WHERE  " + RetsqlCond('ND5')
	cQrySum += 	" AND ND5.ND5_PEDIDO	= TMP.PEDIDO "
	cQrySum += 	" AND ND5.ND5_ITEM	    = TMP.ITEM       "
	cQrySum += 	" AND ND5.ND5_STATUS	= '1' ) = 0  "
	cQrySum += " GROUP BY CODCAR, SEQCAR,PEDIDO, ITEM, LOTECT,NMLOTE,UM "
	
	MPSysOpenQuery( cQrySum, cAliaSUM )
	DbSelectArea(cAliaSUM)
	While (cAliaSUM)->(!eof()) 
		lRetND6 := fND6_NJ6((cAliaSUM)->LOTECT, (cAliaSUM)->NMLOTE,(cAliaSUM)->PEDIDO, (cAliaSUM)->ITEM,(cAliaSUM)->QUANTIDADE, (cAliaSUM)->UM)
		IF !lRetND6
			Exit
		EndIF	
		(cAliaSUM)->(dbskip()) 
	Enddo	
		
	(cAliaSUM)->(dbclosearea())  	
	
	RestArea(aAreaDN6)
Return lRetND6

//Função para trazer o saldo dentro da tabela SB8/NP9
Static Function fSB8_NJ6( cLotePV, cPv, cItemPV,cUM )
	Local cAlSB8NJ6	:= GetNextAlias()
	Local aArSB8NJ6	:= GetArea()
	Local nQtdSB8	:= 0
	Local lEmpPrev  := IIF(SuperGetMV("MV_QTDPREV")== "S",.T.,.F.)

	BeginSQL Alias cAlSB8NJ6

		SELECT NP9_PROD, NP9_UM, SB8.B8_LOCAL
		FROM %Table:SB8% SB8
			INNER JOIN %table:NP9% NP9 
				ON NP9.%notDel%
				AND NP9.NP9_FILIAL = %xFilial:NP9%  
				AND  NP9.NP9_LOTE = SB8.B8_LOTECTL 
				AND NP9.NP9_PROD = SB8.B8_PRODUTO
		Where NP9.%notDel%
		AND SB8.B8_FILIAL	= %xFilial:NP9%
		AND SB8.B8_LOTECTL	= %exp:cLotePV%
		AND NP9.NP9_UM      = %exp:cUM%
		//AND NP9.NP9_CODSAF  = %exp:cSafraPV% //NJ6 ( NÃO TEM SAFRA )
	EndSQL
	
	dbSelectArea("SB8")
	SB8->(dbSetOrder(3)) //B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL
	while (cAlSB8NJ6)->(!eof()) 
	
		IF SB8->(dbSeek(xFilial("SB8")+(cAlSB8NJ6)->NP9_PROD+(cAlSB8NJ6)->B8_LOCAL+cLotePV))
			nQtdSB8 += SB8Saldo(.F.,!Empty(cLotePV),NIL,NIL,NIL,lEmpPrev,NIL,ddatabase,)
		EndIF
		
		(cAlSB8NJ6)->(dbskip())
	EndDo
	
	(cAlSB8NJ6)->(dbclosearea())  	
	
	RestArea(aArSB8NJ6)
	
Return nQtdSB8


//Função para trazer o saldo dentro da tabela ND6
Static Function fND6_NJ6(cLotePV, cSubLote, cPv, cItemPV, nQtSelecPV, cUM )
	Local lND6NJ6	:= .T.
	Local cAlND6NJ6	:= GetNextAlias()
	Local aArND6NJ6	:= GetArea()
	Local nSaldoSB8	:= fSB8_NJ6(cLotePV,cPv, cItemPV,cUM )
	Local nQtdND6	:= 0
	Local nQtdSC0	:= 0
	Local nQtdSC9	:= 0
	Local cMsgErro	:= ""

	BeginSQL Alias cAlND6NJ6
	
		select ND5.ND5_PEDIDO, ND5.ND5_ITEM, ND6_LOTE LOTE, SUM(ND6_QT) QUANTIDADE
		from %table:ND5% ND5
		INNER JOIN %table:ND6% ND6 
			ON ND6.%notDel% 	
		   AND ND6.ND6_CODIGO = ND5.ND5_CODIGO 
		   AND ND6.ND6_FILIAL = ND5.ND5_FILIAL 
		   AND ND6.ND6_PEDIDO = ND5.ND5_PEDIDO
		   AND ND6.ND6_ITEMPV = ND5.ND5_ITEM
		   AND ND6.ND6_CODSAF = ND5.ND5_CODSAF 
		   AND ND6.ND6_LOTE	  = %exp:cLotePV%
		   AND ND6.ND6_SUBLOT = %exp:cSubLote%
		INNER JOIN %Table:SC5% SC5    //desconsideramos o direcionamento de pedidos Encerrados
    		ON SC5.%notDel%
    		AND SC5.C5_FILIAL = %xFilial:SC5%
    		AND SC5.C5_NUM = ND6.ND6_PEDIDO  
			AND NOT ( (SC5.C5_NOTA <> ' ' OR C5_LIBEROK = 'E') AND C5_BLQ = ' ')
		WHERE ND5.%notDel%
		AND ND5.ND5_FILIAL 	= %xFilial:ND5%
		AND ND5.ND5_STATUS	= '1'
		AND ND5.ND5_UM      = %EXP:cUM%
	    AND ( ND5.ND5_PEDIDO != %exp:cPV% OR ND5.ND5_ITEM != %EXP:cItemPV% )
		GROUP BY ND5.ND5_PEDIDO, ND5.ND5_ITEM, ND6.ND6_LOTE
	EndSQL

	
	while (cAlND6NJ6)->(!eof()) 
		 nQtdND6	+= (cAlND6NJ6)->QUANTIDADE
		(cAlND6NJ6)->(dbskip())
	EndDo

	(cAlND6NJ6)->(dbclosearea()) 

	//Buscando qtidades de direcionamento que estão em status de substituir onde os pedidos são excluidos
	BeginSQL Alias cAlND6NJ6
	
		select ND5.ND5_PEDIDO, ND5.ND5_ITEM, ND6_LOTE LOTE, SUM(ND6_QT) QUANTIDADE
		from %table:ND5% ND5
		INNER JOIN %table:ND6% ND6 
			ON ND6.%notDel% 	
		   AND ND6.ND6_CODIGO = ND5.ND5_CODIGO 
		   AND ND6.ND6_FILIAL = ND5.ND5_FILIAL 
		   AND ND6.ND6_PEDIDO = ND5.ND5_PEDIDO
		   AND ND6.ND6_ITEMPV = ND5.ND5_ITEM
		   AND ND6.ND6_CODSAF = ND5.ND5_CODSAF 
		   AND ND6.ND6_LOTE	  = %exp:cLotePV%
		   AND ND6.ND6_SUBLOT = %exp:cSubLote%
		WHERE ND5.%notDel%
		AND ND5.ND5_FILIAL = %xFilial:ND5%
		AND ND5.ND5_STATUS	= '3'   //direcionamento em status de 
		AND ND5.ND5_UM      = %EXP:cUM%
	    AND ( ND5.ND5_PEDIDO != %exp:cPV% OR ND5.ND5_ITEM != %EXP:cItemPV% )
		GROUP BY ND5.ND5_PEDIDO, ND5.ND5_ITEM, ND6.ND6_LOTE
	EndSQL
	
	while (cAlND6NJ6)->(!eof()) 
		 nQtdND6	+= (cAlND6NJ6)->QUANTIDADE
		(cAlND6NJ6)->(dbskip())
	EndDo

	nQtdSC0	+= fSC0_NJ6(cLotePV, cSubLote, cPV, cItemPV,cUM)
	nQtdSC9	+= fSC9_NJ6(cLotePV, cSubLote, cPV, cItemPV,cUM)	
		  
	
	(cAlND6NJ6)->(dbclosearea())   
	
	//Add a Qt selecionada do PV pois a NJ6/SC0 ja esta gravada consumindo saldo da sb8
	//( SB8 + nQtSelecPV )	- (ND6 - C0 - C9)
	lND6NJ6:= IIF(( nSaldoSB8  - (nQtdND6 - nQtdSC0 - nQtdSC9)) >= 0, .T. ,.F.)
	
	IF !lND6NJ6
		cMsgErro += "Pedido Selecionado....: "+  cPV + "/" + cItemPv	+CRLF
		cMsgErro += "Lote..................: "+  cValToChar(cLotePV)	+CRLF
		cMsgErro += "Qtd. do Lote no Pedido: "+  cValToChar(nQtSelecPV)	+CRLF
		cMsgErro += "Saldo Lote............: "+  cValToChar(nSaldoSB8+nQtSelecPV)	+CRLF  //Add a Qt selecionada do PV pois a NJ6/SC0 ja esta gravada consumindo saldo da sb8
		cMsgErro += "Qtd. Direc. Lote......: "+  cValToChar(nQtdND6)	+CRLF
		cMsgErro += "Qtd. Direc. em Reserva: "+  cValToChar(nQtdSC0)	+CRLF
		cMsgErro += "Qtd. Direc. em Faturam: "+  cValToChar(nQtdSC9)	+CRLF
		cMsgErro += "Saldo disponivel......: "+  cValToChar((nSaldoSB8 + nQtSelecPV) - (nQtdND6 - nQtdSC0 - nQtdSC9) )	+CRLF+CRLF
		cMsgErro +=	"A rotina levou em consideração a Formula: Saldo Lote - (Qtd. Direc. Lote - Qtd. Direc. em Reserva - Qtd. Direc. Em Faturam)
		
		MsgDtlhe("Inconsistência no Direcionamento", "Existe lote informado no processo de seleção de lote que encontra-se sem saldo disponivel."+CRLF+;
		   "Clique em 'Detalhes' para visualizar as informações.", cMsgErro)	
	
	EndIF
	
	RestArea(aArND6NJ6)
		
Return lND6NJ6

//Função para trazer o saldo dentro da tabela SC0
Static Function fSC0_NJ6(cLotePV, cSubLote, cCodPV, cItemPV,cUM)
	Local nSC0NJ6	:= 0
	Local cAlSC0NJ6	:= GetNextAlias()
	Local aArSC0NJ6	:= GetArea()
	
	BeginSQL Alias cAlSC0NJ6

		SELECT SUM(C0_QUANT) QUANTIDADE
		from %table:SC0% SC0

			INNER JOIN %Table:NJ6% NJ6
				ON NJ6.NJ6_RESERV  = SC0.C0_NUM 
				AND NJ6.NJ6_NMLOTE = SC0.C0_NUMLOTE
				AND NJ6.NJ6_LOTECT = SC0.C0_LOTECTL
				AND NJ6.NJ6_FILIAL = %xFilial:NJ6% 
				AND ( NJ6.NJ6_NUMPV != %exp:cCodPV% OR NJ6.NJ6_ITEM != %exp:cItemPV% )
				AND NJ6.%notDel%'
			INNER JOIN %Table:ND5%  ND5
				ON  ND5.ND5_PEDIDO = NJ6.NJ6_NUMPV
				AND ND5.ND5_ITEM   = NJ6.NJ6_ITEM
				AND ND5.ND5_STATUS = '1'
				AND ND5.ND5_FILIAL = %xFilial:ND5% 
				AND ND5.ND5_UM     = %exp:cUM% 
				AND ND5.%notDel%
			INNER JOIN %Table:ND6%  ND6
				ON  ND6.ND6_CODIGO = ND5.ND5_CODIGO
				AND ND6.ND6_LOTE   = NJ6.NJ6_LOTECT
                AND ND6.ND6_SUBLOT =NJ6.NJ6_NMLOTE
				AND ND6.ND6_FILIAL = %xFilial:ND6% 
				AND ND6.%notDel%
			INNER JOIN %Table:SC5% SC5    //desconsideramos o direcionamento de pedidos Encerrados
    			ON SC5.%notDel%
    			AND SC5.C5_FILIAL = %xFilial:SC5%
    			AND SC5.C5_NUM = ND6.ND6_PEDIDO  
				AND NOT ( (SC5.C5_NOTA <> ' ' OR C5_LIBEROK = 'E') AND C5_BLQ = ' ')
		WHERE SC0.%notDel% 
		AND SC0.C0_FILIAL = %xFilial:SC0%
		AND SC0.C0_TIPO = 'CL'
		AND SC0.C0_LOTECTL = %exp:cLotePV%
		AND SC0.C0_NUMLOTE = %exp:cSubLote%
	EndSQL
	
	nSC0NJ6 := (cAlSC0NJ6)->QUANTIDADE

	(cAlSC0NJ6)->(dbclosearea())   
	RestArea(aArSC0NJ6)
		
Return nSC0NJ6

//Função para trazer o saldo dentro da tabela SC9
Static Function fSC9_NJ6(cLotePV, cSubLote, cCodPV,cItemPV,cUM)
	Local nSC9NJ6	:= 0
	Local cAlSC9NJ6	:= GetNextAlias()
	Local aArSC9NJ6	:= GetArea()
	
	BeginSQL Alias cAlSC9NJ6

		SELECT SUM(C9_QTDLIB) QUANTIDADE
		FROM %table:SC9% SC9
		INNER JOIN %table:ND5% ND5 
				ON ND5.%notDel% 
			   AND ND5.ND5_FILIAL = %xFilial:ND5%
			   AND ND5.ND5_STATUS = '1'
			   //AND ND5.ND5_CODSAF = %exp:cSafraPV%
			   AND ND5.ND5_PEDIDO = SC9.C9_PEDIDO
			   AND ND5.ND5_ITEM   = SC9.C9_ITEM
			   AND ND5.ND5_UM     = %exp:cUM%
		INNER JOIN %table:ND6% ND6 
				ON ND6.%notDel% 
			   AND ND6.ND6_CODIGO = ND5.ND5_CODIGO 
			   AND ND6.ND6_FILIAL = ND5.ND5_FILIAL 
			   AND ND6.ND6_PEDIDO = ND5.ND5_PEDIDO
			   AND ND6.ND6_ITEMPV = ND5.ND5_ITEM
			   AND ND6.ND6_CODSAF = ND5.ND5_CODSAF 
			   AND ND6.ND6_LOTE = %exp:cLotePV%
			   AND ND6.ND6_SUBLOT = %exp:cSubLote%
		INNER JOIN %Table:SC5% SC5    //desconsideramos o direcionamento de pedidos Encerrados
    			ON SC5.%notDel%
    			AND SC5.C5_FILIAL = %xFilial:SC5%
    			AND SC5.C5_NUM = ND6.ND6_PEDIDO  
				AND NOT ( (SC5.C5_NOTA <> ' ' OR C5_LIBEROK = 'E') AND C5_BLQ = ' ')
		WHERE SC9.%notDel% 
		AND C9_FILIAL = %xFilial:SC9%
		AND C9_BLEST <> '02'
		AND ( C9_PEDIDO != %exp:cCodPV% OR C9_ITEM != %exp:cItemPV% )
		AND   //Disconsidero se existe sc9 com reserva referenciada  que ainda não foi deletada.
				( SELECT COUNT (SC0.C0_NUM) FROM  %Table:SC0% SC0
				WHERE SC0.%notDel%
				AND   SC0.C0_NUM = SC9.C9_RESERVA
				AND   SC0.C0_FILIAL = %xFilial:SC0% 
				) = 0 
		GROUP BY C9_LOTECTL

	EndSQL
	
	nSC9NJ6 := (cAlSC9NJ6)->QUANTIDADE

	(cAlSC9NJ6)->(dbclosearea())   
	RestArea(aArSC9NJ6)
		
Return nSC9NJ6


//Função para disparar mensagem com detalhes.
//cTitulo - Titulo da Tela de Abertura
//cMensagem - Mensagem que será apresentada na tela sem o detalhe
//cDetalhe - Mensagem que será apresentada ao clicar em detalhe, geralmente será um bloco de texto.
Static Function MsgDtlhe(cTitulo, cMensagem, cDetalhe)
	Local oDlgII				:= Nil
	Local oFntTit				:= Nil
	Local oFntMsg				:= Nil
	Local oMsgDet				:= Nil
	Local lTelaDetalhe			:= .F.
	Local lExibeBotaoDetalhe	:= .T.

	Default cTitulo		:= 'Mensagem de Integração' 
	Default cMensagem 	:= ''
	Default cDetalhe 	:= ''

	If Empty(cDetalhe)
		lExibeBotaoDetalhe := .F.
	EndIf

	DEFINE MSDIALOG oDlgII TITLE cTitulo FROM 0,0 TO 130,600 PIXEL 

	DEFINE FONT oFntTit NAME "Arial"  SIZE 6,16	BOLD
	DEFINE FONT oFntMsg NAME "Courier new"  SIZE 7,15

	//@ 0,0  BITMAP oBmp RESNAME "LOGIN" oF oDlgII SIZE 100,600 NOBORDER WHEN .F. PIXEL 
	@05,03 TO 45,295 PROMPT 'Informação' PIXEL
	@13,05 GET cMensagem FONT oFntMsg MULTILINE NOBORDER READONLY HSCROLL SIZE 288,30 PIXEL

	@50,200 BUTTON 'OK' PIXEL ACTION oDlgII:End() // "OK"

	If lExibeBotaoDetalhe
		@50,230 BUTTON 'Detalhes' PIXEL ACTION If(	!lTelaDetalhe,;  // "Detalhes"
		(oDlgII:ReadClientCoors(.T.),oDlgII:Move(oDlgII:nTop,oDlgII:nLeft,oDlgII:nWidth,oDlgII:nHeight+165,,.T.),lTelaDetalhe:=.T.),;
		(oDlgII:ReadClientCoors(.T.),oDlgII:Move(oDlgII:nTop,oDlgII:nLeft,oDlgII:nWidth,oDlgII:nHeight-165,,.T.),lTelaDetalhe:=.F.))		
		@ 67,03 TO 140,295 PROMPT "Detalhes da informação:" PIXEL
		@ 75,05 GET oMsgDet VAR cDetalhe FONT oFntMsg MULTILINE NOBORDER READONLY HSCROLL SIZE 288,63 PIXEL
	EndIf

	oDlgII:lEscClose	:= .F. //Nao permite sair ao se pressionar a tecla ESC.
	oDlgII:lCentered	:= .T.
	oDlgII:Activate(,,,.T.)
	//ACTIVATE MSDIALOG oDlgII CENTERED

Return .T.

//Função para disparar o Top das grid
Static Function fTopGrid()

	DbSelectArea(_cAliMKB)
	(_cAliMKB)->(dbGoTop())
	If !Empty(oMark)
		oMark:oBrowse:Refresh()
	EndIf
	
	DbSelectArea(_cAliMKB2)
	(_cAliMKB2)->(dbGoTop())
	If !Empty(oGetDb)
		oGetDb:ForceRefresh()
	EndIf	
	
Return .T.

//Função que encontra a germinação e transforma em instrução SQL
static  function fGetGerm()

Local nI	:= 0
Local aOpc	:= {}

Local clista    := SUPERGETMV("MV_AGRO051",.F.,"1=Indefinido;2=80-84;3=85-100;4=90-100")
Local cListAux  := ''
Local aOpc		:= {}
Local nI		:= 0
Local lReturn	:= .f.

Local cAux		:= ''
Local cAux1		:= ''

aOpc		:=	Separa(cLista,";")

cCase := ""

For Ni = 1 TO Len ( aOpc )
    
	cAux :=	SUBSTR( aOpc[nI] , 1 , AT("=" ,aOpc[nI] )-1  )

	cAux1 :=	SUBSTR( aOpc[nI] , 3 , length(Alltrim( aOpc[nI] ))-1  )

    IF Empty(cCase)
	   cCase:=" CASE "
	EndIF  
	
	cCase += " WHEN C6_GERMINA = '" + cAux + "' THEN '" + cAux1 + "'"

next Ni

IF !EMPTY( cCASE )
  cCase += " ELSE '  ' END AS GERMIN " 
EndIF

Return ( cCase )

//Retorna a Germinação a Filtrar
//Função resposnavel por filtrar germinação
user function FiltrGer( cOpcGerm )

Local nI	:= 0
Local aOpc	:= {}

Local clista    := SUPERGETMV("MV_AGRO051",.F.,"1=Indefinido;2=80-84;3=85-100;4=90-100")

Local aOpc		:= {}
Local nI		:= 0


Local cAux		:= ''
Local cAux1		:= ''

Local cIniFiltro 	:= '' 
Local cFimFiltro 	:= ''
Local cOpc			:= ''
Local cFiltroGer    := ''

aOpc		:=	Separa(cLista,";")

cOpc := ''

For Ni = 1 TO Len ( aOpc )
	cOpc := SUBSTR( aOpc[nI] , 1 , AT("=" ,aOpc[nI] )-1  )

	IF Alltrim (cOpc) == cOpcGerm
		IF "INDEFINIDO" $ Alltrim( UPPER( AOPC[nI] ) )
			cFiltroGer	:= ""
		Else
			cAux := SUBSTR( aOpc[nI] , AT("=" ,aOpc[nI] )+1, Len(aOpc[nI] )   )
			cAux1:=SUBSTR( cAux , AT("-" ,cAux )+1, Len(cAux )   )
			cAux:= SUBSTR( cAux , 1, AT("-" ,cAux )-1   )
			
			cIniFiltro := cAux
			cFimFiltro := cAux1
			
			cFiltroGer	:= '(cQryAlias)->C6_GERMINA >= ' + cinifiltro 
			cFiltroGer   += ".OR. (cAliasQry)->C6_GERMINA <=" + cFimFiltro
		EndIF
		
		Exit
	EndIF	
next Ni

return  cfiltroger


//Retorna se a germinação esta dentro da faixa de germinação especificada no lote.
Function GermNaFaix( cOpcGerm, cLote, cCodSaf )

Local nI	:= 0
Local aOpc	:= {}

Local clista    := SUPERGETMV("MV_AGRO051",.F.,"1=Indefinido;2=80-84;3=85-100;4=90-100")

Local aOpc		:= {}
Local nI		:= 0


Local cAux		:= ''
Local cAux1		:= ''

Local cIniFiltro 	:= '' 
Local cFimFiltro 	:= ''
Local cOpc			:= ''
Local cFiltroGer    := ''

Local cQryNpx		:= GetNextAlias()
Local nGermLote     := 0
Local lRet          := .t.

aOpc		:=	Separa(cLista,";")

cOpc := ''

For Ni = 1 TO Len ( aOpc )
	cOpc := SUBSTR( aOpc[nI] , 1 , AT("=" ,aOpc[nI] )-1  )

	IF Alltrim (cOpc) == cOpcGerm
		IF "INDEFINIDO" $ Alltrim( UPPER( AOPC[nI] ) )
			lret :=.t.
		Else //
			cAux := SUBSTR( aOpc[nI] , AT("=" ,aOpc[nI] )+1, Len(aOpc[nI] )   )
			cAux1:=SUBSTR( cAux , AT("-" ,cAux )+1, Len(cAux )   )
			cAux:= SUBSTR( cAux , 1, AT("-" ,cAux )-1   )
			
			cIniFiltro := cAux
			cFimFiltro := cAux1
			

			BeginSQL Alias cQryNpx
			SELECT NPX_RESNUM
				FROM %Table:NPX% NPX
					INNER JOIN %Table:NPU% NPU 
						ON  NPU.%notDel%
						AND NPU.NPU_CODTA = NPX. NPX_CODTA 
						AND NPU.NPU_CODVA = NPX.NPX_CODVA 
						AND NPU.NPU_FILIAL = %xFilial:NPU% 
				WHERE NPX.NPX_FILIAL = %xFilial:NPX% 
				AND NPX.NPX_CODSAF =%exp:cCodsaf%
				AND NPX.NPX_LOTE = %exp:cLote%
				AND NPX.%notDel%
				AND NPX.NPX_ATIVO='1'
				AND NPU.NPU_TPRES = '1'  //Indica que a variavel se refere a um resultado de germinação
			EndSQL

			nGermLote := (cQryNpx)->NPX_RESNUM
			( cQryNpx )->( DbCloseArea() )

			cFiltroGer	:= 'nGermLote >= ' + cinifiltro 
			cFiltroGer  += ".and. nGermLote <=" + cFimFiltro

			IF &(cFiltroGer)
				lret := .t.
			Else
				lret := .f.
			EndIf
	
		EndIF
		
		Exit
	EndIF	
next Ni

return  lRet
