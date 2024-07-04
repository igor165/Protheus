#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE 'FWBROWSE.ch'
#Include 'ApWizard.ch'
#Include 'FINA770B.ch'
#Include 'FILEIO.ch'
#Include 'FWEDITPANEL.ch'

Static cRet770F3		:= ''
Static cNumFW8			:= ''
Static cNumFW9			:= ''
Static __cArqTrab		:= GetNextAlias()
Static __cInd01			:= ''
Static __cInd02			:= ''
Static __oFINA7701
Static __lF770FilTit	:= ExistBlock('F770FILTIT')
Static __nRecFW8		:= 0

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA770
Processo do SERASA

@author lucas.oliveira

@since 12/06/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Function FINA770()

Local cExistInd	:= FWSIXUtil():ExistIndex( "FWA" , "4" )
Local cExistFW9 := FW9->(ColumnPos("FW9_IDTITU")) > 0

Private oBrowse := Nil

If !cExistInd .Or. !cExistFW9
	//  STR0094 --- "Dicionario de dados desatualizado."
	//  STR0095 --- "Favor atualizar dicionario de dados com pacote acumulado posterior a 24/08/2020."
	Help(" ",1,"F770Dicion",, STR0094, 1, 0, NIL, NIL, NIL, NIL, NIL, { STR0095 }) 
	Return 
Endif

oBrowse := FWMBrowse():New()
oBrowse:setAlias("FW8") // Cabeçalho de Lotes SERASA
oBrowse:SetDescription(STR0001) //"Lotes SERASA"
oBrowse:DisableDetails()
aRotina := Nil
oBrowse:SetImpTXT(.F.)
oBrowse:SetExpTXT(.F.)
oBrowse:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface
@author lucas.oliveira
@since 12/06/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel	:= FWLoadModel("FINA770")
Local oView		:= FWFormView():New()
Local oStruFW8	:= FWFormStruct(2,"FW8")
Local oStruFW9	:= FWFormStruct(2,"FW9")
Local oStruFWB	:= FWFormStruct(2,"FWB")

oStruFWB:AddField(	"FWB_DCERRO",; //Id do Campo
					"15",; //Ordem
					STR0002,;// Título do Campo //Descrição Erro
					STR0003,; //Descrição do Campo //"Descrição do Erro"
					{},; //aHelp
					"C",; //Tipo do Campo	
					"@!")//cPicture

oView:SetModel(oModel)

oView:AddField("VIEW_FW8",	oStruFW8, "MASTERFW8")
oView:AddGrid("VIEW_FW9",	oStruFW9, "TITULOFW9")
oView:AddGrid("VIEW_FWB",	oStruFWB, "MOVTITFWB")

oView:CreateHorizontalBox("BOXFW8", 20)
oView:CreateHorizontalBox("BOXFW9", 40)
oView:CreateHorizontalBox("BOXFWB", 40)

oView:SetOwnerView("VIEW_FW8", "BOXFW8")
oView:SetOwnerView("VIEW_FW9", "BOXFW9")
oView:SetOwnerView("VIEW_FWB", "BOXFWB")

oView:EnableTitleView("VIEW_FW9", STR0004)//"Títulos"
oView:EnableTitleView("VIEW_FWB", STR0005)//"Ocorrências do Título (Lote)"

oStruFW9:RemoveField( "FW9_IDDOC" )
oStruFWB:RemoveField( "FWB_IDDOC" )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@author lucas.oliveira
@since 12/06/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel    := Nil
Local oStruFW8  := FWFormStruct(1,"FW8")
Local oStruFW9  := FWFormStruct(1,"FW9")
Local oStruFWA  := FWFormStruct(1,"FWA")
Local oStruFWB  := FWFormStruct(1,"FWB")
Local oVirtual	:= FWFormStruct(1,"FW8")
Local aAux		:= aClone(oVirtual:GetFields())
Local nX		:= 0
Local aFW9Rel	:= {}
Local aFWARel	:= {}
Local aFWBRel	:= {}
Local aVIRRel	:= {}
Local bValid    := {|| }
Local bWhen		:= {|| }
Local aValues   := NIL
Local nDecimal  := 0
Local nTamSX5   := TamSX3('X5_DESCRI')[1]
Local bInit 	:= {||Posicione("SX5",1,xFilial("SX5")+"GV"+FWB->FWB_CODERR,"X5_DESCRI")} 

oModel := MPFormModel():New("FINA770",/*PreValidacao*/,/*PosValidacao*/,{|oModel| F770GrvMod(oModel),LimpaArqTmp()} /*bCommit*/)

oStruFWB:AddField(	STR0002			,;  //[01]  C   Titulo do campo
					""				,;  //[02]  C   ToolTip do campo
					"FWB_DCERRO"	,;  //[03]  C   Id do Field
					"C"				,;  //[04]  C   Tipo do campo
					nTamSX5			,;  //[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
					nDecimal		,;  //[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
					bValid			,;	//[07]  B   Code-block de validacao do campo
					bWhen			,;	//[08]  B   Code-block de validacao When do campo
					aValues			,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
					.F.				,;	//[10]  L   Indica se o campo tem preenchimento obrigatorio
					bInit		   	,;	//[11]  B   Code-block de inicializacao do campo
					.F.				,;	//[12]  L   Indica se trata-se de um campo chave
					.F.				,;	//[13]  L   Indica se o campo pode receber valor em uma operacao de update.
					.T.				)	//[14]  L   Indica se o campovirtual

oModel:AddFields("MASTERFW8", /*cOwner*/, oStruFW8, /*bPreVld*/, /*bPosVld*/, /*bLoad*/)
oModel:SetDescription(STR0006)//"Cabeçalho de Lote"
oModel:GetModel("MASTERFW8"):SetDescription(STR0007)//"Destalhes do Lote"
oModel:AddGrid("TITULOFW9", "MASTERFW8", oStruFW9)
oModel:AddGrid("SITTITFWA", "TITULOFW9", oStruFWA)
oModel:AddGrid("MOVTITFWB", "TITULOFW9", oStruFWB)
oModel:AddGrid("VIRTUAL", "MASTERFW8", oVirtual)

Aadd(aVIRRel,{"FW8_LOTE","FW8_LOTE"})
oModel:setrelation("VIRTUAL", aVIRRel, FW8->(IndexKey(1)))

Aadd(aFW9Rel,{"FW9_FILIAL","xFilial('FW9')"})
Aadd(aFW9Rel,{"FW9_LOTE","FW8_LOTE"})
oModel:setrelation("TITULOFW9", aFW9Rel, FW9->(IndexKey(1)))

Aadd(aFWARel,{"FWA_FILIAL","xFilial('FWA')"})
Aadd(aFWARel,{"FWA_IDDOC","FW9_IDDOC"})
oModel:setrelation("SITTITFWA", aFWARel, FWA->(IndexKey(1)))

Aadd(aFWBRel,{"FWB_FILIAL","xFilial('FWB')"})
Aadd(aFWBRel,{"FWB_LOTE","FW9_LOTE"})
Aadd(aFWBRel,{"FWB_IDDOC","FW9_IDDOC"})
oModel:setrelation("MOVTITFWB", aFWBRel, FWB->(IndexKey(1)))

For nX := 1 To Len(aAux)
	oVirtual:SetProperty( aAux[nX][3] , MODEL_FIELD_WHEN, {||.F.})
Next nX

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu de Operações disponíveis na Browse do Lotes SERASA
@author lucas.oliveira
@since 18/06/2015
@version 12.1.6
@return aRotina Array com as configurações necessárias para criação do menu de opções
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0008	ACTION 'VIEWDEF.FINA770'	OPERATION 2 ACCESS 0 //"Consulta Lote"
ADD OPTION aRotina TITLE STR0009	ACTION 'F770Ger'			OPERATION 3 ACCESS 0 //"Gerar Lote"
ADD OPTION aRotina TITLE STR0010	ACTION 'F770Export'			OPERATION 2 ACCESS 0 //"Exportar Lote"
ADD OPTION aRotina TITLE STR0011	ACTION 'F770Import'			OPERATION 3 ACCESS 0 //"Arquivo de Retorno"
ADD OPTION aRotina TITLE STR0012	ACTION 'VIEWDEF.FINA770'	OPERATION 5 ACCESS 0 //"Excluir Lote"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} F770GrvMod
Atualiza os dados do lote SERASA

@author Marcello

@since 25/09/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Function F770GrvMod(oModel)

Local lRet		:= .T.

Begin Transaction
	lRet := .F.

	FWFormCommit(oModel)
	MSUnLockAll()
	lRet := .T.
End Transaction

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} F770Ger
Processo do SERASA

@author lucas.oliveira

@since 12/06/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Function F770Ger()

Local oProcess	:= Nil

oProcess := tNewProcess():New( "FINA770", STR0013,{|oSelf| FINA770A(oSelf)}, STR0014, "FINA770",,.F.,,"",.F.,.T.) //"SERASA" # //"Essa rotina tem como função gerar lotes de títulos em atraso para serem enviados ao Serasa."
FreeObj(oProcess)
DelClassIntf()
LimpaArqTmp()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}F770Grava
Grava em um array todos os títulos selecionados.
@author lucas.oliveira
@since  16/05/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Function F770Grava(oModelAux)

Local lRet		:= .F.
Local cLog		:= ""
Local oModel	:= FWLoadModel("FINA770")
Local oAuxFW8	:= oModel:GetModel("MASTERFW8")
Local oAuxFW9	:= oModel:GetModel("TITULOFW9")
Local oAuxFWA	:= oModel:GetModel("SITTITFWA")
Local oAuxFWB	:= oModel:GetModel("MOVTITFWB")
Local oAuxSE1	:= oModelAux:GetModel('TITULO')
Local oVirtual	:= oModel:GetModel("VIRTUAL")
Local cChaveTit	:= ""
Local cChaveFK7	:= ""
Local cIdTitulo	:= ""
Local nX		:= 0
Local cNumLote	:= ""
Local cNumSeq	:= "001"
Local aAreaFW9	:= {}
Local lSeekFW9	:= .T.

oAuxFWA:Setoptional(.T.)
oAuxFWB:Setoptional(.T.)
oVirtual:Setoptional(.T.)

oModel:SetOperation( MODEL_OPERATION_INSERT ) //Inclusao
oModel:Activate()

cNumLote  := GETSXENUM( "FW8", "FW8_LOTE")

dbSelectArea("FWA")	
FWA->(dbSetOrder(1))
dbSelectArea("FWB")
FWB->(dbSetOrder(1))

BEGIN TRANSACTION

For nx := 1 To oAuxSE1:length()
	
	oAuxSE1:GoLine(nX)

	If !Empty( oAuxSE1:GetValue("E1_MARK") )
		
		cChaveTit :=	oAuxSE1:GetValue("E1_FILIAL")	+"|"+;
						oAuxSE1:GetValue("E1_PREFIXO")	+"|"+;
						oAuxSE1:GetValue("E1_NUM")		+"|"+;
						oAuxSE1:GetValue("E1_PARCELA")	+"|"+;
						oAuxSE1:GetValue("E1_TIPO")		+"|"+;
						oAuxSE1:GetValue("E1_CLIENTE")	+"|"+;
						oAuxSE1:GetValue("E1_LOJA")
		cChaveFK7 := FINGRVFK7("SE1", cChaveTit)
		
		oAuxFW8:LoadValue( "FW8_FILIAL"	, xFilial("FW8") )		
		oAuxFW8:LoadValue( "FW8_LOTE"	, cNumLote )//‘000001’
		oAuxFW8:LoadValue( "FW8_DTLOTE"	, dDataBase	)//16/04/2015
		oAuxFW8:LoadValue( "FW8_DTARQ"	, CTOD("//") )//<vazia>
		oAuxFW8:LoadValue( "FW8_DTPROC"	, CTOD("//") )//<vazia>
		oAuxFW8:LoadValue( "FW8_TIPO"	, ALLTRIM(STR(MV_PAR01)) )//“1” (Envio) ou “2” (Retirada)
		oAuxFW8:LoadValue( "FW8_ARQSER"	, '') //‘006042’
		
		If MV_PAR01 == 2	//Se for retirada, utiliza o mesmo FW9_IDTITU
			aAreaFW9:= FW9->(GetArea())
			FW9->(dbSetOrder(2))
			If lSeekFW9	:= 	FW9->(dbSeek(xFilial("FW9")+cChaveFK7))
				cIdTitulo := FW9->FW9_IDTITU											
			EndIf
			RestArea(aAreaFW9)
		Else			
			cIdTitulo := GETSXENUM( "FW9", "FW9_IDTITU")
		EndIf

		oAuxFW9:LoadValue( "FW9_FILIAL"	, xFilial("FW9") )
		oAuxFW9:LoadValue( "FW9_LOTE"	, cNumLote )//‘000001’
		oAuxFW9:LoadValue( "FW9_IDDOC"	, cChaveFK7 )//Chave do titulo (FK7_IDDOC)
		oAuxFW9:LoadValue( "FW9_PREFIX"	, oAuxSE1:GetValue("E1_PREFIXO") )//Prefixo do título
		oAuxFW9:LoadValue( "FW9_NUM"	, oAuxSE1:GetValue("E1_NUM") )//Numero do título
		oAuxFW9:LoadValue( "FW9_PARCEL"	, oAuxSE1:GetValue("E1_PARCELA") )//Parcela do título
		oAuxFW9:LoadValue( "FW9_TIPO"	, oAuxSE1:GetValue("E1_TIPO") )//Tipo do título
		oAuxFW9:LoadValue( "FW9_CLIENT"	, oAuxSE1:GetValue("E1_CLIENTE") )//Código do Cliente
		oAuxFW9:LoadValue( "FW9_LOJA"	, oAuxSE1:GetValue("E1_LOJA") )//Loja do Cliente
		oAuxFW9:LoadValue( "FW9_FILORI"	, oAuxSE1:GetValue("E1_FILORIG") )//Filial Origem Titulo
		oAuxFW9:LoadValue( "FW9_VALOR"	, oAuxSE1:GetValue("E1_SALDO") )//Saldo do título
		oAuxFW9:LoadValue( "FW9_OBS"	, oAuxSE1:GetValue("E1_OBS") )//“Geração de lote para envio ao Serasa em 16/04/2015 – Autorizado por Sr. José da Silva.” (texto livre)
		oAuxFW9:LoadValue( "FW9_IDTITU"	, cIdTitulo )//‘Identificação do titulo’
		
		If MV_PAR01 == 1 //Inclusão
			If !FWA->(DbSeek(xFilial("FWA")+cChaveFK7)) //primeiro envio ao Serasa.
				oAuxFWB:LoadValue( "FWB_FILIAL"	, xFilial("FWB") )//	Filial do sistema
				oAuxFWB:LoadValue( "FWB_LOTE"	, cNumLote )//	Código do Lote Serasa
				oAuxFWB:LoadValue( "FWB_IDDOC"	, cChaveFK7 )//	Chave do titulo (FK7_IDDOC)
				oAuxFWB:LoadValue( "FWB_SEQ"	, cNumSeq )//	Sequência de registro para o título.
				oAuxFWB:LoadValue( "FWB_OCORR"	, "1" )//	Valores possíveis após esse processo:
													//1 - Selecionado Serasa (Envio ao Serasa)
													//4 - Selecionado Retirada (Retirada do Serasa)
				
				oAuxFWB:LoadValue( "FWB_DESCR"	, STR0015 )//Descrição da ocorrência //"Selecionado Serasa"
				oAuxFWB:LoadValue( "FWB_DTOCOR"	, dDatabase )//	Data da ocorrência (Protheus)
				oAuxFWB:LoadValue( "FWB_VALOR"	, oAuxSE1:GetValue("E1_SALDO") )//	Saldo do título no momento do envio
				oAuxFWB:LoadValue( "FWB_CODERR"	, "  ")//	<vazia>
				oAuxFWB:LoadValue( "FWB_DTSERA"	, CTOD("//") )//	<vazia>
				
				oAuxFWA:LoadValue( "FWA_FILIAL"	, xFilial("FWA") )//xFilial(“FWA”)
				oAuxFWA:LoadValue( "FWA_IDDOC"	, cChaveFK7 )//Chave do titulo (FK7_IDDOC)
				oAuxFWA:LoadValue( "FWA_SEQ"	, cNumSeq )//Ultima sequencia do titulo na FWB
				oAuxFWA:LoadValue( "FWA_PREFIX"	, oAuxSE1:GetValue("E1_PREFIXO") )//Prefixo do título
				oAuxFWA:LoadValue( "FWA_NUM"	, oAuxSE1:GetValue("E1_NUM") )//Numero do título
				oAuxFWA:LoadValue( "FWA_PARCEL"	, oAuxSE1:GetValue("E1_PARCELA") )//Parcela do título
				oAuxFWA:LoadValue( "FWA_TIPO"	, oAuxSE1:GetValue("E1_TIPO") )//Tipo do título
				oAuxFWA:LoadValue( "FWA_CLIENT"	, oAuxSE1:GetValue("E1_CLIENTE") )//Código do Cliente
				oAuxFWA:LoadValue( "FWA_LOJA"	, oAuxSE1:GetValue("E1_LOJA") )//Loja do Cliente
				oAuxFWA:LoadValue( "FWA_FILORI"	, oAuxSE1:GetValue("E1_FILORIG") )//Filial Origem Titulo
				oAuxFWA:LoadValue( "FWA_STATUS"	, "1" )//Status possíveis após o processo
													//1 - Selecionado Serasa (Envio ao Serasa)
									
			Else //Reenvio ao Serasa
			
				If FWB->(DbSeek(xFilial("FWB")+cChaveFK7))

					cNumSeq := F770NumSeq(cChaveFk7, 1)

					RECLOCK("FWB", .T.)
					FWB->FWB_FILIAL	:= xFilial("FWB")
					FWB->FWB_LOTE	:= cNumLote
					FWB->FWB_IDDOC	:= cChaveFK7
					FWB->FWB_SEQ	:= cNumSeq
					FWB->FWB_OCORR	:= "1"
					FWB->FWB_DESCR	:= STR0015
					FWB->FWB_DTOCOR	:= dDatabase
					FWB->FWB_VALOR	:= oAuxSE1:GetValue("E1_SALDO")
					FWB->FWB_CODERR	:= "  "
					FWB->FWB_DTSERA	:= CTOD("//")
					MSUNLOCK()
					
				EndIf
		
				If FWA->(DbSeek(xFilial("FWA")+cChaveFK7))
					RECLOCK("FWA", .F.)
					FWA->FWA_SEQ		:= cNumSeq
					FWA->FWA_STATUS	:= "1"
					MSUNLOCK()
				EndIf
			EndIf
		EndIf
		
		If lSeekFW9 .And. oModel:VldData()
			oModel:CommitData()
			lRet:= .T.			
			ConfirmSx8()
	   Else
	   		If !lSeekFW9			   
			   cLog := STR0096 + cChaveTit
			Else
			   cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
			   cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
			   cLog += cValToChar(oModel:GetErrorMessage()[6])        	
			EndIf
			Help( ,,"F770INC",,cLog, 1, 0 )
			If MV_PAR01 == 1
				RollbackSx8()
			ENDIF
		EndIf
		
		//Retirada
		If MV_PAR01 == 2 .And. lSeekFW9
			If FWB->(DbSeek(xFilial("FWB")+cChaveFK7))

				cNumSeq := F770NumSeq(cChaveFk7, 1)

				RECLOCK("FWB", .T.)
				FWB->FWB_FILIAL	:= xFilial("FWB")
				FWB->FWB_LOTE	:= cNumLote
				FWB->FWB_IDDOC	:= cChaveFK7
				FWB->FWB_SEQ	:= cNumSeq
				FWB->FWB_OCORR	:= "4"
				FWB->FWB_DESCR	:= STR0016 //"Selecionado Retirada"
				FWB->FWB_DTOCOR	:= dDatabase
				FWB->FWB_VALOR	:= oAuxSE1:GetValue("E1_SALDO")
				FWB->FWB_CODERR	:= "  "
				FWB->FWB_DTSERA	:= CTOD("//")
				MSUNLOCK()
				
			EndIf
			
			If FWA->(DbSeek(xFilial("FWA")+cChaveFK7))
				RECLOCK("FWA", .F.)
				FWA->FWA_SEQ		:= cNumSeq
				FWA->FWA_STATUS	:= "4"
				MSUNLOCK()
			EndIf
		EndIf
	EndIf	

Next nX

End TRANSACTION	

If lRet
	CONFIRMSX8()
EndIf

oModelAux:DeActivate()
oModelAux:Destroy()
oModelAux := Nil
oModel:DeActivate()
oModel:Destroy()
oModel := Nil

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} F770FltSC
Construção de Browse de Consulta Padrão do tipo Especifíca 
Situação Cobrança Seleção
@return cRet – Relação das situações de cobrança selecionadas pelo usuário
@author lucas.oliveira
@since  16/05/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Function F770FltSC(cFiltro,lFilFW2, cRetFRV)

Local lRet		:= .F.
Local aStru		:= FRV->(DBSTRUCT()) //Estrutura da tabela de Situações de cobrança.
Local cQuery	:= ''
Local aColumns	:= {}
Local cChave	:= ''
Local nX		:= 0
Local aSize
Local bOk		:= {||lRet := F770GrvSC(__cArqTrab),oDlg:End()}
Local bCancel	:= {|| oMrkBrowse:Deactivate(),oDlg:End()}
Local aPesq		:= {}

Default cFiltro	:= ''
Default lFilFW2	:= .T.
Default cRetFRV := ""

//Criar uma FWMarkBrowse() baseado na tabela FRV, apresentando todas as situações de cobrança e sua descrição para seleção do usuário.
//Caso o usuário confirme, retornar string com o código das situações selecionadas, alimentando a variável Static cRet770F3

cRet770F3 := ''

//Seleciona as Situações de Cobrança, exceção aquelas que impedem interação com a Serasa 
cQuery += " SELECT * FROM "+ RetSqlName("FRV") +" FRV "
cQuery += " WHERE FRV.FRV_FILIAL = '" + xFilial("FRV") + "' "
cQuery += " AND FRV.D_E_L_E_T_ = ' ' "

If lFilFW2 //Incluso IF para nao executar esse trecho quando executado pelo relatorio FINR645
	cQuery += " AND FRV_CODIGO NOT IN( "
	cQuery += " SELECT FW2_SITUAC FROM " + RetSqlName("FW2")
	cQuery += " WHERE D_E_L_E_T_ = '' "
	cQuery += " AND FW2_CODIGO = '0012' )"
EndIf

If !Empty(cFiltro)
	cQuery += " AND " + cFiltro
EndIf
cQuery += " ORDER BY "+ SqlOrder(FRV->(IndexKey()))

cChave := FRV->(IndexKey())
aAdd(aStru, {'FRV_OK','C',1,0}) // Adiciono o campo de marca

If __oFINA7701 <> Nil
	__oFINA7701:Delete()
	__oFINA7701	:= Nil
EndIf

If Empty(__cArqTrab)
	__cArqTrab := GetNextAlias()
EndIf

//Cria o Objeto do FwTemporaryTable
__oFINA7701 := FwTemporaryTable():New(__cArqTrab)

//Cria a estrutura do alias temporario
__oFINA7701:SetFields(aStru)

//Adiciona o indicie na tabela temporaria
__oFINA7701:AddIndex("1",{"FRV_CODIGO"})
__oFINA7701:AddIndex("2",{"FRV_DESCRI"})
	
//Criando a Tabela Temporaria
__oFINA7701:Create()

Processa({||SqlToTrb(cQuery, aStru, __cArqTrab)})	// Cria arquivo temporario

DbSetOrder(0) // Fica na ordem da query	

//MarkBrowse
For nX := 1 To Len(aStru)
	If	aStru[nX][1] $ "FRV_FILIAL|FRV_CODIGO|FRV_DESCRI|FRV_BANCO|FRV_DESCON|FRV_PROTES|FRV_PERCEN|FRV_NATIOF"
		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData( &("{||" + aStru[nX][1] + "}") )
		aColumns[Len(aColumns)]:SetTitle(RetTitle(aStru[nX][1])) 
		aColumns[Len(aColumns)]:SetSize(aStru[nX][3]) 
		aColumns[Len(aColumns)]:SetDecimal(aStru[nX][4])
		aColumns[Len(aColumns)]:SetPicture(PesqPict("FRV",aStru[nX][1])) 
	EndIf 	
Next nX 

//Regras para pesquisa na tela
Aadd(aPesq,{AllTrim(RetTitle("FRV_CODIGO")),{{'FRV',"C",TamSX3("FRV_CODIGO")[1],0,AllTrim(RetTitle("FRV_CODIGO")),"@!"}},1})
Aadd(aPesq,{AllTrim(RetTitle("FRV_DESCRI")),{{'FRV',"C",TamSX3("FRV_DESCRI")[1],0,AllTrim(RetTitle("FRV_DESCRI")),"@!"}},2})

If !(__cArqTrab)->(Eof())
	aSize := MsAdvSize(,.F.,400)
	DEFINE MSDIALOG oDlg TITLE STR0017 From 300,0 to 800,800 OF oMainWnd PIXEL //Situações de Cobrança
	oMrkBrowse:= FWMarkBrowse():New()
	oMrkBrowse:oBrowse:SetEditCell(.T.)	
	oMrkBrowse:SetFieldMark("FRV_OK")
	oMrkBrowse:SetOwner(oDlg)
	oMrkBrowse:SetAlias(__cArqTrab)
	oMrkBrowse:SetSeek(.T.,aPesq)
	oMrkBrowse:SetMenuDef("")
	oMrkBrowse:AddButton(STR0018, bOk,,2) //Confirmar
	oMrkBrowse:AddButton(STR0019,bCancel,,2 ) //Cancelar 
	oMrkBrowse:bMark	:= {||}
	oMrkBrowse:bAllMark	:= {||F770SCMark(oMrkBrowse,__cArqTrab)}
	oMrkBrowse:SetMark( "X", __cArqTrab, "FRV_OK" )
	oMrkBrowse:SetDescription("")
	oMrkBrowse:SetColumns(aColumns)
	oMrkBrowse:SetTemporary(.T.) 
	oMrkBrowse:Activate()
	ACTIVATE MSDIALOg oDlg CENTERED
EndIf

cRetFRV := cRet770F3

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}F770SCMark
Marca ou desmarca todas as situações de cobrança.
@author lucas.oliveira
@since  06/10/2015
@version 12.1.7
/*/
//-------------------------------------------------------------------
Function F770SCMark(oMrkBrowse,__cArqTrab)

Local cMarca := oMrkBrowse:Mark()

dbSelectArea(__cArqTrab)
(__cArqTrab)->(DbGoTop())

While !(__cArqTrab)->(Eof())
	
	RecLock(__cArqTrab, .F.)
	
	If (__cArqTrab)->FRV_OK == cMarca
		(__cArqTrab)->FRV_OK := ' '
	Else
		(__cArqTrab)->FRV_OK := cMarca
	EndIf
	
	MsUnlock()
	(__cArqTrab)->(DbSkip())	
EndDo

(__cArqTrab)->(DbGoTop())
oMrkBrowse:oBrowse:Refresh(.T.)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc}LimpaArqTmp
Limpa o arquivo temporário
@author lucas.oliveira
@since  07/10/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Static function LimpaArqTmp()

If __cArqTrab != ""
	If Select(__cArqTrab) > 0
		( __cArqTrab )->( dbCloseArea() )
		FErase( ( __cArqTrab ) + GetDBExtension() )
		__cArqTrab := ""

		// Exclusao dos indices temporarios
		Ferase(__cInd01 + RetIndExt())
		__cInd01 := ""

		Ferase(__cInd02 + RetIndExt())
		__cInd02 := ""

	EndIf
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc}F770GrvSC
Grava em uma string todas as Situações de Cobrança selecionadas.
@author lucas.oliveira
@since  16/05/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Function F770GrvSC(__cArqTrab)

Local lRet		:= .F.
Local nRecNo	:= 0
Local nX		:= 0

dbSelectArea(__cArqTrab)
nRecno := (__cArqTrab)->(RecNo())
(__cArqTrab)->(DbGoTop())

While !(__cArqTrab)->(Eof())
	If !Empty((__cArqTrab)->FRV_OK)
		cRet770F3 += Iif(nX > 0, ",'" + (__cArqTrab)->FRV_CODIGO + "'", "'" + (__cArqTrab)->FRV_CODIGO + "'")
		nX++
	EndIf
	(__cArqTrab)->(DbSkip())
EndDo

(__cArqTrab)->(DbGoTo(nRecno))
lRet := Iif(Len(cRet770F3) > 0,.T., .F.)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F770RetSC
Retorna a string contendo as situações de cobrança selecionadas
@return cRet770F3 - Retorno da consulta padrão Situações de cobrança.
@author lucas.oliveira
@since  16/05/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Function F770RetSC()

Return cRet770F3

//-------------------------------------------------------------------
/*/{Protheus.doc} F770BxRen
Atualiza o status e sequncia da FWA e
cria um novo registro de ocorrência na FWB se Baixa ou Renegociação do título.
@author lucas.oliveira
@since  16/05/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Function F770BxRen(cOpc, cMotBx, cChaveFk7, aVencTit, cFilOri)

Local oModel	:= Nil
Local oFW9		:= Nil
Local oFWA		:= Nil
Local oFWB		:= Nil
Local cNumSeq	:= ""
Local lRet		:= .F.
Local cLog		:= ""
Local cOcorr	:= ""
Local cDescr	:= ""
Local nValor	:= 0
Local cStatus	:= ""
Local aArea		:= GetArea()
Local cLote		:= ""
Local lF770lmsg	:= .F.
Local cFilOld	:= cFilAnt

Default aVencTit := {SE1->E1_VENCREA, SE1->E1_VENCREA + 1} //Caso o array venha vazio, preencho com datas diferentes
Default cFilOri	 := cFilAnt

cLote := F770Lote(cChaveFk7, cFilOri)

dbSelectArea("FW8")	
FW8->(dbSetOrder(1))//FILIAL+IDDOC+LOTE
dbSelectArea("FW9")	
FW9->(dbSetOrder(1))//FILIAL+IDDOC+LOTE
If FW8->(DbSeek(xFilial("FW8",cFilOri)+cLote)) .AND. FW9->(DbSeek(xFilial("FW9",cFilOri)+cLote+cChaveFk7))
	
	If FWIsInCallStack("FINA040")
		
		//Ponto de entrada F770LMSG utilizado para desativar a exibicao da mensagem 
		If ExistBlock("F770LMSG")
			lF770lmsg := ExecBlock( "F770LMSG", .F., .F., aVencTit)
		Endif

		If (Valtype(lF770lmsg) == "L" .And. lF770lmsg ) //Tratamento de tipo logico e Desativacao de mensagem
			lRet := .F.
		Else
			lRet := MsgNoYes(STR0020,STR0021) //"Desja retirar esse título do Serasa" # //"Título no Serasa"
		EndIf

	Else
		lRet := .T.
	Endif
	
	If lRet
		cFilAnt := cFilOri
		oModel	:= FWLoadModel("FINA770")
		oFW9	:= oModel:GetModel("TITULOFW9")
		oFWA	:= oModel:GetModel("SITTITFWA")
		oFWB	:= oModel:GetModel("MOVTITFWB")
		
		oModel:SetOperation(MODEL_OPERATION_UPDATE)
		oModel:Activate()
		
		oFW9:SeekLine( { {"FW9_IDDOC", cChaveFk7 } } )
		
		If !(cOpc == "3" .AND. oFWA:GetValue("FWA_STATUS") == "0")
		
			If cOpc == "1"
				cOcorr		:= "8"
				cDescr		:= STR0022 //"Recebido"
				nValor		:= SE1->E1_SALDO
				cStatus	:= Iif( oFWA:GetValue("FWA_STATUS") == "3", cOcorr, "0")
			Elseif cOpc == "2"
				cOcorr		:= "7"
				cDescr		:= STR0023 //"Negociado"
				nValor		:= SE1->E1_SALDO
				cStatus	:= Iif( oFWA:GetValue("FWA_STATUS") == "3", cOcorr, "0")
			Elseif oFWA:GetValue("FWA_STATUS") != "0"
				cNumSeq := F770NumSeq(cChaveFk7, 2)
				If FWB->(DbSeek(xFilial("FWB")+cChaveFK7+STRZERO(Val(cNumSeq)-1,3)))
					cOcorr		:= FWB->FWB_OCORR
					cDescr		:= FWB->FWB_DESCR
					nValor		:= FWB->FWB_VALOR
					cStatus	:= cOcorr
				Endif
			Endif
			
			If FWB->(DbSeek(xFilial("FWB")+cChaveFK7))
				
				cNumSeq := F770NumSeq(cChaveFk7, 1, cFilOri)
				
				oFWA:LoadValue( "FWA_SEQ"	, cNumSeq )
				oFWA:LoadValue( "FWA_STATUS", cStatus )
				
				If !oFWB:IsEmpty()
					oFWB:AddLine()
				EndIf
				
				oFWB:LoadValue( "FWB_FILIAL", xFilial("FWB",cFilOri) )		//	Filial do sistema
				oFWB:LoadValue( "FWB_LOTE"	, oFW9:GetValue("FW9_LOTE") )	//	Código do Lote Serasa
				oFWB:LoadValue( "FWB_IDDOC"	, oFW9:GetValue("FW9_IDDOC") )	//	Chave do titulo (FK7_IDDOC)
				oFWB:LoadValue( "FWB_SEQ"	, cNumSeq )						//	Sequência de registro para o título.
				oFWB:LoadValue( "FWB_OCORR"	, cOcorr )							//	4 - Selecionado Retirada (Retirada do Serasa)
				oFWB:LoadValue( "FWB_DESCR"	, cDescr )							//	Descrição da ocorrência
				oFWB:LoadValue( "FWB_DTOCOR", dDatabase )						//	Data da ocorrência (Protheus)
				oFWB:LoadValue( "FWB_VALOR"	, nValor)							//	Saldo do título no momento do envio
				oFWB:LoadValue( "FWB_CODERR", "  ")							//	<vazia>
				oFWB:LoadValue( "FWB_DTSERA", CTOD("//") )					//	<vazia>
		
			Endif	
			
			If oModel:VldData()
				oModel:CommitData()
				lRet:= .T.
			Else
				cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
				cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
				cLog += cValToChar(oModel:GetErrorMessage()[6])        	

				Help( ,,"F770RETTIT",,cLog, 1, 0 )	             
			Endif
			
			oModel:DeActivate()
			oModel:Destroy()
		Endif
		cFilAnt := cFilOld	
	EndIf
EndIF

RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F770Lote
Função que retorna o lote ref a chave da FW9
@author lucas.oliveira
@since  16/05/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
FUNCTION F770Lote(cChaveFk7 AS CHARACTER, cFilOri AS CHARACTER) AS CHARACTER
LOCAL cLote	AS CHARACTER
LOCAL cSeq	AS CHARACTER

DEFAULT cFilOri	:= cFilAnt

cLote := ""
cSeq := "001"

//Movimentos Do Título Serasa não necessário para países localizados
If cPaisLoc == "BRA"
	//achar a ultima sequencia
	cSeq	:= F770NumSeq(cChaveFk7, 2, cFilOri)
	
	dbSelectArea("FWB")	
	FWB->(dbSetOrder(1))//FILIAL+IDDOC+SEQ
	If FWB->(DbSeek(xFilial("FWB", cFilOri)+cChaveFk7+cSeq))	
		cLote	:= FWB->FWB_LOTE			
	Endif
EndIf

RETURN cLote

//-------------------------------------------------------------------
/*/{Protheus.doc} F770Lote
Função que retorna ultima sequencia da FWB
nOpc = 1 - Ultima sequencia livre pra ser usada.
nOpc = 2 - Ultima sequencia usada.
@author lucas.oliveira
@since  16/05/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
FUNCTION F770NumSeq(cChaveFk7 AS CHARACTER, nOpc AS NUMERIC, cFilTit AS CHARACTER) AS CHARACTER
LOCAL cNumSeq AS CHARACTER
LOCAL cSeq	AS CHARACTER

DEFAULT cFilTit := cFilAnt

cNumSeq	:= "001"
cSeq := "001"

//Movimentos Do Título Serasa não necessário para países localizados
If cPaisLoc == "BRA"		
	dbSelectArea("FWB")	
	FWB->(dbSetOrder(1))//FILIAL+IDDOC+SEQ
	While FWB->(DbSeek(xFilial("FWB", cFilTit)+cChaveFK7+cNumSeq))
		cSeq		:= cNumSeq
		cNumSeq	:= SOMA1(FWB->FWB_SEQ)
		FWB->(DbSkip())
	EndDo
EndIf
	
RETURN Iif(nOpc == 1, cNumSeq, cSeq)

//-------------------------------------------------------------------
/*/{Protheus.doc} F770Export
Rotina para geração do arquivo de exportação SERASA

@author Pedro Lima
@since 29/06/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Function F770Export(cAlias, nRecno, nOpc, lAutomato)

Local oMileExport	:= FWMile():New(.T.)
Local cFilePath		:= StrTran(GetMV("MV_SERENV"),"/","\")
Local lExport		:= .T.
Local lTemArq		:= .F.
Local nRecFw8		:= FW8->(RECNO())	
Local cFilter		:= "FW8_FILIAL == '" + FW8->FW8_FILIAL + "' .And. FW8_LOTE == '" + FW8->FW8_LOTE + "'"

Private	cSeqReg		:= '0000000'
Private cFilBase	:= FW8->FW8_FILIAL //armazeno a filial base da FW8 em substituição ao mv_par01 (antigo pergunte)
Private cSeqSerasa	:= ""

Default cAlias 		:= "FW8"
Default nRecno		:= FW8->(Recno())
Default nOpc		:= 3 
Default lAutomato	:= .F.

If (Iif(lAutomato,.T.,Pergunte('FIN770EXPO',.T.)) ) 
		
	F770Filter(cFilter)

	FW8->(dbSetOrder(1))
	FW8->(dbGoTo(nRecFw8))
	
	If !Empty(FW8->FW8_ARQSER)
		lTemArq := .T.
		If !lAutomato
			If mv_par03 == 1 //Gera arquivo com numeração nova
				lExport := MsgYesNo(STR0063 + CRLF + CRLF + STR0077 + DTOC(FW8->FW8_DTARQ) + CRLF + STR0078 + FW8->FW8_ARQSER + CRLF + CRLF + STR0080,STR0049)
			ElseIf mv_par03 == 2 //Gera arquivo com mesma numeração
				lExport := MsgYesNo(STR0063 + CRLF + CRLF + STR0077 + DTOC(FW8->FW8_DTARQ) + CRLF + STR0078 + FW8->FW8_ARQSER + CRLF + CRLF + STR0079,STR0049)
				cSeqSerasa := FW8->FW8_ARQSER
			Else
				MsGAlert(STR0063 + CRLF + CRLF + STR0077 + DTOC(FW8->FW8_DTARQ) + CRLF + STR0078 + FW8->FW8_ARQSER + CRLF + CRLF + STR0081)	//"Sua configuração não permite a geração de novos arquivos nessa situação. Por favor, verifique parametrização no grupo de perguntas."
				lExport := .F.
			Endif
		else
			lExport	:= .T.
			If mv_par03 == 2
				cSeqSerasa := FW8->FW8_ARQSER
			Elseif mv_par03 == 3
				lExport := .F.
			EndIf
		EndIf	
	Else
		If mv_par03 != 1  
			If !lAutomato
				MsGAlert(STR0081)	//"Sua configuração não permite a geração de novos arquivos nessa situação. Por favor, verifique parametrização no grupo de perguntas."
			EndIf
			lExport := .F.
		Endif
	EndIf

	If lExport

		oMileExport:SetOperation("2") //Exportação
		oMileExport:SetLayout("SERA_ENV") //Nome do layout de recebimento
		
		oMileExport:SetAlias("FW8")
		
		oMileExport:SetTXTFile(cFilePath + AllTrim(mv_par01) + "." + mv_par02)
		
		oMileExport:SetInterface(.T.)
		
		If oMileExport:Activate()
			oMileExport:Export()
			oMileExport:DeActivate()
			FW8->(dbSetOrder(1)) 
			FW8->(dbGoTo(nRecFw8))
			RecLock('FW8',.F.)
			FW8->FW8_DTARQ := dDataBase
			MsUnlock()
			If !lAutomato
				MsGAlert(STR0093) //"Processo finalizado"
			ENDIF
		Else
			If !lAutomato
				ApMsgStop( I18N(STR0035 + oMileExport:GetError(), {} ) )
			EndIf
		EndIf
		
		FW8->(DbClearFilter())
	EndIf
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F770Import
Rotina para processamento do arquivo de retorno SERASA

@author Pedro Lima
@since 29/06/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Function F770Import(cAlias, nRecno, nOpc, lAutomato, cArquivo)
Local oMileExport	:= FWMile():New(.T.)
Private cRetDir		:= ""
Private lProcessa	:= .T.
Private nTamId		:= TamSX3("FW9_IDTITU")[1]
Private nTamPre		:= TamSX3("FW9_PREFIX")[1]
Private nTamNum		:= TamSX3("FW9_NUM")[1]
Private nTamPar		:= TamSX3("FW9_PARCEL")[1]

Default cAlias 		:= "FW8"
Default nRecno		:= FW8->(Recno())
Default nOpc		:= 3 
Default lAutomato	:= .F.
Default cArquivo	:= ""

If lAutomato .Or. Pergunte('FIN770RET',.T.)

	If lAutomato
		mv_par01 := cArquivo
	Endif

	oMileExport:SetOperation("1") //Importação
	oMileExport:SetLayout("SERA_RET") //Nome do layout de retorno

	oMileExport:SetTXTFile(mv_par01)

	oMileExport:SetInterface(.T.)

	If oMileExport:Activate()
		oMileExport:Import()
		oMileExport:DeActivate()
		If !lAutomato
			MsGAlert(STR0093) //"Processo finalizado"
		Endif
	Else
		ApMsgStop( I18N(STR0036 + oMileExport:GetError(), {} ) )
	EndIf
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F770GETARQ
Controle de numeração do arquivo SERASA

@author Rodrigo Pirolo
@since 30/06/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Function F770GETARQ()

Local nCodSera	:= Val(GetMV("MV_ARQSERA"))
Local nTamArq	:= TamSX3("FW8_ARQSER")[1]
Local cNumSera	:= ""

If MV_PAR03 == 1
	//Verifica numero do ultimo Bordero Gerado
	cNumSera := Soma1(StrZero(nCodSera,nTamArq,0),nTamArq)

	While !MayIUseCode( "FW8->FW8_ARQSER" + xFilial("FW8") + cNumSera )	//verifica se esta na memoria, sendo usado
		cNumSera := Soma1(cNumSera) // busca o proximo numero disponivel 
	EndDo                                           

	//Atualiza o conteudo do parametro
	PutMV("MV_ARQSERA",cNumSera)

	//Gravo o código na tabela FW8, para que fique de acordo com o que foi enviado para o SERASA
	RecLock("FW8")
	FW8->FW8_ARQSER := cNumSera
	MsUnlock()
ElseIf MV_PAR03 == 2
	cNumSera := cSeqSerasa
Endif

Return cNumSera

//-------------------------------------------------------------------
/*/{Protheus.doc} F770SEQREG
Controle do sequencial do arquivo

@author Rodrigo Pirolo
@since 30/06/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Function F770SEQREG()

cSeqReg := Soma1(cSeqReg,7)

If Val(cSeqReg) == 1
	DbSelectArea("FW9")
	FW9->(DbSetOrder(1))
	FW9->(DbSeek(xFilial("FW9")+FW8->FW8_LOTE))
ElseIf Val(cSeqReg) > 1
	FW9->(DbSkip())
EndIf

Return cSeqReg

//-------------------------------------------------------------------
/*/{Protheus.doc} Fa770GetOp
Retorna o tipo de Registro no Serasa
I = Inclusão no Serasa
E = Exclusão do Serasa

@author Rodrigo Pirolo
@since 30/06/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Function Fa770GetOp()

Local cRetorno := ""

If FW8->FW8_TIPO == "1"
	cRetorno := "I"
Else
	cRetorno := "E"
EndIf

Return cRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} F770Vencto
Retorna a data de vencimento do titulo

@author Pedro Lima
@since 30/06/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Function F770Vencto()

Local dDataVencto

SE1->(DbSetOrder(1))

If SE1->(MsSeek(xFilial("SE1",FW9->FW9_FILORI)+FW9->(FW9_PREFIX + FW9_NUM + FW9_PARCEL + FW9_TIPO + FW9_CLIENT + FW9_LOJA)))
	dDataVencto := SE1->E1_VENCTO
EndIf

Return dDataVencto

//-------------------------------------------------------------------
/*/{Protheus.doc} F770Client
Retorna informações do cliente

@author Pedro Lima
@since 30/06/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Function F770Client(nOpcao)

Local cRetorno	:= ""
Local cStatus	:= ""
Local cMessage	:= ""
Local cChaveUID	:= ""
Local aAreaFW9	:= {}

SA1->(DbSetOrder(1))

If SA1->(MsSeek(xFilial("SA1",FW9->FW9_FILORI) + FW9->(FW9_CLIENT + FW9_LOJA)))
	If nOpcao == 0
		cRetorno := SA1->A1_NOME
	ElseIf nOpcao == 1
		cRetorno := SA1->A1_PESSOA
	ElseIf nOpcao == 2
		cRetorno := StrZero(Val(SA1->A1_CGC),15)
	ElseIf nOpcao == 3
		cRetorno := SA1->A1_END
	ElseIf nOpcao == 4
		cRetorno := SA1->A1_BAIRRO
	ElseIf nOpcao == 5
		cRetorno := SA1->A1_MUN
	ElseIf nOpcao == 6
		cRetorno := SA1->A1_EST
	ElseIf nOpcao == 7
		cRetorno := SA1->A1_CEP
	ElseIf nOpcao == 8
		cRetorno := SA1->A1_DDD
	ElseIf nOpcao == 9
		cRetorno := PadR(AllTrim(SA1->A1_TEL),9)

		//Aproveito a chamada da função para cada linha da FW9
		//para atualizar o status da FWA e também gerar o registro
		//correspondente na tabela FWB
		DbSelectArea("FWA")
		FWA->(dbSetOrder(4))
		cChaveUID := FW9->FW9_IDDOC
		aAreaFW9 := FW9->(GetArea())
		
		If FWA->(DbSeek(FW9->FW9_FILORI + cChaveUID))

			If FWA->FWA_STATUS $ "1|2"
				cStatus := "2"
				cMessage := STR0025 //"Enviado SERASA"
			ElseIf FWA->FWA_STATUS $ "4|5"
				cStatus := "5"
				cMessage := STR0024 //"Retirada Solicitada"		
			EndIf

			cNumSeq := F770NumSeq(cChaveUID,1)
			
			RecLock("FWA",.F.)
			FWA->FWA_STATUS := cStatus
			FWA->FWA_SEQ := cNumSeq
			FWA->(MsUnlock())
			
			DbSelectArea("FWB")
			DbSetOrder(1)
			FWB->(DbSeek(xFilial("FWB",cFilBase)+cChaveUID))
							
			RecLock("FWB",.T.)
	
			FWB->FWB_FILIAL	:= xFilial("FWB",cFilBase)	//Filial do sistema
			FWB->FWB_LOTE	:= FW9->FW9_LOTE			//Código do Lote Serasa
			FWB->FWB_IDDOC	:= cChaveUID				//Chave do titulo (FK7_IDDOC)
			FWB->FWB_SEQ	:= cNumSeq					//Sequência de registro para o título.
			FWB->FWB_OCORR	:= cStatus					//
			FWB->FWB_DESCR	:= cMessage					//Descrição da ocorrência
			FWB->FWB_DTOCOR	:= dDatabase				//Data da ocorrência (Protheus)
			FWB->FWB_VALOR	:= FW9->FW9_VALOR			//Saldo do título no momento do envio
			FWB->FWB_DTSERA	:= dDataBase				//Data de processamento do arquivo de retorno
			
			FWB->(MsUnlock())					
		EndIf

		//Processa log de geração do arquivo
		SE1->(DbSetOrder(2))
		SE1->(MsSeek(xFilial("SE1",FW9->FW9_FILORI) + FW9->(FW9_CLIENTE + FW9_LOJA + FW9_PREFIX + FW9_NUM + FW9_PARCEL + FW9_TIPO)))
		FinaCONC({{ STR0026,'','','',STR0027 }})	//"INCLUSÃO NO ARQUIVO DE ENVIO SERASA" # //"Registro incluído no arquivo de envio SERASA."

		RestArea(aAreaFW9)
		
	EndIf
EndIf

Return cRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} F770ValTit
Retorna o valor do título com zeros à esquerda

@author Pedro Lima
@since 01/07/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Function F770ValTit()

Local cRetorno := ""

SE1->(DbSetOrder(1))

If SE1->(MsSeek(xFilial("SE1",FW9->FW9_FILORI) + FW9->( FW9_PREFIX + FW9_NUM + FW9_PARCEL + FW9_TIPO + FW9_CLIENT + FW9_LOJA)))
	cRetorno := StrZero(SE1->E1_VALOR*100,15)
EndIf

Return cRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} F770BTip
Retorna o tipo do documento

@author Pedro Lima
@since 01/07/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Function F770BTip()   

Local cRetorno	:= ""

SA1->(DbSetOrder(1))

If SA1->(MsSeek(xFilial("SA1") + FW9->(FW9_CLIENT + FW9_LOJA)))
	If SA1->A1_PESSOA == "F"
		cRetorno := "2"
	Else
		cRetorno := "1"
	EndIf
EndIf

Return cRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} F770BEstp
Retorna a UF do documento

@author Pedro Lima
@since 01/07/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Function F770BEst()   

Local cRetorno	:= ""

SA1->(DbSetOrder(1))

If SA1->(MsSeek(xFilial("SA1") + FW9->(FW9_CLIENT + FW9_LOJA)))
	If SA1->A1_PESSOA == "F"
		cRetorno := SA1->A1_EST
	Else
		cRetorno := SPACE(2)
	EndIf
EndIf

Return cRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} F770SETDIR
Rotina para "setar" o caminho do arquivo de retorno

@author Pedro Lima
@since 02/07/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Function F770SETDIR()

Local	cFilePath	:= StrTran(GetMV("MV_SERRET"),"/","\")

cRetDir := cGetFile(STR0037,STR0038,0,cFilePath,.T.,,.F.)

Return !Empty(cRetDir)

//-------------------------------------------------------------------
/*/{Protheus.doc} F770GETDIR
Rotina para retornar o caminho do arquivo de retorno para o mv_par da pergunta

@author Pedro Lima
@since 02/07/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Function F770GETDIR()

Local cRet := cRetDir

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F770Proc
Rotina para processamento do arquivo de retorno SERASA

@author Pedro Lima
@since 03/07/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Function F770Proc()

Local cChaveTit	:= ""

If lProcessa //Só processo o arquivo caso não haja impedimentos
	If TP_REG == "0" //Header
		FW8->(dbSetOrder(2))
		If FW8->(dbSeek(xFilial("FW8") + CD_LOTE)) .And. AllTrim(TP_ARQ) == "R" //Se localizar o lote na tabela FW8 e for arquivo de retorno
			lProcessa := .T.
			__nRecFW8 := FW8->(Recno())
		Else
			lProcessa := .F.	
			cMsg := STR0028 +" "+ CD_LOTE +" "+ STR0029 //Lote # //não encontrado
		EndIf
	ElseIf TP_REG == "1"
		cChaveTit := SubStr( ID_TIT, 1, nTamId ) //Id Titulo
		FW8->(DbGoTo(__nRecFW8))
		lProcessa := F770AtuRet( AllTrim(CD_OPER), AllTrim(CD_ERRO), cChaveTit )		
	ElseIf TP_REG == "9"
		cMsg := ""
		__nRecFW8 := 0
	EndIf
EndIf

Return lProcessa

//-------------------------------------------------------------------
/*/{Protheus.doc} F770AtuRet
Atualiza o status e sequncia da FWA e FWB
@author Pedro Lima
@since  07/07/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Function F770AtuRet(cOcorr,cErro,cChaveFW9)

Local oModel	:= Nil
Local oFW9		:= Nil
Local oFWA		:= Nil
Local oFWB		:= Nil
Local cNumSeq	:= ""
Local cChaveUID	:= ""
Local cLog		:= ""
Local cStatus	:= ""
Local cMessage	:= ""
Local lRet		:= .F.
Local cQuery	:= ""
Local nRecFW9	:= 0
Local cFilFW9	:= ""

cQuery := "SELECT FW9.R_E_C_N_O_ RECNO "
cQuery += "FROM " + RetSqlName("FW9") + " FW9 "
cQuery += "WHERE "
cQuery += "FW9.FW9_FILIAL  	= ? AND "
cQuery += "FW9.FW9_LOTE 	= ? AND "
cQuery += "FW9.FW9_IDTITU	= ? AND "
cQuery += "FW9.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
oQrySca := FWPreparedStatement():New(cQuery)

oQrySca:SetString(1, FW8->FW8_FILIAL)
oQrySca:SetString(2, FW8->FW8_LOTE)
oQrySca:SetString(3, cChaveFW9)

cQuery	:= oQrySca:GetFixQuery()

nRecFW9 := MpSysExecScalar(cQuery,"RECNO")

If nRecFW9 > 0

	FW9->(DbGoTo(nRecFW9))
	cChaveUID 	:= FW9->FW9_IDDOC
	cFilFW9		:= FW9->FW9_FILORI

	oModel	:= FWLoadModel("FINA770")
	oFW9	:= oModel:GetModel("TITULOFW9")
	oFWA	:= oModel:GetModel("SITTITFWA")
	oFWB	:= oModel:GetModel("MOVTITFWB")
	
	oModel:SetOperation(MODEL_OPERATION_UPDATE)
	oModel:Activate()
	
	oFW9:SeekLine({{"FW9_IDDOC",cChaveUID}})
	
	FWA->(DBSetOrder(4))	//FWA_FILORI+FWA_IDDOC
	If FWA->(DbSeek(cFilFW9 + cChaveUID))
		oFWA:SeekLine({{"FWA_IDDOC",cChaveUID}})
		If !Empty(cErro)
			oFWA:LoadValue("FWA_STATUS", "6" )
			cStatus	:= "6"
			cMessage := STR0030 //"Erro de Process."
		Else
			If cOcorr == "E"
				cStatus	:= "0"
				cMessage := STR0031 //"Reg. Excluído"			
			Else
				cStatus	:= "3"
				cMessage := STR0032 //"Reg. Incluído"			
			EndIf
						
			oFWA:LoadValue("FWA_STATUS", cStatus)
		EndIf

		cNumSeq := Soma1(oFWA:GetValue("FWA_SEQ"))

		FWB->(DbSetOrder(1))
		
		While FWB->(DbSeek(xFilial("FWB")+cChaveUID+cNumSeq)) //Pego o próximo sequencial do arquivo
			cNumSeq := Soma1(cNumSeq)
			FWB->(DbSkip()) 
		EndDo
			
		oFWB:AddLine()

		oFWB:LoadValue( "FWB_FILIAL", xFilial("FWB"))				//Filial do sistema
		oFWB:LoadValue( "FWB_LOTE"	, oFW9:GetValue("FW9_LOTE"))	//Código do Lote Serasa
		oFWB:LoadValue( "FWB_IDDOC"	, oFW9:GetValue("FW9_IDDOC"))	//Chave do titulo (FK7_IDDOC)
		oFWB:LoadValue( "FWB_SEQ"	, cNumSeq)						//Sequência de registro para o título.
		oFWB:LoadValue( "FWB_OCORR"	, cStatus)						//6 - Erro de processamento
		oFWB:LoadValue( "FWB_DESCR"	, cMessage)						//Descrição da ocorrência
		oFWB:LoadValue( "FWB_DTOCOR", dDatabase)					//Data da ocorrência (Protheus)
		oFWB:LoadValue( "FWB_VALOR"	, oFW9:GetValue("FW9_VALOR"))	//Saldo do título no momento do envio
		oFWB:LoadValue( "FWB_CODERR", cErro)						//Código do erro
		oFWB:LoadValue( "FWB_DTSERA", dDataBase)					//Data de processamento do arquivo de retorno

	Endif
	
	If oModel:VldData()
		//Processa log de geração do arquivo
		SE1->(DbSetOrder(1))
		SE1->(DbSeek(xFilial("SE1",oFW9:GetValue("FW9_FILORI"))+oFW9:GetValue("FW9_PREFIX")+oFW9:GetValue("FW9_NUM")+;
					oFW9:GetValue("FW9_PARCEL")+oFW9:GetValue("FW9_TIPO")+oFW9:GetValue("FW9_CLIENT")+oFW9:GetValue("FW9_LOJA")))
		FinaCONC({{ STR0033,'','','',STR0034 }}) //"PROCESSAMENTO DO ARQUIVO DE RETORNO SERASA" # //"Registro processado pelo arquivo de retorno SERASA."                                                                                                                                                                                                                                                                                                                                                                                                                                                               
		oModel:CommitData()
		lRet:= .T.
	Else
		cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
		cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
		cLog += cValToChar(oModel:GetErrorMessage()[6])        	

		Help( ,,"F770RETTIT",,cLog, 1, 0 )	   
		lRet := .F.          
	Endif
	
	oModel:DeActivate()
	oModel:Destroy()
	
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F770Filter
Filtro na Browse

@author Mauricio Pequim Jr
@since  12/03/2016
@version P12
/*/	
//-------------------------------------------------------------------
Static Function F770Filter(cFilter)

FW8->(DbSetFilter(&("{||"+cFilter+"}"),cFilter))

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F770FilTit
Retorna a Filial do Título com base no tamanho da coluna (34)

@author Pedro Lima
@since 20/01/2016
@version 12.1.7
/*/
//-------------------------------------------------------------------
Function F770FilTit()

Local cRetorno	:= Space(34)
Local aArea		:= GetArea()

cRetorno := FW9->FW9_IDTITU

If __lF770FilTit
	cRetorno := ExecBlock('F770FILTIT',.F.,.F.)
EndIf

RestArea(aArea)
Return cRetorno
