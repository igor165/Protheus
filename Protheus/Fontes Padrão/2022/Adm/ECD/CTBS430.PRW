#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'CTBS430.CH'

//Compatibilização de fontes 30/05/2018

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBS430
Cadastro do Bloco K - Plano de Contas Consolidado

@author TOTVS
@since 20/02/2018
@version P12.1.20
/*/
//-------------------------------------------------------------------
Function CTBS430()
Local oBrowse

oBrowse := FWmBrowse():New()

oBrowse:SetAlias( 'CQU' )

oBrowse:SetDescription(STR0019) //"Cadastro do Bloco K - Plano de Contas Consolidado"  

oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu da Rotina

@author TOTVS
@since 03/05/2017
@version P12.1.20
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title STR0001	Action 'VIEWDEF.CTBS430' 	OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina Title STR0002	Action 'VIEWDEF.CTBS430' 	OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina Title STR0003	Action 'VIEWDEF.CTBS430' 	OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina Title STR0004	Action 'VIEWDEF.CTBS430' 	OPERATION 5 ACCESS 0 //"Excluir"
ADD OPTION aRotina Title STR0005	Action 'Cts430ExLt'      	OPERATION 5 ACCESS 0 //"Excluir em Lote"  
ADD OPTION aRotina Title STR0006  	Action 'C430CT1Imp' 		OPERATION 3 ACCESS 0 //"Importar Plano de Contas"   

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de Dados da Rotina

@author TOTVS
@since 03/05/2017
@version P12.1.20
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruCQU := FWFormStruct(1,'CQU')
Local oStruCQV := FWFormStruct(1,'CQV')

Local oModel

SetStruct(oStruCQU, oStruCQV)

oModel := MPFormModel():New('CTBS430', /*<bPre >*/, /*<bPost >*/, /*<bCommit >*/, /*<bCancel>*/)

oModel:AddFields('CQUMASTER',/*cOwner*/,oStruCQU,/*bPreVld*/{|oCQV,cAcao,cCampo,cValAnt,xOldVl| PreValCQU(oCQV,cAcao,cCampo,cValAnt,xOldVl)},{ || ExistChav( "CQU", FWFldGet("CQU_IDBLK")+FWFldGet("CQU_CODCTA"))})

oModel:AddGrid('CQVDETAIL','CQUMASTER',oStruCQV,/*bLinePre*/{|oCQU,nLinha,cAcao, cField|PreValCQV(oCQU,nLinha,cAcao, cField)},/*bLinePost*/,/*bPreVal*/,/*bPosVal*/, /*BLoad*/ )

oModel:SetRelation('CQVDETAIL',{{'CQV_FILIAL','XFilial("CQV")'},{'CQV_IDBLK','CQU_IDBLK'},{'CQV_CODCTA','CQU_CODCTA'}}, CQV->(IndexKey(1)) )

oModel:SetDescription(STR0020) //'Bloco K200 - Plano de Contas Consolidado'

oModel:GetModel("CQVDETAIL"):SetUniqueLine({'CQV_CODEMP','CQV_CTAEMP'})

oModel:GetModel('CQUMASTER'):SetDescription(STR0021) //Registro K200: Plano de Contas Consolidado
oModel:GetModel('CQVDETAIL'):SetDescription(STR0022) //Registro K210: Mapeamento Plano de Contas Empresas Consolidadas
oModel:GetModel('CQVDETAIL'):SetOptional( .T. )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Tela da Rotina

@author TOTVS
@since 03/05/2017
@version P12.1.20
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oStruCQU	:= FWFormStruct(2,'CQU')
Local oStruCQV	:= FWFormStruct(2,'CQV')
Local oModel	:= FWLoadModel('CTBS430')
Local oView

oView := FWFormView():New()

oView:SetModel(oModel)

oView:AddField('VIEW_CQU',oStruCQU,'CQUMASTER')

oView:AddGrid('VIEW_CQV',oStruCQV,'CQVDETAIL')

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TOP' 	,  35 )
oView:CreateHorizontalBox( 'DOWN' 	,  65 )

oView:SetOwnerView('VIEW_CQU','TOP'		)
oView:SetOwnerView('VIEW_CQV','DOWN'	)

oView:EnableTitleView('VIEW_CQU')
oView:EnableTitleView('VIEW_CQV')

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} CT430SelEmp
Importação do plano de contas - CT1

@author TOTVS
@since 29/05/2017
@version P12.1.20
/*/
//-------------------------------------------------------------------
Function C430CT1Imp()

Local oView 	:= FWFormView():New()
Local cIDK030	:= ''
Local cCTADe	:= ''
Local cCTAAte	:= ''
Local lApaga	:= .T.
Local lRet		:= .T.
Local lAmarra 	:= .F.

/* Carrega Pergunta sobre o intervalo das contas a serem importadas */
If Pergunte("CTBS430",.T.)

		cIDK030	:= MV_PAR01
		cCTADe	:= MV_PAR02
		cCTAAte	:= MV_PAR03
		lApaga	:= MV_PAR04 == 1 //sim
		lAmarra := MV_PAR05 == 1

		
		If Empty(cCTAAte) .OR. Empty(cIDK030)
			If Empty(cIDK030)
				Help(" ",1,"C430CT1Imp",,STR0025,1, 0,,,,,,{STR0026}) //"Registro K030 não informado."##Help#'Preencha o parâmetro "Registro K030".'
			Else
				Help(" ",1,"C430CT1Imp",,STR0023,1, 0,,,,,,{STR0024}) //"Intervalo de contas não foi informado corretamente."###'Preencha o parâmetro "Conta Até".'
			Endif
			
			C430CT1Imp()
		Else		
			//Exclusão dos lançamento na subscrita
			If lApaga
	
				MsgRun(STR0013 + STR0027, STR0028, {|| lRet := Cts430Del(cIDK030,cCTADe,cCTAAte)}) //"Excluíndo intervalo selecionado."
																												  // " Aguarde..."
																												  //'Exclusão de Registros'
			//Consulta para informar se a CQU já possui registros
			Else
				
				MsgRun (STR0014,STR0029, {||lRet := ConsCQU(cIDK030,cCTADe,cCTAAte)}) //"Verificando registros de saldos (K300)."     
				 																			//"Consulta CQU"
				
			Endif
			
			If lRet
			
				MsgRun(STR0015 + STR0027, STR0030, {|| GravaCQU(cIDK030,cCTADe,cCTAAte, lAmarra)}) //"Gravando registros nas tabelas do bloco K200." 
																								// " Aguarde..."
																								//'Gravando K200'
			
			Endif
		Endif		
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaCQU
Grava CQU - K200

@author Totvs
@since 06/03/2018
@version P12.1.20
/*/
//-------------------------------------------------------------------
Static Function GravaCQU(cIDK030,cCTADe,cCTAAte, lAmarra)

Local oModel := FWLoadModel("CTBS430")
Local oModelCQU
Local aErrorMsg := {}
Local lRet

Local cAlsCT1	:= GetNextAlias()
Local cQryCT1	:= ''

Default cCTADe		:= ''
Default cCTAAte		:= ''
Default cIDK030		:= ''

//Gravação da CQU		
cQryCT1 := " SELECT CT1_FILIAL, CT1_NTSPED, CT1_CLASSE, CT1_CONTA, CT1_DESC01, CT1_CTASUP"		+ CRLF
cQryCT1 += " FROM " + RetSqlName("CT1") + " CT1 "												+ CRLF
cQryCT1 += " WHERE CT1.CT1_FILIAL = '" + xFilial("CT1") + "' "									+ CRLF
cQryCT1 += " AND CT1.D_E_L_E_T_ = ' ' "															+ CRLF
cQryCT1 += " AND CT1.CT1_CONTA BETWEEN '" + cCTADe + "' AND '" + cCTAAte   + "' " 				+ CRLF
	
If !(ALLTRIM(TcGetDB()) $ "MSSQL|ORACLE|INFORMIX")  
	cQryCT1 := ChangeQuery(cQryCT1)		
Endif
		
dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQryCT1) , cAlsCT1 , .T. , .F.)

dbSelectArea("CQU")
CQU->(dbSetOrder(1)) //CQU_FILIAL+CQU_IDBLK+CQU_CODCTA

oModel:GetModel("CQUMASTER"):GetStruct():SetProperty("CQU_CODNAT",MODEL_FIELD_OBRIGAT,.f.)

oModel:SetOperation(MODEL_OPERATION_INSERT)	
oModelCQU := oModel:GetModel("CQUMASTER")

While !(cAlsCT1)->(Eof())
	
	oModel:Activate()
	
	lRet := oModelCQU:LoadValue("CQU_IDBLK ", cIDK030) .And.; // LoadValue para que o gatilho de preenchimento de grid seja feito apenas após o preenchimento do campo CQU_CODCONTA
			oModelCQU:LoadValue("CQU_CODNAT", (cAlsCT1)->CT1_NTSPED) .And.;
			oModelCQU:SetValue("CQU_INDCTA", If((cAlsCT1)->CT1_CLASSE =="1","S",If((cAlsCT1)->CT1_CLASSE =="2","A"," "))) .And.;
			oModelCQU:LoadValue("CQU_CODCTA", (cAlsCT1)->CT1_CONTA) .And.;
			oModelCQU:SetValue("CQU_NOMCTA", (cAlsCT1)->CT1_DESC01) .And.;
			oModelCQU:SetValue("CQU_NIVEL", CalNiv( (cAlsCT1)->CT1_FILIAL, (cAlsCT1)->CT1_CONTA, (cAlsCT1)->CT1_CTASUP)) .And.;
			oModelCQU:SetValue("CQU_CTASUP", (cAlsCT1)->CT1_CTASUP)

	If lAmarra 
		oModelCQU:RunTrigger("CQU_CODCTA")
	EndIf

	lRet := lRet .And. oModel:VldData()
	
	If !lRet
		aErrorMsg := oModel:GetErrorMessage()
		Help(" ",1,"GravaCQU",,aErrorMsg[6],1, 0,,,,,,aErrorMsg[7])
		oModel:DeActivate()
		Exit
	Else
		oModel:CommitData()
	EndIf
	oModel:DeActivate()

(cAlsCT1)->(dbSkip())
	
Enddo

(cAlsCT1)->(dbCloseArea())
CQU->(DBGoTop())

Return	

//-------------------------------------------------------------------
/*/{Protheus.doc} Cts430ExLt
Exclusao em Lote de Contas 

@author Totvs
@since 06/03/2018
@version P12.1.20
/*/
//-------------------------------------------------------------------
Function Cts430ExLt()

Local cIDK030		:= ''
Local cCTADe		:= ''
Local cCTAAte		:= ''

/* Carrega Pergunta sobre o ID a ser deletado */
If Pergunte("CTBS430EXC",.T.)
	cIDK030	:= MV_PAR01
	cCTADe	:= MV_PAR02
	cCTAAte	:= MV_PAR03
	
	If Empty(cCTAAte) .OR. Empty(cIDK030)
			If Empty(cIDK030)
				Help(" ",1,"Cts430ExLt",,STR0025,1, 0,,,,,,{STR0026}) //"Registro K030 não informado."###'Preencha o parâmetro "Registro K030".'
			Else
				Help(" ",1,"Cts430ExLt",,STR0023,1, 0,,,,,,{STR0024}) //"Intervalo de contas não foi informado corretamente."###'Preencha o parâmetro "Conta Até".'
			Endif
			
			Cts430ExLt() //Executa novamente a função para reabertura dos parâmetros.
			
	Else			
			MsgRun (STR0016, "Excluíndo K200", {|| Cts430Del(cIDK030,cCTADe,cCTAAte)}) //"Excluíndo registros para bloco K200." 
	Endif
Endif	

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Cts430Del
Exclusao em Lote de Contas 

@author Totvs
@since 06/03/2018
@version P12.1.20
/*/
//-------------------------------------------------------------------
Static Function Cts430Del(cIDK030,cCTADe,cCTAAte)

Local oView 		:= FWFormView():New()
Local cQryCQU		:= ''
Local cQryCQV		:= ''
Local lRet			:= .T.
Local cAlsCQX		:= GetNextAlias()

Default cIDK030		:= ''
Default cCTADe		:= ''
Default cCTAAte		:= ''

dbSelectArea("CQX")    
cQryCQX := " SELECT "																	+ CRLF
cQryCQX += " * FROM "+ RetSQLName("CQX") + " CQX"										+ CRLF
cQryCQX += " WHERE CQX.CQX_FILIAL = '" + xFilial("CQX") +	"' "						+ CRLF
cQryCQX += " AND CQX.D_E_L_E_T_ = ' ' "													+ CRLF
cQryCQX += " AND CQX.CQX_IDBLK = '" + cIDK030 + "' "									+ CRLF
cQryCQX += " AND CQX.CQX_CODCTA BETWEEN '" + cCTADe + "' AND '" + cCTAAte   + "' " 		+ CRLF

If !(ALLTRIM(TcGetDB()) $ "MSSQL|ORACLE|INFORMIX")  
	cQryCQX := ChangeQuery(cQryCQX)		
Endif

dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQryCQX) , cAlsCQX , .T. , .F.)

If !(cAlsCQX)->(Eof()) .and. oView <> Nil
	Help(,,'Cts430Del',,STR0011,1,0,,,,,,{STR0017 }) //"Deleção não permitida, pois a conta possui esta em uso pelo cadastro do bloco K300"
													//"Verifique registros cadastrados no bloco K300." 
	lRet	:= .F.
Endif
	
If lRet
	cQryCQU := " DELETE "															+ CRLF
	cQryCQU += " FROM "+ RetSQLName("CQU")											+ CRLF
	cQryCQU += " WHERE CQU_FILIAL = '" + xFilial("CQU") + "' "						+ CRLF
	cQryCQU += " AND CQU_IDBLK = '" + cIDK030 + "' "								+ CRLF
	cQryCQU += " AND CQU_CODCTA BETWEEN '" + cCTADe + "' AND '" + cCTAAte   + "' " 	+ CRLF
	TCSQLEXEC(cQryCQU)
	
	cQryCQV := " DELETE "															+ CRLF
	cQryCQV += " FROM "+ RetSQLName("CQV")											+ CRLF
	cQryCQV += " WHERE CQV_FILIAL = '" + xFilial("CQV") + "' "						+ CRLF
	cQryCQV += " AND CQV_IDBLK = '" + cIDK030 + "' "								+ CRLF
	cQryCQV += " AND CQV_CODCTA BETWEEN '" + cCTADe + "' AND '" + cCTAAte   + "' " 	+ CRLF
	TCSQLEXEC(cQryCQV)
Endif

(cAlsCQX)->(dbCloseArea())

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} ConsCQU
Exclusao em Lote de Contas 

@author Totvs
@since 06/03/2018
@version P12.1.20
/*/
//-------------------------------------------------------------------
Static Function ConsCQU(cIDK030,cCTADe,cCTAAte)

Local cQryCQU		:= ''
Local lRet			:= .T.
Local oView 		:= FWFormView():New()
Local cAlsCQU		:= GetNextAlias()

Default cIDK030		:= ''
Default cCTADe		:= ''
Default cCTAAte		:= ''
 
cQryCQU := " SELECT "															+ CRLF
cQryCQU += " * FROM "+ RetSQLName("CQU")										+ CRLF
cQryCQU += " WHERE CQU_FILIAL = '" + xFilial("CQU") + "' "						+ CRLF
cQryCQU += " AND D_E_L_E_T_ = ' ' "												+ CRLF
cQryCQU += " AND CQU_IDBLK = '" + cIDK030 + "' "								+ CRLF
cQryCQU += " AND CQU_CODCTA BETWEEN '" + cCTADe + "' AND '" + cCTAAte   + "' " 	+ CRLF

If !(ALLTRIM(TcGetDB()) $ "MSSQL|ORACLE|INFORMIX")  
	cQryCQU := ChangeQuery(cQryCQU)		
Endif
				
dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQryCQU) , cAlsCQU , .T. , .F.)

If !(cAlsCQU)->(Eof())
	If oView <> Nil
		Help(,,'ConsCQU',,STR0007,1,0,,,,,,{STR0018}) //"Importação não executada - Já existem registros cadastrados para o intervalo definido"		
													 //"Verifique intervalo informado." 
	Endif

	lRet	:= .F.
Endif

(cAlsCQU)->(dbCloseArea())

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} CalNiv
Calculo do nivel das contas

@author Totvs
@since 06/03/2018
@version P12.1.20
/*/
//-------------------------------------------------------------------
Static Function CalNiv(cFilCT1,cConta,cCtaSup)

Local nNivel	:= 1
Local aArea		:= GetArea()

Default cFilCT1	:= ''
Default cConta	:= ''
Default cCtaSup	:= ''

dbSelectArea("CT1")       
dbSetOrder(1)

If CT1->(MsSeek(cFilCT1+cConta))	
	While CT1->(!Eof()) .And. CT1->CT1_FILIAL == cFilCT1 .And. !Empty(CT1->CT1_CTASUP)

		If CT1->(MsSeek(xFilial()+CT1->CT1_CTASUP))	    	
			nNivel++
 		EndIf	

	Enddo

EndIf

RestArea(aArea)

Return (nNivel)

//-------------------------------------------------------------------
/*/{Protheus.doc} PreValCQV
Calculo do nivel das contas

@author Totvs
@since 06/03/2018
@version P12.1.20
/*/
//-------------------------------------------------------------------

Static Function PreValCQV(oCQV,nLinha,cAcao, cField)

Local oModel	:= FWModelActive()
Local cNat		:= oModel:GetModel("CQUMASTER"):GetValue("CQU_INDCTA")
Local lRet		:= .T.

If cField == "CQV_CODEMP" .And. cAcao == "CANSETVALUE"
	lRet := oCQV:GetValue("CQV_XFLAG") <> "T"
EndIf

If lRet
	If cNat = "S" .AND. cAcao $ "CANSETVALUE|UNDELETE"

		lRet	:= .F.
		
		If !IsBlind()  //este tratamento eh orientacao do frame pois quando usado CANSETVALUE não exibe o Help
			MSGINFO("PreValCQV - "+STR0031, STR0032 )	    //"Conta Sintética não permite inclusão do painel K210" ##//"Verifique a natureza da conta."
		Else
			Help(,,'PreValCQV',,STR0031,1,0,,,,,,{STR0032}) //"Conta Sintética não permite inclusão do painel K210" ##//"Verifique a natureza da conta."
		EndIf

	Endif

	If lRet .AND. cAcao $ "CANSETVALUE|UNDELETE" .And. Empty(FWFldGet("CQU_IDBLK"))
		lRet := .F.		

		If !IsBlind()  //este tratamento eh orientacao do frame pois quando usado CANSETVALUE não exibe o Help
			MSGINFO("PreValCQV - "+STR0033, STR0034 )	    //"Não é possivel incluir o painel K210 sem possuir o ID do bloco K informado." ##// "Preencha o campo Id.Bloco K (CQU_IDBLK)."
		Else
			Help(" ",1,"PreValCQV",,STR0033,1, 0,,,,,,{STR0034}) //"Não é possivel incluir o painel K210 sem possuir o ID do bloco K informado." ##// "Preencha o campo Id.Bloco K (CQU_IDBLK)."
		EndIf

	EndIf

	If lRet .AND. cAcao == "UNDELETE" .And. !Empty(FWFldGet("CQU_IDBLK")) .And. !Empty(oCQV:GetValue("CQV_CODEMP"))
		lRet := ExistCpo("CQR",FWFldGet("CQU_IDBLK")+oCQV:GetValue("CQV_CODEMP"))
	EndIf

Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PreValCQU
Calculo do nivel das contas

@author Totvs
@since 06/03/2018
@version P12.1.20
/*/
//-------------------------------------------------------------------

Static Function PreValCQU(oCQU,cAcao,cCampo,cConteudo,xOldContent)

Local oModel	:= oCQU:GetModel() //FWModelActive()

Local oCQV		:= oModel:GetModel("CQVDETAIL")
Local cNat		:= oModel:GetModel("CQUMASTER"):GetValue("CQU_INDCTA")
Local lRet		:= .T.


//-------------------------------------------------------------------------------------------------------
// Não permite a alteração do campo Natureza caso algum dado relacionado já esteja preenchido
//-------------------------------------------------------------------------------------------------------	
If lRet .And. cAcao $ "CANSETVALUE" .And. cCampo ==  "CQU_INDCTA" .And. cConteudo == "S" .And. !oCQV:IsEmpty() .And. oCQV:Length(.T.) > 0 
	lRet	:= .F.

	If !IsBlind()  //este tratamento eh orientacao do frame pois quando usado CANSETVALUE não exibe o Help
		MSGINFO("PreValCQU - "+STR0031, STR0032 )	//"Conta Sintética não permite inclusão do painel K210" ## 	//"Verifique a natureza da conta."
	Else
		Help(,,'PreValCQU',,STR0031,1,0,,,,,,{STR0032}) //"Conta Sintética não permite inclusão do painel K210" ## 	//"Verifique a natureza da conta."
	EndIf

Endif

Return lRet

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} AmK210CQV

Função que alimenta o bloco K210 no grid

@params:
oModel: Objeto. Instância da classe FwFormModel ou FwFormView
cField: Char. Variavel que guarda o campo pelo qual o gatilho foi acionado
@return: 

@sample:
    
@author Totvs

@since 14/02/2019
@version 12.1.25
*/
//------------------------------------------------------------------------------------------------------

Static Function AmK210CQV(oModel, cField)

Local oModelCQU 
Local oModelCQV 
Local oView

Local nLinha 	:= 1
Local nI		:= 0

Local cFilCQR 	:= xFilial("CQR")
Local cIdBlkCQR := ''
Local cContaCQU := ''

Local aAreaCQR	:= CQR->(GetArea())

Local lFillGrid	:= .f.

oView := FWViewActive()

oModelCQU := oModel:GetModel():GetModel("CQUMASTER")
oModelCQV := oModel:GetModel():GetModel("CQVDETAIL")

// Amarração só é feita em caso de conta analitica
If ( oModelCQU:GetValue("CQU_INDCTA") <> "S" )

// Caso o gatilho seja chamado pelo campo Id de Bloco e haja registros alterados manualmente, o Cod Conta e o grid são limpos
	
	If cField == 'CQU_IDBLK' .And. !oModelCQV:IsEmpty()

		oModelCQV:ClearData(.t.)
		
	EndIf

	lFillGrid := oModelCQV:IsEmpty()

	cIdBlkCQR := oModelCQU:GetValue("CQU_IDBLK")
	cContaCQU := oModelCQU:GetValue("CQU_CODCTA")	

	// Ação de preenchimento do grid só é executada caso os campos de ID e Cod Conta estejam preenchidos	
	If ( !Empty(cContaCQU) .And. !Empty(cIdBlkCQR) )

	// Preenchimento do grid caso não haja nenhum registro no grid
		If ( lFillGrid )

	// Buscando as empresas do bloco K100 que estão na tabela CQR	
			CQR->(dbSetOrder(1))

			If CQR->(MsSeek(cFilCQR+cIdBlkCQR))

				// Inserindo Cod de Empresa e Conta no grid da K210	
				oModelCQV:GoLine(nLinha)
				oModelCQV:SetValue('CQV_CODEMP', CQR->CQR_CODEMP)
				oModelCQV:SetValue('CQV_CTAEMP', cContaCQU)
				oModelCQV:SetValue('CQV_IDBLK', cIdBlkCQR)
				
				CQR->(dbSkip())

				// Em caso de mais de uma empresa inserido no bloco
				While CQR->(!Eof()) .And. CQR->CQR_IDBLK == cIdBlkCQR

					nLinha := oModelCQV:AddLine()
					
					If oModelCQV:GetLine() <> nLinha
						oModelCQV:GoLine(nLinha)
					Else
						oModelCQV:SetValue('CQV_CODEMP', CQR->CQR_CODEMP)
						oModelCQV:SetValue('CQV_CTAEMP', cContaCQU)
						oModelCQV:SetValue('CQV_IDBLK', cIdBlkCQR)
						CQR->(dbSkip())
					EndIf
				Enddo
			EndIf

		// Caso o grid esteja preenchido, serão sobrescritos apenas as linhas inseridas por gatilho
		Else
			For nI := 1 to oModelCQV:Length()

				oModelCQV:GoLine(nI)

				If ( !oModelCQV:IsDeleted()  )

					If ( oModelCQV:GetValue("CQV_XFLAG") <> "M" )
						oModelCQV:SetValue("CQV_CTAEMP",cContaCQU)						
					EndIf
				EndIf
			Next nI
		EndIf

	EndIf
		
	oModelCQV:GoLine(1)

	// Refresh só em feito em caso de View ativa
	If ( Valtype(oView) == "O" .And. oView:IsActive())
		oView:Refresh("VIEW_CQV")
	EndIf

	RestArea(aAreaCQR)
	
Endif

Return	

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} CS430VldTrig

Função que faz a validação se o gatilho que alimenta o grid deve ou não ser acionado

@params:
oModelCQU: Objeto. Instância da classe FwFormModel ou FwFormView
cField: Char. Variavel que guarda o campo pelo qual o gatilho foi acionado
xNewValue: Indefinido. Variavel que guarda o valor do campo pelo qual o gatilho foi acionado

@return: lRet

@sample:
    
@author Totvs

@since 14/02/2019
@version 12.1.25
*/
//------------------------------------------------------------------------------------------------------


Static Function CS430VldTrig(oModelCQU,cField,xNewValue)

Local lRet := .T.

Local oModelCQV	:= oModelCQU:GetModel():GetModel("CQVDETAIL")

Local cMsgYesNo		:= ""

If !Empty(xNewValue)
	If !oModelCQV:IsEmpty() .And. !IsBlind()
		
		cMsgYesNo := STR0037 	// "Os registros K210 já foram preenchidos anteriormente."
		cMsgYesNo += STR0038	// "Deseja Sobrescrever a coluna de Conta da Empresa (cujas contas foram preenchidas automaticamente) com a nova conta informada? "
		cMsgYesNo += STR0039  	// "Importante: Contas do bloco K210 que foram preenchidas manualmente, não serão."

		lRet := MsgYesNo(cMsgYesNo)
	EndIf
EndIf

Return(lRet)

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} SetStruct

Função usada para criar adicionar campos e gatilhos no model

@params:
oStructCQU: Objeto. Instância da classe FwFormModel ou FwFormViewStruct
oStructCQV: Objeto. Instância da classe FwFormModel ou FwFormViewStruct

@return: 

@sample:
    
@author Totvs

@since 14/02/2019
@version 12.1.25
*/
//------------------------------------------------------------------------------------------------------


Static function SetStruct(oStruCQU, oStruCQV)

	Local bTrigger 		:= {|oModel, cField, xVal| AmK210CQV(oModel, cField), xVal}
	Local bVldTrigger	:= {|oMdlCQU,cFldCQU,xValue| CS430VldTrig(oMdlCQU,cFldCQU,xValue) }
	Local bTriggerFlag  := {|oModelCQV, cField, xVal| FlagTrigg(oModelCQV, cField, xVal) }

// Gatilho que preenche o grid com os Cod. Empresa e Cod. Conta Emp
	oStruCQU:AddTrigger("CQU_IDBLK", "CQU_IDBLK", , bTrigger)
	oStruCQU:AddTrigger("CQU_CODCTA", "CQU_CODCTA", bVldTrigger, bTrigger)
	

// Campo virtual utilizado para marcar se o codigo de conta do grid foi alterado manualmente
 
	oStruCQV:AddField(  STR0040,;  								// Título do Campo
						STR0040,; 								// Tooltip da descrição do campo
						"CQV_XFLAG",;                           // Nome do Campo
						"C",;    								// Tipo do Campo
						1,; 									// Tamanho do Campo
						0,; 									// Decimal do Campo
						{|| .T.},;                              // Bloco de validação do campo (Valid)
						{||	.T.},;                              // Bloco de edição do campo (When)
						Nil,;                                   // Lista de valores, caso seja um combobox
						Nil,;                                   // Se o campo é obrigatório
						Nil,;                                   // Inicializador padrão do campo
						Nil,;                                   // O campo compõe uma chave única?
						.F.,;                                   // Não atualiza o conteúdo?
						.T. )                                   // O campo é virtual?

	If ( !oStruCQV:HasField("CQV_IDBLK") )

        oStruCQV:AddField(  GetSx3Cache("CQV_IDBLK","X3_TITULO"),;  // Título do Campo
                            GetSx3Cache("CQV_IDBLK","X3_DESCRIC"),; // Tooltip da descrição do campo
                            "CQV_IDBLK",;                           // Nome do Campo
                            GetSx3Cache("CQV_IDBLK","X3_TIPO"),;    // Tipo do Campo
                            GetSx3Cache("CQV_IDBLK","X3_TAMANHO"),; // Tamanho do Campo
                            GetSx3Cache("CQV_IDBLK","X3_DECIMAL"),; // Decimal do Campo
                            Nil,;                              		// Bloco de validação do campo (Valid)
                            {||	.T.},;                              // Bloco de edição do campo (When)
                            Nil,;                                   // Lista de valores, caso seja um combobox
                            Nil,;                                   // Se o campo é obrigatório
                            MontaBlock(GetSx3Cache("CQV_IDBLK","X3_RELACAO")),;                                   // Inicializador padrão do campo
                            Nil,;                                   // O campo compõe uma chave única?
                            .F.,;                                   // Não atualiza o conteúdo?
                            .T. )                                   // O campo é virtual?

    EndIf					

	// Gatilho utilizado para indicar se a linha do grid foi preenchida manualemente ou via gatilho
	oStruCQV:AddTrigger("CQV_CTAEMP", "CQV_XFLAG", {||.T. }, bTriggerFlag )	

	//Atualiza as propriedades da estrutura
	oStruCQU:SetProperty("CQU_IDBLK", MODEL_FIELD_VALID, {|oMdlCQU,cFld,xCnt,nLine,e| VldIdBlK(oMdlCQU,cFld,xCnt,nLine,e) })
	
Return

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} FlagTrigg

Função usada para acionar o gatilho no campo virtual XFLAG que será usado para identificar quais linhas do grid
foram alteradas manualmente

@params:
oModelCQV: Objeto. Instância da classe FwFormModel ou FwFormView
cField: Char. Variavel que guarda o campo pelo qual o gatilho foi acionado
xVal: Indefinido. Variavel que guarda o valor do campo pelo qual o gatilho foi acionado

@return: cRet

@sample:
    
@author Totvs

@since 14/02/2019
@version 12.1.25
*/
//------------------------------------------------------------------------------------------------------

Static Function FlagTrigg(oModelCQV, cField, xVal)

	Local oModelCQU := oModelCQV:GetModel():GetModel("CQUMASTER")
	Local cRet := ''
	
	If ( IsInCallStack("AmK210CQV") )
		cRet := "T"
	Else
		cRet := IIF( xVal == oModelCQU:GetValue("CQU_CODCTA"), "T", "M")
	EndIf	

Return cRet

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} VldIdBlK

Função que faz a validação do campo Id. Bloco K. (CQU_IDBLK)

@params:
oModelCQV: Objeto. Instância da classe FwFormModel ou FwFormView
cField: Char. Variavel que guarda o campo pelo qual o gatilho foi acionado
xContent: Indefinido. Variavel que guarda o valor do campo pelo qual o gatilho foi acionado
nLine: Numerico. Variavel que guarda a linha do grid que esta selecionada

@return: lRet

@sample:
    
@author Totvs

@since 14/02/2019
@version 12.1.25
*/
//------------------------------------------------------------------------------------------------------

Static Function VldIdBlK(oModelCQV,cField,xContent,nLine,e)

	Local lRet	:= .t.

	Local oCQU := oModelCQV:GetModel():GetModel("CQUMASTER")

	If lRet := ExistCpo("CQQ", xContent)
		lRet := CS430VldTrig(oCQU, "CQU_IDBLK")
	Endif
Return(lRet)

