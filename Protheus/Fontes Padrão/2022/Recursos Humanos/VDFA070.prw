#include "VDFA070.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} VDFA070  
	Manutenção de Substituições
	@owner Fabricio Amaro
	@author Fabricio Amaro
	@since 02/10/2013
	@version P11 Release 8
/*/
//	project GESTÃO DE PESSOAS E VIDA FUNCIONAL MP-MT (M12RHMP)
Function VDFA070()
	Local oBrowse
	Private cTab := chr(9)
	Private cEnt := chr(13)+chr(10)
	
	Private aFldRot 	:= {'RA_NOME'}
	Private aOfusca	 	:= If(FindFunction('ChkOfusca'), ChkOfusca(), {.T.,.F.}) //[1] Acesso; [2]Ofusca
	Private lOfuscaNom 	:= .F. 
	Private aFldOfusca 	:= {}

	If aOfusca[2]
		aFldOfusca := FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRot ) // CAMPOS SEM ACESSO
		IF aScan( aFldOfusca , { |x| x:CFIELD == "RA_NOME" } ) > 0
			lOfuscaNom := FwProtectedDataUtil():IsFieldInList( "RA_NOME" )
		ENDIF
	EndIf

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('RI8')
	oBrowse:SetDescription(STR0001)//'Manutenção de Substituições'
	oBrowse:DisableDetails()
	oBrowse:Activate()
	
Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.VDFA070' OPERATION 2 ACCESS 0//'Visualizar'
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.VDFA070' OPERATION 3 ACCESS 0//'Incluir'
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.VDFA070' OPERATION 4 ACCESS 0//'Alterar'
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.VDFA070' OPERATION 5 ACCESS 0//'Excluir'
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.VDFA070' OPERATION 8 ACCESS 0//'Imprimir'

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruRI8 := FWFormStruct( 1, 'RI8', /*bAvalCampo*/,/*lViewUsado*/ )
	Local oModel
	
	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('VDFA070', /*bPreValidacao*/,  {|oModel|VDFA070POS(oModel)},  {|oModel|VDFA070GRV(oModel)}, /*bCancel*/ )

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( 'RI8MASTER', /*cOwner*/, oStruRI8, /*bPreValidacao*/, /*bPosValidacao*/ , /*bCarga*/ )

	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( STR0010 )//'Manutenção de Substituições'
	
	oModel:SetPrimaryKey( { "RI8_FILIAL", "RI8_MAT" } )

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel( 'RI8MASTER' ):SetDescription( STR0011 )//'Dados da Substituição'
	
Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel   := FWLoadModel( 'VDFA070' )
	// Cria a estrutura a ser usada na View
	Local oStruRI8 := FWFormStruct( 2, 'RI8' )
	Local oView  

	// Cria o objeto de View
	oView := FWFormView():New()
	
	// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )
	
	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_RI8', oStruRI8, 'RI8MASTER' )
	
	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'TELA' , 100 )
	
	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_RI8', 'TELA' )
	
	// Define fechamento da tela
	oView:SetCloseOnOk( {||.T.} )
	
Return oView

//-------------------------------------------------------------------
//FUNÇÃO DE VERIFICAÇÃO NA CONFIRMAÇÃO DA ROTINA
Static Function VDFA070POS(oModel)
	Local lRet 		 := .T.
	Local cPeriodo	 := Alltrim(oModel:GetValue('RI8MASTER','RI8_PERIOD'))
	Local cProcSub	 := POSICIONE("SRA",1, oModel:GetValue('RI8MASTER','RI8_FILSUB')+oModel:GetValue('RI8MASTER','RI8_MATSUB'),"RA_PROCES")
	Local cRotPadr	 := IIF(fGetCalcRot("1")== NIL, "FPB",fGetCalcRot("1"))
	Local nOperation := oModel:GetOperation()
	Local cPerFec    := ""

	cPerFec  := POSICIONE("RCH",4, FWXFILIAL("RCH",Alltrim(oModel:GetValue('RI8MASTER','RI8_FILSUB')))+ cProcSub + cRotPadr + cPeriodo ,"RCH_DTFECH")

	If nOperation == 3 .OR. nOperation == 4 //INCLUIR OU ALTERAR
		If !(Empty(cPerFec))
			cMsg := STR0013+cPeriodo+STR0012//" já se encontra fechado!"//"O período para pagamento informado "
			Help(,,STR0019,,cMsg,1,0,,,,,,{STR0029})
			lRet := .F. 
		EndIf

		If ((cFilAnt + FwFldGet('RI8_MAT')) == (FwFldGet('RI8_FILSUB') + FwFldGet('RI8_MATSUB'))) .AND. lRet
			Help(,,STR0019,,STR0024,1,0,,,,,,{STR0026}) //Atenção! # O substituto informado é o prórpio substituído! # Altere a matrícula do substituto OU do substituído.
			lRet := .F. 
		EndIf
	
		If nOperation == 4 .AND. lRet
			lRet := VldAltRI8(oModel)
		ENDIF

	ElseIf nOperation == 5
		lRet := VldDelRI8()

	EndIf
Return lRet


//-------------------------------------------------------------------
//FUNÇÃO DE GRAVAÇÃO NA CONFIRMAÇÃO DA ROTINA
Static Function VDFA070GRV(oModel)

	Local lRet 		 := .T.
	Local cPeriodo	 := (oModel:GetValue('RI8MASTER','RI8_PERIOD'))
	Local cFilSub	 := (oModel:GetValue('RI8MASTER','RI8_FILSUB'))	
	Local cMatSub	 := (oModel:GetValue('RI8MASTER','RI8_MATSUB'))	
	Local nPercent	 := (oModel:GetValue('RI8MASTER','RI8_PERCEN'))	
	Local cNumID	 := (oModel:GetValue('RI8MASTER','RI8_NUMID'))	
	Local nValor	 := (oModel:GetValue('RI8MASTER','RI8_VALOR'))	
	Local nParcela	 := (oModel:GetValue('RI8MASTER','RI8_PARCEL'))	
	Local nOperation := oModel:GetOperation()
	Local dVenc      := POSICIONE("RCH",9, FWXFILIAL("RCH") + cPeriodo,"RCH_DTPAGO")	

	Begin Transaction
	
		IF nOperation == 3 .OR. nOperation == 4 //INCLUIR OU ALTERAR 

			If !(EMPTY(cFilSub))	.AND. ;
			   !(EMPTY(cMatSub))	.AND. ;
			   !(EMPTY(cPeriodo))	.AND. ;
			   !(EMPTY(nPercent))	.AND. ;
			    (EMPTY(cNumID))		.AND. ;  //INDICA QUE JÁ FOI INTEGRADO COM A SRK
			   nValor 		> 0		.AND. ;
			   nParcela 	> 0   
		
			
				cVerba  := RetValSrv( "1334" , cFilSub , "RV_COD" , 2 )
				cCC     := POSICIONE("SRA",1,cFilSub + cMatSub,"RA_CC")
				cProces := Posicione("SRA",1,cFilSub + cMatSub,"RA_PROCES")
	
				cDoc := fProxDoc(cFilSub,"SRK",cVerba,cMatSub)  //PROXIMO DOCUMENTO
				If !(Empty(cDoc))
					cDoc := StrZero(Val(cDoc) + 1, TamSX3("RK_DOCUMEN")[1] )
				Else
					cDoc := StrZero(1,TamSX3("RK_DOCUMEN")[1])
				EndIf
				
				dbSelectArea("SRK")
				RecLock("SRK",.T.)
				
					RK_FILIAL 	:= cFilSub
					RK_MAT		:= cMatSub
					RK_PD		:= cVerba
					RK_VALORTO	:= nValor
					RK_PARCELA	:= nParcela
					RK_VALORPA	:= RK_VALORTO / RK_PARCELA 
					RK_VALORAR	:= ( RK_VALORPA * RK_PARCELA ) - RK_VALORTO
					RK_DTVENC	:= dVenc
					RK_DTMOVI	:= dDataBase
					RK_DOCUMEN	:= cDoc
					RK_CC		:= cCc
					RK_NUMID	:= "RI8" + RK_FILIAL + RK_MAT + RK_PD + RK_DOCUMEN
					RK_PERINI	:= cPeriodo
					RK_PROCES	:= cProces
					RK_NUMPAGO	:= "01"
					RK_ROTEIR	:= fGetCalcRot('1')
					RK_STATUS	:= "2"
					RK_VLSALDO	:= nValor
					
				MsUnLock()
				
				lRet := oModel:SetValue('RI8MASTER','RI8_NUMID',RK_NUMID)
			
				lRet := FWFormCommit( oModel )	
				
				MsgBox(STR0015,STR0016,"INFO")//"O valor a ser pago foi gravado com sucesso em Valores Futuros!"//"Valores Futuros"
			
			Else
				//GRAVA O MODELO
				lRet:= FWFormCommit(oModel)
			EndIf
		ElseIf nOperation == 5 //EXCLUIR
			If !(Empty(cNumID)) //CASO TENHA SRK - VALORES FUTUROS
				dbSelectArea("SRK")
				dbSetOrder(2)
				If dbSeek(cFilSub + cMatSub + AllTrim(cNumID))
					RecLock("SRK", .F. )
					("SRK")->( dbDelete() )
					("SRK")->( MsUnlock() )
				EndIf
				MsgBox(STR0025,STR0016,"INFO")// 'O registro que estava em Valores Futuros também foi excluído!' "Valores Futuros"
			EndIf
			
			lRet:= FWFormCommit(oModel)
		EndIf
	
	End Transaction

Return lRet

//-------------------------------------------------------------------
//FUNÇÃO PARA VALIDAÇÃO ESPECÍFICA DO CAMPO RI8_FATGER
Function fValCatEx()
	Local aArea	:= GetArea()
	Local lRet	:= .T.
	Local cFil	:= M->RI8_FILSUB
	Local cMat	:= M->RI8_MATSUB
	Local cFatGer := M->RI8_FATGER

	If cFatGer == "3" //EXERCICIO CUMULATIVO
		cCatFunc := Posicione("SRA",1,cFil + cMat,"RA_CATFUNC")
		If !(cCatFunc $ "0*1")
			cMsg := STR0017+cEnt+cEnt//"Categoria do SUBSTITUTO dever ser 0-Membro ou 1-Membro em Comissão, quando a opção do fato gerador for 3 – Exercicio Cumulativo!"
			If lOfuscaNom
				cMsg += OEMTOANSI( STR0030 ) + cFil + "/" + cMat
			else
				cMsg += AllTrim(Posicione("SRA",1,cFil + cMat,"RA_NOME")) 
			ENDIF
			cMsg += STR0018 +cCatFunc//" - Categoria: "
			Help(,,STR0019,,cMsg,1,0,,,,,,{STR0028})//"Atenção!"
			lRet := .F.
		EndIf
	EndIf
	RestArea( aArea )
Return lRet


// FUNÇÃO DE VALIDAÇÃO DO BOTÃO ALTERAR DE SUBSTITUIÇÕES (RI8)
Function VldAltRI8(oModel)
	Local cPeriodo := Alltrim(M->RI8_PERIOD)
	Local cPerFec  := POSICIONE("RCH",9, FWXFILIAL("RCH") + cPeriodo,"RCH_DTFECH")
	Local lRet 	   := .T.

	If !(Empty(cPerFec))
		HELP("", 1, "HELP", STR0019, STR0007, 1, 0) // Não será permitido alterar pois o período já se encontra fechado!
		lRet := .F.

	ElseIf !(Empty( M->RI8_NUMID ) )
		HELP("", 1, "HELP", STR0019, STR0008, 1, 0) // Não será permitido alteração pois já houve integração com Valores Futuros! Exclua e refaça o lançamento!
		lRet := .F.

	ElseIf !(M->RI8_ORIGEM == "1") // Se não for manual
		HELP("", 1, "HELP", STR0019, STR0023, 1, 0) // Origem Automática! Não é permitida manutenção!
		lRet := .F.
	EndIf
Return lRet


// FUNÇÃO DE VALIDAÇÃO DO BOTÃO EXCLUIR DE SUBSTITUIÇÕES (RI8)
Function VldDelRI8()
	Local lRet      := .T.
	Local oMDL      := FWModelActive()
	Local oMDLRI8   := oMDL:GetModel("RI8MASTER")
	Local cPeriodo	:= Alltrim(oMDLRI8:GetValue("RI8_PERIOD"))
	Local cProcSub	:= POSICIONE("SRA",1, oMDLRI8:GetValue("RI8_FILSUB") + oMDLRI8:GetValue("RI8_MATSUB"), "RA_PROCES")
	Local cRotPadr	:= IIF(fGetCalcRot("1") == NIL, "FPB", fGetCalcRot("1"))
	
	If !(Alltrim(oMDLRI8:GetValue("RI8_ORIGEM")) == "1") //SE NÃO FOR MANUAL
		HELP("", 1, "HELP", STR0019, STR0023, 1, 0) //'Origem Automática! Não é permitida manutenção!'
		lRet := .F.
	EndIf

	cPerFec  := POSICIONE("RCH",4, FWXFILIAL("RCH",Alltrim(oMDLRI8:GetValue("RI8_FILSUB"))) + cProcSub + cRotPadr + cPeriodo ,"RCH_DTFECH")

	If !(Empty(cPerFec))
		HELP("", 1, "HELP", STR0019, STR0009, 1, 0) // "Não será permitido excluir pois já houve integração com Valores Futuros e o período já se encontra fechado!"
		lRet := .F.
	EndIf
Return lRet


//-------------------------------------------------------------------
//FABRICIO 04/10/2013
//VALIDAÇÕES NOS CAMPOS PARA EVITAR O LANÇAMENTO DE INFORMAÇÕES ERRADAS
Function fValSub(cFil,cMat)
	Local aArea     := GetArea()
	Local lRet 		:= .T. 
	
	Local dDtDe  := FwFldGet('RI8_DATADE') //(oModel:GetValue('RI8MASTER','RI8_DATADE'))
	Local dDtAte := FwFldGet('RI8_DATATE') //(oModel:GetValue('RI8MASTER','RI8_DATATE'))
	Local nRecno := RI8->(Recno())
	
	Private cMsgNovo := ""
	If !Empty(cFil) .AND. !Empty(cMat) .AND. !Empty(dDtDe) .AND. !Empty(dDtAte) 
		lRet := fVerRI8(cFil,cMat,dDtDe,dDtAte,.T.,.T.,.F.,.F.,.T., ,nRecno )
	EndIf

	If !lRet
		Help(,,STR0020,,STR0021,1,0)//"Erro"//"Execute os procedimentos da mensagem anterior!"
	EndIf
	
	RestArea( aArea )
Return lRet

//-------------------------------------------------------------------
//Função que analisa qual era a tabela do Substituído no período em que houve a substituição 
Function fVlCumulat(cFil,cMat)
	Local aArea     := GetArea()
	Local aAreaSRA  := SRA->(GetArea())
	Local nVlIniTab := 0
	Local nValAcum  := 0
	Local nDias		:= 0

	Local dDtDe    := FwFldGet('RI8_DATADE') //(oModel:GetValue('RI8MASTER','RI8_DATADE'))
	Local dDtAte   := FwFldGet('RI8_DATATE') //(oModel:GetValue('RI8MASTER','RI8_DATATE'))
	Local nPercent := FwFldGet('RI8_PERCEN') //(oModel:GetValue('RI8MASTER','RI8_PERCEN'))
	
	Private cTabela   := ""		//-- Tabela Salarial
	Private cNvlTab	  := ""		//-- Nivel da Tabela Salarial
	Private cFaixa 	  := ""		//-- Faixa da Tabela Salarial
	Private cTabCom   := ""		//-- Tabela Salarial quando Comissionado
	Private cNivelCom := ""		//-- Nivel da Tabela Salarial quando Comissionado
	Private cFaixaCom := ""		//-- Faixa da Tabela Salarial quando Comissionado

	dbSelectArea("SRA")
	dbSetOrder(1)
	dbSeek(cFil + cMat)

	If Empty(dDtDe)
		dDtDe := dDataBase
	EndIf
	If Empty(dDtAte)
		dDtAte := dDataBase
	EndIf

	dDe  := dDtDe
	dAte := dDtAte

	While MesAno(dDe) <= MesAno(dAte)	
		fBuscaTab(dDe,@cTabela,@cNvlTab,@cFaixa,@cTabCom,@cNivelCom,@cFaixaCom)  //PESQUISA A TABELA NA ALTERAÇÃO DE SALARIOS NA DATA INFORMADA 
		nVlIniTab := TabSalIni(cTabela,dDe,.T.)  //PESQUISA O VALOR DA TABELA NO INICIO DA CARREIRA
		
		If !(MesAno(dDe) == MesAno(dAte))
			nDias := (LastDay(dDe) - dDe ) + 1
		Else
			nDias := (dAte - dDe ) + 1
		EndIf
		
		nValAcum += (((nVlIniTab * (nPercent/100)) / 30 ) * nDias )
		
		dDe := LastDay(dDe) + 1
	EndDo

	RestArea( aAreaSRA )
	RestArea( aArea )
Return nValAcum

//-------------------------------------------------------------------
//FUNÇÃO PARA VALIDAR A DATA FINAL E EXECUTAR OS CALCULOS DE SUBSTITUIÇÃO
//INCLUSO NO VALID DO CAMPO RI8_DATATE
Function fVldDtFim()
	Local lRet := .T.
	Local aArea     := GetArea()
		
	fValSub(cFilAnt,FwFldGet("RI8_MAT"))
	fValSub(FwFldGet("RI8_FILSUB"),FwFldGet("RI8_MATSUB"))
	
	If (FwFldGet("RI8_DATATE") < FwFldGet("RI8_DATADE"))
		lRet := .F.
		Help(,,STR0019,,STR0022,1,0,,,,,,{STR0027})//"Atenção!" # "A data FINAL da Substituição deve ser maior ou igual a data INICIAL!" # "Altere a data final ou data inicial da substituição."
	EndIf

	RestArea( aArea )

Return lRet

