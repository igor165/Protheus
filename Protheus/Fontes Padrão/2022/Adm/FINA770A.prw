#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'FINA770A.ch'

Static cF770Als		:= ''
Static aSelFil		:= {}
Static __aCposSE1  	:= {}

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA770A
Processo do SERASA

@author lucas.oliveira

@since 12/06/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Function FINA770A(oSelf)

Local lRet				:= .T.

//Carrega static de dicionario 
__aCposSE1 := F770Browse()

If DTOS(MV_PAR03) > DTOS(MV_PAR04)
	Help( " ", 1, "F770ADATE",, STR0001, 1, 0 ) //A data final não pode ser menor que a data inicial.
	lRet := .F.
Else
	lRet := FWExecView( STR0002 , "FINA770A", 3, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/ )
EndIf

FwFreeArray(__aCposSE1)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@author lucas.oliveira
@since 12/06/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel	:= Nil
Local oStruSE1	:= FWFormStruct(1,"SE1")
Local oMaster	:= FwFormModelStruct():New()
Local nX		:= 0

oModel := MPFormModel():New("FINA770A",/*PreValidacao*/,{|oModel| F770PosVld(oModel)},{|oModel| F770Grava(oModel)})

oStruSE1:AddField(	"",; //Título do campo
					"",; //cToolTip
					"E1_MARK",;// Id do Campo
					"L",; //cTipo
					1,; //Tamanho do Campo	
					0)//Decimal

oStruSE1:AddField(	STR0003,; //Título do campo
					"",; //cToolTip
					"E1_OBS",;// Id do Campo
					"C",; //cTipo
					40,; //Tamanho do Campo	
					0)//Decimal

oStruSE1:AddField(	STR0004,; //Título do campo
					"",; //cToolTip
					"E1_SALDO",;// Id do Campo
					"N",; //cTipo
					16,; //Tamanho do Campo	
					2,;//Decimal
					{||.F.},;//
					{||.F.})//
					
oMaster:AddTable('XXX',,'TAB_GOST') 
oMaster:AddField(	STR0006,; //Título do campo
					"",; //cToolTip
					"CPOVIRTUAL",;// Id do Campo
					"C",; //cTipo
					1,; //Tamanho do Campo	
					0,,,,,{|| "1"})//Decimal

oModel:AddFields("MASTER", /*cOwner*/, oMaster, /*bPreVld*/, /*bPosVld*/, /*bLoad*/)
oModel:SetDescription(STR0007)
oModel:AddGrid("TITULO", "MASTER", oStruSE1)
oModel:GetModel('MASTER'):SetPrimaryKey({})

oStruSE1:SetProperty( "*" , MODEL_FIELD_OBRIGAT, .F.)

For nX := 1 To Len(__aCposSE1)
	If __aCposSE1[nX][1] != "E1_OBS"
		oStruSE1:SetProperty( __aCposSE1[nX][1] , MODEL_FIELD_WHEN, {||.F.})
	EndIf
Next nX

oModel:SetVldActivate( {|oModel| F770ValLoad(oModel) } )
oModel:SetActivate( {|oModel| F770ALoad(oModel) } )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface
@author lucas.oliveira
@since 12/06/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel	:= FWLoadModel("FINA770A")
Local oView		:= FWFormView():New()
Local oStruSE1
Local nY        
Local cCposSE1  := ""

For nY := 1 To Len(__aCposSE1)
	cCposSE1 += __aCposSE1[nY][1] + "|"
Next

oStruSE1	:= FWFormStruct(2, "SE1", { |cCmp| Alltrim(cCmp) $ cCposSE1 })

oStruSE1:AddField(	"E1_MARK",; //Id do Campo
					"01",; //Ordem
					"",;// Título do Campo
					"",; //Descrição do Campo
					{},; //aHelp
					"L",; //Tipo do Campo	
					"")//cPicture

oStruSE1:AddField(	"E1_OBS",; //Id do Campo
					"15",; //Ordem
					STR0003,;// Título do Campo
					STR0003,; //Descrição do Campo
					{},; //aHelp
					"C",; //Tipo do Campo	
					"@!")//cPicture

oStruSE1:AddField(	"E1_SALDO",; //Id do Campo
					"13",; //Ordem
					STR0004,;// Título do Campo
					STR0005,; //Descrição do Campo
					{},; //aHelp
					"N",; //Tipo do Campo	
					"@E 9,999,999,999,999.99")//cPicture

oView:SetModel(oModel)
oView:AddGrid("VIEW_SE1", oStruSE1, "TITULO")
oView:CreateHorizontalBox("BOXSE1"	, 90)
oView:CreateHorizontalBox("BOXBOT"	, 10)
oView:SetOwnerView("VIEW_SE1","BOXSE1")
oView:EnableTitleView( "VIEW_SE1", STR0002 )
oView:AddOtherObject("btnMarcaDesm", { |oPanel, oView| F770ABotao(oPanel,oView) })
oView:SetOwnerView("btnMarcaDesm",'BOXBOT')

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} F770ValLoad
Valida da carga de dados dos títulos que serão selecionados para envio ao SERASA.

@author marylly.araujo
@since  08/02/2016
@version 12.1.11
/*/
//-------------------------------------------------------------------
Function F770ValLoad(oModel AS OBJECT) AS LOGICAL
LOCAL oSE1 AS OBJECT
LOCAL lRet AS LOGICAL
LOCAL nTotal AS NUMERIC

oSE1 := oModel:GetModel('TITULO')
lRet := .T.
nTotal := 0

//Seleciona filiais
If MV_PAR11 == 1
	aSelFil := AdmGetFil(,.T.,'SE1')
EndIf

cF770Als := F770AQuery()

If (cF770Als)->(Eof())
	Help(" ",1,"RECNO")
	lRet := .F.
EndIf

dbSelectArea(cF770Als)

/* Contagem dos registros retornados pela query de dados */
COUNT to nTotal

If nTotal > oSE1:GetMaxLines()
	Help( ,,"F770LIM",, STR0023 + CVALTOCHAR((nTotal-2000)) + STR0024 + CRLF + STR0025, 1, 0 ) // "Limite de 2000 títulos para geração do lote do SERASA foi ultrapassado em " //" títulos." //"Faça um novo filtro para geração do lote."
	lRet := .F.
EndIf

RETURN lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F770ALoad
Atribui valor dos títulos para os campos da Grid a serem selecionados.

@author lucas.oliveira
@since  26/06/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Function F770ALoad(oModel AS OBJECT) AS LOGICAL
LOCAL cAliasSE1 AS CHARACTER
LOCAL aStruct AS ARRAY
LOCAL oMaster AS OBJECT	 
LOCAL oSE1 AS OBJECT
LOCAL nLen AS NUMERIC
LOCAL nY AS NUMERIC

cAliasSE1 := F770AQuery()
aStruct := (cAliasSE1)->(dbStruct())
oMaster := oModel:GetModel('MASTER')
oSE1 := oModel:GetModel('TITULO')
nLen := Len(__aCposSE1)
nY := 0

oMaster:LoadValue("CPOVIRTUAL", "0")

DbSelectArea(cAliasSE1)
(cAliasSE1)->(DbGoTop())

While !(cAliasSE1)->(Eof())

    // A primeira Linha está presente na criação do Grid
    If !oSe1:IsEmpty()
        oSE1:AddLine()
        oSE1:GoLine(oSE1:Length())
    ENDIF
    
    For nY := 1 to nLen
        If aScan( aStruct, { |x| AllTrim(x[1]) == AllTrim(__aCposSE1[nY][1]) }) > 0
            If(__aCposSE1[nY][3] == 'D')
                oSE1:LoadValue(__aCposSE1[nY][1], StoD((cAliasSE1)->&(__aCposSE1[nY][1])))			
            Else
                oSE1:LoadValue(__aCposSE1[nY][1], (cAliasSE1)->&(__aCposSE1[nY][1]))	
            Endif
        EndIF
    Next	

    (cAliasSE1)->(DbSkip())

Enddo

RETURN .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} F770AQuery
Processo do SERASA

@author lucas.oliveira

@since 12/06/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Function F770AQuery()
Local cQuery	:= ""
Local cSE1_FWA	:= ""
Local cAliasSE1	:= GetNextAlias()
Local cFil		:= ""
Local nY		:= 0
Local aSituaca	:= StrTokArr(AllTrim(MV_PAR10) ,",")
Local cSitOK	:= ""
Local cSitNO	:= ""
Local cComp		:= "" 	
Local cSepNeg   := If("|"$MV_CRNEG,"|",",")
Local cSepProv  := If("|"$MVPROVIS,"|",",")
Local cSepRec   := If("|"$MVRECANT,"|",",")
Local cTmpFil	:= ''
Local aTmpFil	:= {}
Local cQrySE1	:= ''

For nY := 1 to Len(__aCposSE1)
	If Alltrim(__aCposSE1[nY][1]) != "E1_OBS"		
		cQrySE1 += __aCposSE1[nY][1] + ","
	Endif
Next

//Trato os dados das situações de cobrança a serem utlizadas na busca
// e verifico se a mesma permite envio ao Serasa
FW2->(DbSetOrder(1))
//Se informado alguma situação de cobrança
If !Empty(aSituaca)
	For nY := 1 To Len(aSituaca)
		If FW2->(DbSeek(xFilial("FW2")+ AllTrim(aSituaca[nY]) +"0012"))
			//Situções de cobrança com bloqueio
			cSitNO += "'"+ StrTran(AllTrim(aSituaca[nY]),"'","") +"',"
		Else
			//Situções de cobrança sem bloqueio
			cSitOK += "'"+ StrTran(AllTrim(aSituaca[nY]),"'","") +"',"
		EndIf
	Next nY	
Else
	FRV->(DbSetOrder(1))
	While !FRV->(EOF())
		If FW2->(DbSeek(xFilial("FW2")+ FRV->FRV_CODIGO +"0012"))
			//Situções de cobrança com bloqueio
			cSitNO += "'"+ FRV->FRV_CODIGO +"',"
		Else
			//Situções de cobrança sem bloqueio
			cSitOK += "'"+ FRV->FRV_CODIGO +"',"
		EndIf
		FRV->(DbSkip())
	EndDo
	FRV->(DbGoTop())
EndIf

//Trato as strings para utiliza-las na query
cSitOK := Substr(cSitOK, 1, Len(cSitOK) - 1 )
cSitNO := Substr(cSitNO, 1, Len(cSitNO) - 1 )

//Filiais selecionadas.
If !Empty(aSelFil)
	cFil := "SE1.E1_FILIAL " + GetRngFil( aSelFil, 'SE1', .T., @cTmpFil )
	aAdd(aTmpFil,cTmpFil)
Else
	cFil := "SE1.E1_FILIAL = '"+ FWxFilial("SE1") +"'"
EndIf

//Filtra os títulos e cria campo virtual
cQuery := " SELECT '  ' E1_OBS," + Substr(cQrySE1,1,Len(cQrySE1)-1)
cQuery += " FROM "+ RetSqlName("SE1") +" SE1 "
cQuery += " WHERE "+ cFil +" AND "

//Irá compor o filtro dos títulos, verificando a existencia de SE1 na FWA
cSE1_FWA += " SELECT FWA.FWA_FILIAL,FWA.FWA_PREFIX,FWA.FWA_NUM,FWA.FWA_PARCEL,FWA.FWA_TIPO,FWA.FWA_CLIENT,FWA.FWA_LOJA"
cSE1_FWA += " FROM "+ RetSqlName("FWA") +" FWA"
cSE1_FWA += " WHERE FWA.FWA_FILIAL = '" + FWxFilial("FWA") + "'"
cSE1_FWA += " AND SE1.E1_PREFIXO = FWA_PREFIX"
cSE1_FWA += " AND SE1.E1_NUM = FWA_NUM"
cSE1_FWA += " AND SE1.E1_PARCELA = FWA_PARCEL"
cSE1_FWA += " AND SE1.E1_TIPO = FWA_TIPO"
cSE1_FWA += " AND SE1.E1_CLIENTE = FWA_CLIENT"
cSE1_FWA += " AND SE1.E1_LOJA = FWA_LOJA"
cSE1_FWA += " AND FWA.D_E_L_E_T_ = ' ' "

If MV_PAR01 == 1//Inclusão
	
	If MV_PAR02 == 1//Normal
				
		cQuery += "( "
		//Contas a Receber (SE1) com saldo que não possuam registro na tabela Situação de Titulo Serasa (FWA)
		cQuery += "NOT EXISTS ( "+ cSE1_FWA +" ) "
		//Contas a Receber (SE1) com saldo que possuam registro na tabela Situação de Titulo Serasa (FWA) com status Sem restrições (FWA_STATUS = "0")
		cQuery += "OR EXISTS ( "+ cSE1_FWA +" AND FWA.FWA_STATUS = '0' ) "
		cQuery += ") "
		
	Else //Erro				
				
		//Contas a Receber (SE1) com saldo que possuam registros na tabela Situação de Titulo Serasa (FWA) com status Erro Envio (FWA_STATUS = "6")
		cQuery += "EXISTS ( "+ cSE1_FWA +" AND FWA.FWA_STATUS = '6' ) "

	EndIf
	cQuery += "AND SE1.E1_SALDO > "+ STR(MV_PAR05) +" "
Else //Retirada

	If MV_PAR02 == 1//Normal
				
		//Registros na tabela Situação de Titulo Serasa (FWA) com status Incluido Serasa (FWA_STATUS = "3") ou Negociado com o cliente (FWA_STATUS = "7")
		//ou Recebido do Cliente (FWA_STATUS = "8")
		cQuery += "EXISTS ( "+ cSE1_FWA +" AND FWA.FWA_STATUS IN ('3','7','8') ) "
		
	Else //Erro
		
		//Registros na tabela Situação de Titulo Serasa (FWA) com status Erro Retirada (FWA_STATUS = "9")
		cQuery += "EXISTS ( "+ cSE1_FWA +" AND FWA.FWA_STATUS = '9' ) "
		
	EndIf
	cQuery += "AND SE1.E1_SALDO >= "+ STR(MV_PAR05) +" "
EndIf

cQuery += "AND SE1.E1_VENCREA BETWEEN '"+ DTOS(MV_PAR03) +"' AND '"+ DTOS(MV_PAR04) +"' "
cQuery += "AND SE1.E1_CLIENTE BETWEEN '"+ MV_PAR06 +"' AND '"+ MV_PAR08 +"' "
cQuery += "AND SE1.E1_LOJA BETWEEN '"+ MV_PAR07 +"' AND '"+ MV_PAR09 +"' "

If !Empty(cSitOK)
	cQuery += "AND SE1.E1_SITUACA IN ("+ cSitOK +") "
Else
	cQuery += "AND SE1.E1_SITUACA NOT IN ("+ cSitNO +")"
EndIf

cQuery += " AND E1_TIPO NOT IN " + FormatIn(MVABATIM + "|" + MV_CPNEG + "|" + MVTAXA + "|" + MVTXA,"|")
cQuery += " AND E1_TIPO NOT IN " + FormatIn(MV_CRNEG,cSepNeg)
cQuery += " AND E1_TIPO NOT IN " + FormatIn(MVPROVIS,cSepProv)
cQuery += " AND E1_TIPO NOT IN " + FormatIn(MVRECANT,cSepRec)

cQuery += " AND SE1.D_E_L_E_T_ = ' ' "

IF ExistBlock("F770CPQ")
	cComp := ExecBlock("F770CPQ",.F.,.F.)
	If !Empty(cComp)
		cQuery	+=  "AND "+ cComp + " "
	EndIf	
Endif

cQuery += "ORDER BY "+ SqlOrder(SE1->(IndexKey()))

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE1,.T.,.T.)

Return cAliasSE1

//-------------------------------------------------------------------
/*/{Protheus.doc} F770Botao
Cria botão para marcar ou desmarcar todos os títulos

@author Marcello Gabriel
@since 28/08/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Function F770ABotao(oPanel,oView)
Local oButton	:= Nil
Local oRadio	:= Nil
Local nRadio	:= 1

@4,4 Radio oRadio VAR nRadio ITEMS STR0009,STR0010 3D SIZE 100,10 OF oPanel PIXEL			//"Marcar todos os títulos"###"Desmarcar todos os títulos"
@4,150 BUTTON oButton PROMPT STR0011  SIZE 100,10 FONT oPanel:oFont ACTION MsgRun(STR0008,STR0002,{|| F770AMarca(nRadio)}) OF oPanel PIXEL     //"Executar"###"Marca / Desmarca todos os títulos"###"Títulos" 

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} F770AMarca
Marcar ou desmarca todos os títulos.

@author Marcello Gabriel
@since 28/08/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Function F770AMarca(nAcao)
Local nX			:= 0
Local nLenSE1		:= 0
Local lMarca		:= .F.
Local oModel		:= Nil
Local oModTit		:= Nil
Local oView			:= Nil
Local aSaveLines 	:= FWSaveRows()

oModel := FWModelActive()
oModTit := oModel:GetModel("TITULO")
nLenSE1 := oModTit:Length()
If nLenSE1 > 0
	oView := FwViewActive()
	For nX := 1 To nLenSE1
		oModTit:GoLine(nX)
		lMarca := oModTit:GetValue("E1_MARK")
		If nAcao == 1
			lMarca := .T.
		ElseIf nAcao == 2
			lMarca := .F.
		Else
			lMarca := !lMarca
		EndIf
		oModTit:LoadValue("E1_MARK",lMarca)
	Next
	oModTit:GoLine(1)
	oView:Refresh()
EndIf

FWRestRows( aSaveLines )

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} F770PosVld

Pós validação do modelo
Valida se foi selecionado algum título para continuar.
@author  renato.ito
@since   03/06/2019
@version P12

@param oModel - Modelo de dados
@return lRet

/*/
//-------------------------------------------------------------------
Function F770PosVld(oModel As Object) As Logical

Local lRet			As Logical
Local nX			As Numeric
Local oModelAux		As Object	
Local aSaveLines	As Array

aSaveLines 	:= FWSaveRows()

oModelAux := oModel:GetModel('TITULO')
lRet := .F.

For nX := 1 To oModelAux:length()
	
	oModelAux:GoLine(nX)

	If !Empty( oModelAux:GetValue("E1_MARK") )
		lRet := .T.
		Exit
	EndIf

Next

If !lRet
	Help( ,,,"F770SEL",STR0026, 1, 0 )//"Nenhum título foi selecionado para a geração do lote."
EndIf

FWRestRows( aSaveLines )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F770Browse
Função que retorna os campos da SE1 que estão como Usados e no Browse
@author  sidney.silva
@since   09/06/2021
@version P12

@return aSE1Brw, array, array com os campos que estão como Usados e no Browse

/*/
//-------------------------------------------------------------------
Static Function F770Browse()

Local aSE1Brw 	As Array
Local aCmpSE1 	As Array
Local aCmpPdr	As Array
Local aCmpMem	As Array
Local nX 		As Numeric
Local nY 		As Numeric	
Local cX3Tipo	As Character

aSE1Brw 		:= {}
aCmpSE1 		:= {}
aCmpPdr			:= {} 
aCmpMem			:= {} 	
nX 				:= 0  	
nY 				:= 0  	
cX3Tipo			:=""

	// Campos padrões que sempre existiram na rotina (legado)	
	aCmpPdr   := { "E1_FILIAL", "E1_FILORIG", "E1_PREFIXO", "E1_NUM", "E1_PARCELA", "E1_TIPO", "E1_CLIENTE", "E1_LOJA", "E1_NOMCLI", "E1_EMISSAO", "E1_VENCTO", "E1_VENCREA", "E1_VALOR", "E1_SALDO", "E1_SITUACA", "E1_OBS" }

	For nX := 1 to Len(aCmpPdr)
		aAdd(aCmpSE1, {aCmpPdr[nX], GetSx3Cache(aCmpPdr[nX], "X3_ORDEM"), GetSx3Cache(aCmpPdr[nX], "X3_TIPO")})			
	Next 
	
	aSE1Brw := FWSX3Util():GetAllFields( "SE1" , .F. )

	// Campos que estão ativos no Browser e Usados no configurador, serve para inserir mais colunas na tela
	For nY := 1 to Len(aSE1Brw)		
		If !aScan( aCmpSE1, { |x| AllTrim( x[1] ) ==  AllTrim( aSE1Brw[nY] ) } ) .And. GetSx3Cache(aSE1Brw[nY], "X3_BROWSE") == "S"	.And. X3Uso(GetSX3Cache(aSE1Brw[nY], "X3_USADO"))		
			cX3Tipo:=GetSx3Cache(aSE1Brw[nY], "X3_TIPO") 
			If cX3Tipo == "M"
				aAdd(aCmpMem, {aSE1Brw[nY], GetSx3Cache(aSE1Brw[nY], "X3_ORDEM"),cX3Tipo})			
			Else
				aAdd(aCmpSE1, {aSE1Brw[nY], GetSx3Cache(aSE1Brw[nY], "X3_ORDEM"), cX3Tipo})			
			EndIF
		Endif		
	Next 
	
	aSort(aCmpSE1,,,{ |x, y| x[2] < y[2] })
	
	//-- Adiciona campos Memo no final da query
	For nY := 1 to Len(aCmpMem)	
		aAdd(aCmpSE1, {aCmpMem[nY,1],aCmpMem[nY,2],aCmpMem[nY,3]})	
	Next nY

	FwFreeArray(aCmpMem)
	FwFreeArray(aSE1Brw)
	FwFreeArray(aCmpPdr)

Return aCmpSE1
