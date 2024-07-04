#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TMSAF64.CH"

Static cAtivChg := SuperGetMv("MV_ATIVCHG",,"")
Static cAtivSai := SuperGetMv("MV_ATIVSAI",,"")
Static cSvcEnt  := PadR(SuperGetMV("MV_SVCENT",,""),Len(DC5->DC5_SERVIC))	//-- Codigo do servico p/ carregamento de entrega do modulo TMS.
Static cTMSOPdg := SuperGetMV("MV_TMSOPDG",,"0")
Static cTesDR   := SuperGetMV("MV_TESDR",,"")	//-- TES pre-determinado para geracao de movimentos de vasilhames ou mercadorias a serem 
											//-- transportadas remetidos por terceiros.
Static nTipAltVia := 0	//-- 0=Não se Aplica / 1=Mercadoria não Prevista / 2=Passagem em Cliente / 3=Ponto de apoio
Static lAltRomeio := .F.
Static lTMS3GFE   := TmsIntGFE('02')
Static lTmsRdpU	  := SuperGetMV( 'MV_TMSRDPU',.F., 'N' ) <> 'N'  //F-Fechamento, S=Saida, C=Chegada, N=Não Utiliza o Romaneio unico por Lote de Redespacho

//-------------------------------------------------------------------
/* TMSAF64
Rotina da Validação do Nodelo (PosValid e VldActive) da Viagem Modelo 3 
@author  Katia
@since   17/06/2020
@param 
@version 1.0      
*/
//-------------------------------------------------------------------
Function TMSAF64(oModel,cValid)

Local lRet        := .T.
Default oModel    := FWModelActive()

If cValid == "VLD"
    lRet:= ValidMdl(oModel)
ElseIf cValid == "ACT"
    lRet:= ActivaMdl(oModel)
ElseIf cValid == "POS"
    lRet:= PosVldMdl(oModel)
	
	If lRet
		lRet	:= TF64AOpFrt(oModel)
	EndIf
	
EndIf

Return lRet

//-------------------------------------------------------------------
/* PosVldMdl
Função PosValid (Tudo Ok) do Modelo da Viagem Modelo 3
@author  Katia
@since   16/06/2020
@version 1.0      
*/
//-------------------------------------------------------------------
Static Function PosVldMdl(oModel)
Local oMdlFldDTQ	:= oModel:GetModel("MdFieldDTQ") 
Local oMdlGrdDTR	:= oModel:GetModel("MdGridDTR") 
Local nOperation	:= oMdlFldDTQ:GetOperation()
Local lRet          := .T.
Local aAreas        := {DTP->(GetArea()),SF4->(GetArea()),DVW->(GetArea()),GetArea()}
Local aFilDca       := {}
Local cSeek         := ""
Local cFilDca       := ""
Local cPerg         := "TMSAF60"
Local nCntFor1      := 0
Local nQtdVei       := 0

If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE
	Pergunte(cPerg,.F.)
	If MV_PAR01 == 2	//-- Carregamento automatico
		//-- Verifica se tem complemento da viagem
		For nCntFor1 := 1 To oMdlGrdDTR:Length()
			nQtdVei := nQtdVei + Iif(!oMdlGrdDTR:IsDeleted() .And. !Empty(oMdlGrdDTR:GetValue("DTR_CODVEI",nCntFor1)),1,0)
		Next nCntFor1
		If nQtdVei == 0
			Help("",1,"TMSA24002",,STR0002 + FwFldGet("DTQ_FILORI") + " " +  FwFldGet("DTQ_VIAGEM"),4,1)	//-- Complemento de viagem nao encontrado (DTR)###" Viagem : "
			lRet := .F.
		EndIf
		//-- Verifica se existe a TESDR
		SF4->(DbSetOrder(1))
		If !SF4->(DbSeek(xFilial("SF4") + cTesDR))
			Help("",1,"TMSA20015",,STR0002 + cTes,5,11)	//-- Tipo de entrada/saida informado no parametro MV_TESDR nao encontrado (SF4)### TES :
			lRet := .F.
		EndIf
		//-- Verifica serviço de entrega
		If !TF67SvcEnt()
			lRet := .F.
		EndIf
		//-- Qd for viagem de entrega, a filial de descarga sera a propria filial de origem pois na rota de entrega nao e informado filial de descarga. 3o parametro .T.
		aFilDca := TMSRegDca(FwFldGet("DTQ_ROTA"),,FwFldGet("DTQ_SERTMS") == StrZero(3,Len(DC5->DC5_SERTMS)))
		If !Empty(aFilDca)
			cFilDca := aFilDca[1,3]
		EndIf
		If Empty(cFilDca)
			Help("",1,"TMSAF6404",,,5,11)	//-- Filial de descarga não encontrada.
			lRet := .F.
		EndIf
	EndIf

	If lRet .And. nOperation == MODEL_OPERATION_UPDATE
	    DTY->( DbSetOrder( 2 ) )
	    If DTY->(MsSeek(xFilial('DTY') + M->DTQ_FILORI + M->DTQ_VIAGEM)) .And. DTY->DTY_FILORI == cFilAnt
	        If (M->DTQ_ROTA <> DTQ->DTQ_ROTA)
	            Help(' ', 1, 'TMSXFUNA06')	//-- Manutencoes nao sao permitidas em viagens que ja tenham contrato de carreteiro
	            lRet := .F.
	        EndIf
	    EndIf
	EndIf

	If lRet .And. Empty(M->DM5_CODOPE)
		lRet:= TF64Condut(oModel)
	EndIf

	//-- Verifica os campos da DM4
	If lRet
		If !Empty(FwFldGet("DM4_FILVGE")) .Or. !Empty(FwFldGet("DM4_NUMVGE"))
			If Empty(FwFldGet("DM4_FILVGE")) .Or. Empty(FwFldGet("DM4_NUMVGE"))
				Help("",1,"TMSAF6417")	//-- Quando o campo Filial da Viagem Original ou o campo Número da viagem Original estiverem preenchidos, os dois campos citados devem estar preenchidos.
				lRet := .F.
			EndIf
		EndIf
	EndIf

ElseIf nOperation == MODEL_OPERATION_DELETE 
    // verificar se existe despesas para este documento 
    If TMSDespCx(M->DTQ_FILORI,M->DTQ_VIAGEM)
        Help('',1,'TMSA14419') //-- "Viagem contem despesas lançadas",Favor excluir a(s) operação(ões)","no Movimento do Caixinha"
        lRet := .F.
    EndIf

	//-- Verifica se existem valores informados que não foram gerados no TMS
	If lRet
		DVW->(DbSetOrder(1))
		If DVW->(DbSeek(cSeek := xFilial("DVW") + FwFldGet("DTQ_FILORI") + FwFldGet("DTQ_VIAGEM")))
			While DVW->(!Eof()) .And. DVW->(DVW_FILIAL + DVW_FILORI + DVW_VIAGEM) == cSeek
				If !Empty(DVW->DVW_ORIGEM) .And. !AllTrim(DVW->DVW_ORIGEM) $ "TMSA240|TMSA340"
					Help("",1,"TMSAF6301")	//-- "Existem valores informados que não foram gerados pelo TMS."
					lRet := .F.
					Exit
				EndIf
				DVW->(DbSkip())
			EndDo
		EndIf
	EndIf

	//-- Verifica se existem Lotes vinculados com a viagem
	If lRet .And. !T64ChkLot(DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM) 
		Help("",1,"TMSAF6415")	//-- "Viagem não poderá ser excluida pois existem lotes vianculados a ela."
		lRet := .F. 
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet

//-------------------------------------------------------------------
/* ValidMdl
Função Valid do Modelo da Viagem 3
@author  Katia
@since   29/06/2020
@version 1.0      
Validações do TMSA144Mnt
*/
//-------------------------------------------------------------------
Static Function ValidMdl(oModel)
Local nOperation	:= oModel:GetOperation()
Local lRet          := .T.
Local cIDPdg		:= ""
Local cIDFrt		:= ""
Local cWhile		:= ""
Local lDTRAtu		:= DTR->(FieldPos("DTR_IDPDG")) > 0
Local aAreas        := {DM6->(GetArea()),DTQ->(GetArea()),DTR->(GetArea()),DT6->(GetArea()),DM4->(GetArea()),DM5->(GetArea()),GetArea()}
 
If nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_DELETE
    
    If nOperation == MODEL_OPERATION_UPDATE
		lRet:= TF64VldAlt( DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, lDTRAtu )
        		
    ElseIf nOperation == MODEL_OPERATION_DELETE 
        If DTQ->DTQ_SERTMS == StrZero(1,Len(DTQ->DTQ_SERTMS))	//-- Viagem de Coleta
            Help("",1,"TMSAF6402")	//-- Não é permitido excluir viagem de coleta utilizando a modelo 3.
            lRet:= .F.
        EndIf 

        //Valida a exclusão de uma viagem caso haja outra viagem coligada a ela. 
		If lRet
	        dbSelectArea("DTR")
	        DTR->(DbSetOrder(2))
	        If	DTR->(MsSeek(xFilial('DTR') + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM))
	            Help('',1,'TMSA14422',, STR0001 +  DTR->DTR_FILORI + STR0002 + DTR->DTR_VIAGEM,4,1)  
	            lRet:= .F.
	        EndIf
		EndIf

        If lRet
            //-- Valida se a viagem de coleta esta em transito. As outras validacoes sera executa na TMSChkViag().
            If DTQ->DTQ_STATUS != StrZero(1,Len(DTQ->DTQ_STATUS)) //-- 1=Em Aberto;5=Fechada;2=Em Transito;4=Chegada em Filial / Cliente;3=Encerrada;9=Cancelada
                Help(' ', 1, 'TMSXFUNA03') //-- Viagem nao esta em Aberto
                lRet:= .F.
            EndIf
        EndIf

        //-- Somente permite manutencoes em viagens em aberto, em transito ou chegada parcial
        If lRet .And. !TMSChkViag(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,,.F.,.T.,,,,,,,,.F.,.T.,,.T.)
            lRet:= .F.
        EndIf
 
        //-- Verifica se o carregamento já foi iniciado
        If lRet
			DM6->(DbSetOrder(1))
			If DM6->(DbSeek(xFilial("DM6") + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM))
				Help("",1,"TMSAF6406")	//-- "Não é permitida exclusão pois a viagem já possui carregamento iniciado."
				lRet := .F.
			EndIf
		EndIf

		If lRet .AND. lDTRAtu
			DTR->( DbSetOrder(1) )//DTR_FILIAL, DTR_FILORI, DTR_VIAGEM, DTR_ITEM, R_E_C_N_O_, D_E_L_E_T_( !Empty( DTR->DTR_IDOPE ) .OR. !Empty( DTR->DTR_IDPDG ) )
	        If DTR->( MsSeek( xFilial('DTR') + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM ) ) .AND. DTR->DTR_CODOPE == "03"

				cWhile	:= xFilial('DTR')+ DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM
				
				While !DTR->(EOF()) .AND. xFilial('DTR') + DTR->( DTR_FILORI + DTR_VIAGEM ) == cWhile .AND. lRet

					If !Empty( DTR->DTR_PRCTRA ) .OR. !Empty( DTR->DTR_IDPDG )
						cIDPdg += If( !Empty( cIDPdg ), "," + AllTrim(DTR->DTR_IDPDG), AllTrim(DTR->DTR_IDPDG) )
						cIDFrt += If( !Empty( cIDFrt ), "," + AllTrim(DTR->DTR_PRCTRA), AllTrim(DTR->DTR_PRCTRA) )
					EndIf

					DTR->( DbSkip() )
				EndDo
			EndIf
			DM5->( DbSetOrder( 1 ) )
			If DM5->( DbSeek( xFilial("DM5") + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM ) ) .AND. DM5->DM5_CODOPE == "03" .AND. ( !Empty( cIDPdg ) .OR. !Empty( cIDFrt ) )
				lRet := .F.
				// STR0024 "Integração TMS Protheus X PagBem"
				// STR0025 "Ocorreu um erro no processo de Cancelamento dos Contratos de Frete e Pedagio no Sistema PagBem."
				// STR0026 "Realize o cancelamento dos contratos pelo Portal do Sistema PagBem. "
				// STR0027 "Contrato de Frete: "
				// STR0028 " Contrato de Pedagio: "
				Help( "", 1, STR0024, , STR0025, 1, 0, , , , , ,{ STR0026 + If( !Empty(cIDFrt), STR0027 + cIDFrt + ".", "" ) + If( !Empty(cIDPdg), STR0028 + cIDPdg + ".", "" ) } ) // "Ocorreu um erro no processo de Cancelamento dos Contratos de Frete e Pedagio no Sistema PagBem." "Atualize o ambiente para que os novos campos da tabela Operadoras de Frota (DEG) sejam criados."
			EndIf
		EndIf
    EndIf
EndIf


AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
Return lRet

//------------------------------------------------------
/* TF64ChkDM4
Função que verifica dados na tabela DM4- Planejamento
@author  Katia
@since   04/08/2020
@version 1.0      
*/
//-------------------------------------------------------
Function TF64ChkDM4(cFilOri,cViagem)
Local lRet      := .F.
Local aAreas    := {GetArea()}
Local cQuery    := ""
Local cAliasQry := GetNextAlias()

cQuery := "SELECT COUNT(*) NREG"
cQuery += " FROM " + RetSqlName("DM4") + " DM4"
cQuery += " WHERE DM4.DM4_FILIAL = '" + xFilial("DM4") + "'"
cQuery += " AND DM4.DM4_FILORI = '" + cFilOri + "'"
cQuery += " AND DM4.DM4_VIAGEM = '" + cViagem + "'"
cQuery += " AND DM4.D_E_L_E_T_ = ''"
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
If (cAliasQry)->(!Eof())  .And. (cAliasQry)->NREG > 0
    lRet:= .T.
EndIf
(cAliasQry)->(DbCloseArea())

If !lRet
    //Esta viagem nao é compativel com a nova estrutura da viagem modelo 3.
    Help(' ', 1, 'TMSAF6403')
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet

/*{Protheus.doc} TF67SvcEnt
Valida o servico informado no parametro MV_SVCENT, apenas p/viagens de entrega.
@type Static Function
@author Valdemar Roberto Mognon
@since 10/08/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function TF67SvcEnt()
Local aAreas     := {DC5->(GetArea()),DC6->(GetArea()),GetArea()}
Local cSeekDC5   := ""
Local cSeekDC6   := ""
Local lRet       := .T.

//-- Valida o servico informado no parametro MV_SVCENT, somente para viagens de entrega ou reprocesso.
DC5->(DbSetOrder(1))
If !DC5->(DbSeek(cSeekDC5 := xFilial("DC5") + cSvcEnt))
	Help("",1,"TMSA21016")	//-- "Parametro de servico de entrega ou reprocesso invalido ..."
	lRet := .F.
Else
	While DC5->(!Eof() .And. DC5->(DC5_FILIAL + DC5_SERVIC) == cSeekDC5)
		DC6->(DbSetOrder(1))
		If DC6->(DbSeek(cSeekDC6 := xFilial("DC6") + DC5->DC5_TAREFA))
			While DC6->(!Eof() .And. DC6->(DC6_FILIAL + DC6_TAREFA) == cSeekDC6)
				If DC6->DC6_ATIVID == cAtivChg .Or. DC6->DC6_ATIVID == cAtivSai
					Help("",1,"TMSA21015")	//-- "O Servico especificado no parametro MV_SVCENT esta incorreto ..."
					lRet := .F.
				EndIf
				DC6->(DbSkip())
			EndDo
		EndIf
		DC5->(DbSkip())
	EndDo
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet

/*{Protheus.doc} TF64Folder
Valida acesso as Folders
@type Function
@author Katia
@since 17/08/2020
@version version
@param param, param_type, param_descr
@return lRet
*/
Function TF64Folder(cID,nOldSheet,nSelSheet)
Local lRet:= .T.

If cID == 'Folder2' .And. nSelSheet == 6 //DLD- Forma de Pagamento
	If M->DM5_CODOPE <> '02'
		Help('',1,'TMSA24093') //"Opção disponível para operadora Pamcard "
		lRet:= .F.
	EndIf
ElseIf cID == "Folder1" .And. nSelSheet == 3	//-- DMB - Automatização da viagem 
	If Empty(FwFldGet("DTQ_CODAUT"))
		Help("",1,"TMSAF6416")	//-- "Opção disponível somente com o código de automatização da viagem preenchido."
		lRet:= .F.
	EndIf
EndIf

Return lRet

/*{Protheus.doc} TF64VldAlt
Valida a Alteração da Viagem
@type Function
@author Katia
@since 17/08/2020
@version version
@param param, param_type, param_descr
@return lRet
@Uso TMSAF64 / TMSAF64E
*/
Function TF64VldAlt(cFilOri,cViagem, lDTRAtu)
Local lManViag      := GetNewPar("MV_MANVIAG",.F.) //-- Permite configurar se e possível manifestar uma viagem que ainda nao esta disponivel na filial corrente                       
Local cStatus       := ""
Local lAberto       := .T.
Local lChgViag      := .F. 
Local lRet          := .T.
Local cIDPdg		:= ""
Local cIDFrt		:= ""
Local cWhile		:= ""
Local aAreas        := {DM5->(GetArea()),DM6->(GetArea()),DTQ->(GetArea()),GetArea()}
Local lTransito		:= .F.
Local lVgeAntiga	:= IsInCallStack("TMSA140") .OR. IsInCallStack("TMSA141") .OR. isInCallStack("TMSA143");
						.OR. isInCallStack("TMSA144") .OR. isInCallStack("TMSA210")

Default cFilOri     := ""
Default cViagem     := ""
Default lDTRAtu		:= DTR->(FieldPos("DTR_IDPDG")) > 0

DTQ->(DbSetOrder(2))
lRet:= DTQ->(MsSeek(xFilial('DTQ')+ cFilOri + cViagem))

If lRet	
	//-- Determina se o processo de alteração é de retirada de mercadoria não prevista
	TF64AltVia()	//-- Variavel para o controle da lPrcMerNpr  da viagem antiga

	lTransito	:= DTQ->DTQ_STATUS == StrZero(2,Len(DTQ->DTQ_STATUS))
	If !TMFGetStat("lIncMot")  //Inclusao de Condutor permite a inclusao
	   lRet := TMSChkViag( DTQ->DTQ_FILORI , DTQ->DTQ_VIAGEM, .T., .F., .T., .T., , , lTransito, , , , .T. )  //-- Manutencoes serao permitidas somente em viagens em aberto ou chegada em filial
	EndIf

	If lRet .And. DTQ->DTQ_SERTMS == StrZero(1,Len(DTQ->DTQ_SERTMS))	//-- Viagem de Coleta
        Help("",1,"TMSAF6401")	//-- Não é permitido alterar viagem de coleta utilizando a modelo 3.
        lRet:= .F.
    EndIf 

	If lTMS3GFE .Or. lTmsRdpU
		TF64AltRom()	
	EndIf

	If lRet
		//Nao permite alteração da viagem de transporte caso nao esteja em aberto
		If DTQ->DTQ_STATUS != StrZero(1,Len(DTQ->DTQ_STATUS)) .And.;
			DTQ->DTQ_STATUS != StrZero(4,Len(DTQ->DTQ_STATUS)) .And.;
			DTQ->DTQ_SERTMS == StrZero(2,Len(DTQ->DTQ_SERTMS)) 			
			lRet:= .F.
		ElseIf  DTQ->DTQ_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS)) .And. DTQ->DTQ_STATUS == StrZero(5,Len(DTQ->DTQ_STATUS)) .AND. !lVgeAntiga//-- Viagem de Entrega fechada   
			lRet:= .F.
		EndIf

		If !lRet
			Help(' ', 1, 'TMSXFUNA03') //-- Viagem nao esta em Aberto					
		EndIf
	EndIf

    //-- Se o parametro MV_MANVIAG (Permite configurar se e possivel manifestar uma viagem que ainda nao esta disponivel na filial corrente)
    //-- estiver habilitado, permitir manutencoes na viagem com Status 'Em Transito'
    If lRet
        cStatus := StrZero(2,Len(DTQ->DTQ_STATUS)) + ";" + StrZero(4,Len(DTQ->DTQ_STATUS))
        If lManViag .And. DTQ->DTQ_STATUS $ cStatus
            lAberto := .F.
            DTW->(DbSetOrder(4))
            If DTW->(MsSeek(cSeek := xFilial("DTW") + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM + cAtivSai + cFilAnt))
                Do While !DTW->(Eof()) .And. DTW->(DTW_FILIAL+DTW_FILORI+DTW_VIAGEM+DTW_ATIVID+DTW_FILATI) == cSeek
                    //-- Se for operacao de 'Saida' e o Status da Operacao de Saida da Viagem estiver  'Encerrado'
                    If	DTW->DTW_CATOPE == StrZero(1,Len(DTW->DTW_CATOPE)) .And. ;
                        DTW->DTW_STATUS == StrZero(2,Len(DTW->DTW_STATUS))
                        lAberto := .T. //-- Nao permite alterar a Viagem
                        Exit
                    EndIf
                    DTW->(dbSkip())
                EndDo
            EndIf
        EndIf

        //-- Permite manutencoes em viagens com chegada parcial.
        If DTQ->DTQ_SERTMS == StrZero(2,Len(DC5->DC5_SERTMS)) //-- Transporte
            lChgViag := .T.
        EndIf
        If !TMSChkViag(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,lAberto,.F.,.F.,.T.,.F.,.F.,.F.,,,,lChgViag)
            lRet:= .F.
        EndIf
    EndIf
    
	If lRet .AND. lDTRAtu
		DTR->( DbSetOrder(1) )//DTR_FILIAL, DTR_FILORI, DTR_VIAGEM, DTR_ITEM, R_E_C_N_O_, D_E_L_E_T_( !Empty( DTR->DTR_IDOPE ) .OR. !Empty( DTR->DTR_IDPDG ) )
		If DTR->( MsSeek( xFilial('DTR') + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM ) ) .AND. DTR->DTR_CODOPE == "03"

			cWhile	:= xFilial('DTR') + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM
			
			While !DTR->(EOF()) .AND. xFilial('DTR') + DTR->( DTR_FILORI + DTR_VIAGEM ) == cWhile .AND. lRet

				If !Empty( DTR->DTR_PRCTRA ) .OR. !Empty( DTR->DTR_IDPDG )
					cIDPdg += If( !Empty( cIDPdg ), "," + AllTrim(DTR->DTR_IDPDG), AllTrim(DTR->DTR_IDPDG) )
					cIDFrt += If( !Empty( cIDFrt ), "," + AllTrim(DTR->DTR_PRCTRA), AllTrim(DTR->DTR_PRCTRA) )
				EndIf

				DTR->( DbSkip() )
			EndDo
		EndIf
		DM5->( DbSetOrder( 1 ) )
		If DM5->( DbSeek( xFilial("DM5") + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM ) ) .AND. DM5->DM5_CODOPE == "03" .AND. ( !Empty( cIDPdg ) .OR. !Empty( cIDFrt ) )
            lRet := .F.
			// STR0024 "Integração TMS Protheus X PagBem"
			// STR0025 "Ocorreu um erro no processo de Cancelamento dos Contratos de Frete e Pedagio no Sistema PagBem."
			// STR0026 "Realize o cancelamento dos contratos pelo Portal do Sistema PagBem. "
			// STR0027 "Contrato de Frete: "
			// STR0028 " Contrato de Pedagio: "
			Help( "", 1, STR0024, , STR0025, 1, 0, , , , , ,{ STR0026 + If( !Empty(cIDFrt), STR0027 + cIDFrt + ".", "" ) + If( !Empty(cIDPdg), STR0028 + cIDPdg + ".", "" ) } ) // "Ocorreu um erro no processo de Cancelamento dos Contratos de Frete e Pedagio no Sistema PagBem." "Atualize o ambiente para que os novos campos da tabela Operadoras de Frota (DEG) sejam criados."
        EndIf
	EndIf
    //-- Verifica se o carregamento já foi iniciado
//	If lRet
//		DM6->(DbSetOrder(1))
//		If DM6->(DbSeek(xFilial("DM6") + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM))
//			Help("",1,"TMSAF6405")	//-- "Não é permitida edição pois a viagem já possui carregamento."
//			lRet := .F.
//		EndIf
//	EndIf
EndIf

If !lRet
	TF64SetSt("nTipAltVia",0)
	TF64SetSt("lAltRomeio",.F.)
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
Return lRet

/*{Protheus.doc} TF64AltVia
Determina qual o processo de alteração da viagem 1=Mercadoria não Prevista / 2=Passagem em Cliente / 3= Ponto de Apoio
@type Function
@author Katia
@since 15/09/2020
@version 12.1.30
@param 
@return lRet
Função para tratar a variavel private lPrcMerNpr da viagem modelo antiga
*/
Function TF64AltVia()	
Local aAreas     := {DA8->(GetArea()),DC5->(GetArea()),DC6->(GetArea()),GetArea()}
Local cAtvChgApo := SuperGetMv("MV_ATVCHPA",,"")	//-- Atividade de Chegada no Ponto de Apoio
Local cAtvSaiApo := SuperGetMv("MV_ATVSAPA",,"")	//-- Atividade de Saida do Ponto de Apoio
Local cAtvChgCli := SuperGetMv("MV_ATVCHGC",,"")	//-- Atividade de Chegada em Cliente
Local cAtvSaiCli := SuperGetMv("MV_ATVSAIC",,"")	//-- Atividade de Saída do cliente
Local cSeekDC5   := ""
Local cSeekDC6   := ""

nTipAltVia := 0	//-- Inicializa Variável

If !Empty(DTQ->DTQ_ROTA)
	DA8->(dbSetOrder(1))
	DC5->(dbSetOrder(1))
	DC6->(dbSetOrder(1))
	If DA8->(MsSeek(xFilial("DA8") + DTQ->DTQ_ROTA))
        If DC5->(MsSeek(cSeekDC5 := xFilial("DC5") + DA8->DA8_SERVIC))
            While DC5->(!Eof()) .And. DC5->(DC5_FILIAL + DC5_SERVIC) == cSeekDC5
    	        DC6->(MsSeek(cSeekDC6 := xFilial("DC6") + DC5->DC5_TAREFA))
                While DC6->(!Eof()) .And. DC6->(DC6_FILIAL + DC6_TAREFA) == cSeekDC6
                    If DC6->DC6_ATIVID == cAtvChgApo .Or. DC6->DC6_ATIVID == cAtvSaiApo
                        nTipAltVia := 3	//-- Ponto de Apoio
                        Exit
                    EndIf
                    If DC6->DC6_ATIVID == cAtvChgCli .Or. DC6->DC6_ATIVID == cAtvSaiCli
                        nTipAltVia := 2	//-- Passagem em Cliente
                        Exit
                    EndIf
                    DC6->(DbSkip())
                EndDo
                If nTipAltVia == 3
                    Exit
                EndIf
                DC5->(DbSkip())
            EndDo
        EndIf
    EndIf
EndIf
If nTipAltVia == 0
	If DTQ->DTQ_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS)) .And.; //-- Viagem de Entrega
	   DTQ->DTQ_STATUS == StrZero(2,Len(DTQ->DTQ_STATUS)) .And.; //-- Em Trânsito
	   !F11RotRote(DTQ->DTQ_ROTA)
	   nTipAltVia := 1	//-- Mercadoria não Prevista
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return 

/*{Protheus.doc} TF64GetSt
Retorna conteudo variáveis estaticas
@type Function
@author Katia
@since 15/09/2020
@version 12.1.30
*/
Function TF64GetSt(cVar)	

Return &(cVar)

/*{Protheus.doc} TF64SetSt
Seta variáveis estaticas
@type Function
@author Katia
@since 15/09/2020
@version 12.1.30
*/
Function TF64SetSt(cVar,xCont)

&(cVar) := xCont

Return

/*{Protheus.doc} TF64AltRom
Determina se a altera a viagem com o Romaneio
@type Function
@author Katia
@since 15/09/2020
@version 12.1.30
@param 
@return lRet
Função para tratar a variavel private lAltRomeio da viagem modelo antiga
*/
Function TF64AltRom()	
Local cChvExt:= ""
Local lRet   := .T.

//-- Integracao Viagem TMS x GFE
If lTMS3GFE .Or. lTmsRdpU  
	If DTQ->DTQ_STATUS $ "2|4|5"   //2=Em Transito;4=Chegada em Filial;5=Fechada
		//---- Verifica se existe algum Romaneio em Aberto (o Pergunte foi removido na viagem 3)
		lRet:= TmsGFEDUD(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,,,,.T.,@cChvExt)
		If !Empty(DTQ->DTQ_CHVEXT) .And. DTQ->DTQ_CHVEXT <> cChvExt
			lAltRomeio:= .T.
		EndIf 
	EndIf
EndIf

Return lRet

/*{Protheus.doc} ActivaMdl
Valida Início da Viagem
@type Static Function
@author Valdemar Roberto Mognon
@since 07/10/2020
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
(examples)
@see (links_or_references)
*/
Static Function ActivaMdl(oModel)

Local oMdlGrdDM3 := oModel:GetModel("MdGridDM3")
Local oMdlGrdDTR := oModel:GetModel("MdGridDTR")
Local oMdlGrdDUP := oModel:GetModel("MdGridDUP")
Local oMdlGrdDUQ := oModel:GetModel("MdGridDUQ")
Local oMdlGrdDVB := oModel:GetModel("MdGridDVB")
Local oMdlGrdSDG := oModel:GetModel("MdGridSDG")
Local oMdlGrdDVW := oModel:GetModel("MdGridDVW")
Local oMdlGrdDJA := oModel:GetModel("MdGridDJA")
Local oMdlGrdDMB := oModel:GetModel("MdGridDMB")
Local nCntFor1   := 0
Local nOperation := oModel:GetOperation()
Local aVetWrk    := {}
Local aAreas     := {DTA->(GetArea()),DM6->(GetArea()),GetArea()}

Local lNoAltDM6  := .F.

	For nCntFor1 := 1 To oMdlGrdDTR:Length()
		If !oMdlGrdDTR:IsDeleted()
			Aadd(aVetWrk,FwFldGet("DTR_CODVEI"))
		EndIf
	Next nCntFor1
	TMFSetStat("aVeiVia",Aclone(aVetWrk))

	aVetWrk := {}		
	For nCntFor1 := 1 To oMdlGrdDUP:Length()
		If !oMdlGrdDUP:IsDeleted()
			Aadd(aVetWrk,FwFldGet("DUP_CODMOT"))
		EndIf
	Next nCntFor1
	TMFSetStat("aMotVia",Aclone(aVetWrk))

	If nOperation != MODEL_OPERATION_INSERT
		DTA->(DbSetOrder(1))
		For nCntFor1 := 1 To oMdlGrdDM3:Length()
			oMdlGrdDM3:GoLine(nCntFor1)
			If DTA->(DbSeek(xFilial("DTA") + FwFldGet("DM3_FILDOC") + FwFldGet("DM3_DOC") + FwFldGet("DM3_SERIE") + ;
											FwFldGet("DTQ_FILORI") + FwFldGet("DTQ_VIAGEM")))
				oMdlGrdDM3:LoadValue("DM3_ORIGEM",DTA->DTA_ORIGEM)
			EndIf
		Next nCntFor1
	EndIf

	If nOperation == MODEL_OPERATION_UPDATE .And. AliasInDic("DMB") .And. DTQ->DTQ_STATUS != StrZero(1,Len(DTQ->DTQ_STATUS))
		oMdlGrdDMB:SetNoUpdateLine(.T.)
	Else
		oMdlGrdDMB:SetNoUpdateLine(.F.)
	EndIf

	DM6->(DbSetOrder(1))
	lNoAltDM6 := nOperation == MODEL_OPERATION_UPDATE .And. DM6->(DbSeek(xFilial("DM6") + FwFldGet("DTQ_FILORI") + FwFldGet("DTQ_VIAGEM")))

	oMdlGrdDTR:SetNoInsertLine(lNoAltDM6)
	oMdlGrdDTR:SetNoDeleteLine(lNoAltDM6)
	oMdlGrdDTR:SetNoUpdateLine(lNoAltDM6)

	If !TMFGetStat("lIncMot")  //Inclusao de Condutor permite a inclusao
		oMdlGrdDUP:SetNoInsertLine(lNoAltDM6)
		oMdlGrdDUP:SetNoDeleteLine(lNoAltDM6)
		oMdlGrdDUP:SetNoUpdateLine(lNoAltDM6)
	EndIf

	oMdlGrdDUQ:SetNoInsertLine(lNoAltDM6)
	oMdlGrdDUQ:SetNoDeleteLine(lNoAltDM6)
	oMdlGrdDUQ:SetNoUpdateLine(lNoAltDM6)

	oMdlGrdDVB:SetNoInsertLine(lNoAltDM6)
	oMdlGrdDVB:SetNoDeleteLine(lNoAltDM6)
	oMdlGrdDVB:SetNoUpdateLine(lNoAltDM6)

	oMdlGrdSDG:SetNoInsertLine(lNoAltDM6)
	oMdlGrdSDG:SetNoDeleteLine(lNoAltDM6)
	oMdlGrdSDG:SetNoUpdateLine(lNoAltDM6)

	oMdlGrdDVW:SetNoInsertLine(lNoAltDM6)
	oMdlGrdDVW:SetNoDeleteLine(lNoAltDM6)
	oMdlGrdDVW:SetNoUpdateLine(lNoAltDM6)

	oMdlGrdDJA:SetNoInsertLine(lNoAltDM6)
	oMdlGrdDJA:SetNoDeleteLine(lNoAltDM6)
	oMdlGrdDJA:SetNoUpdateLine(lNoAltDM6)

	If cTMSOPdg <> "0"
		MdGridDLD := oModel:GetModel("MdGridDLD")
		MdGridDLD:SetNoInsertLine(lNoAltDM6)
		MdGridDLD:SetNoDeleteLine(lNoAltDM6)
		MdGridDLD:SetNoUpdateLine(lNoAltDM6)
	EndIf
			
	AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return .T.

/*{Protheus.doc} TF64Condut
Valida o Condutor Principal da Viagem
@type Function
@author Katia
@since 14/12/2020
*/
Function TF64Condut(oModel)
Local nCount     := 0
Local lRet       := .T.
Local nCondP     := 0
Local oMdGridDUP := Nil
Local aSaveLine	 

Default oModel   := FWModelActive()

oMdGridDUP := oModel:GetModel('MdGridDUP')
aSaveLine  := FWSaveRows()

For nCount:= 1 To oMdGridDUP:Length()
	oMdGridDUP:GoLine(nCount)
	If !oMdGridDUP:IsEmpty() .And. !oMdGridDUP:IsDeleted()
											
		If oMdGridDUP:GetValue('DUP_CONDUT') == "1" .AND. !Empty( FwFldGet("DUP_CODMOT") ) //Condutor principal
			nCondP += 1
		EndIf
	EndIf
Next nCount

If nCondP > 1
	Help('',1,'TMSA24056') //-- Permitido apenas um Condutor Principal por Viagem
	lRet:= .F.
EndIf

FWRestRows( aSaveLine )
Return lRet

/*{Protheus.doc} T64ChkLot
Query para verificar se Existem Doctos Vinculados a viagem que nao estejam deletados
@type Function
@author Rafael
@since 26/07/2022
*/
Static Function T64ChkLot(cFilOri, cViagem)

Local lRet 			:= .T. 
Local cQuery 		:= ""
Local cAliasLot   	:= GetNextAlias()

Default cFilOri := ""
Default cViagem := ""

cQuery := " SELECT DTP_FILORI,DTP_LOTNFC, COUNT(DUD_DOC) TOTREG "
cQuery += " FROM " + RetSqlName("DTP")+" DTP " 		
cQuery += " LEFT JOIN "+RetSqlName("DUD")+" DUD ON " 
cQuery += " (DUD.DUD_FILIAL = '"+xFilial("DUD")+"' AND DUD.DUD_FILORI = DTP.DTP_FILORI AND DUD.DUD_VIAGEM = DTP.DTP_VIAGEM AND DUD.D_E_L_E_T_ = '') "		
cQuery += " WHERE DTP.DTP_FILIAL   = '" + xFilial("DTP") + "' "
cQuery += " AND DTP.DTP_FILORI = '" + cFilOri  + "' "
cQuery += " AND DTP.DTP_VIAGEM = '" + cViagem  + "' "		
cQuery += " AND DTP.D_E_L_E_T_ = ' ' "				
cQuery += " GROUP BY DTP_FILORI,DTP_LOTNFC "
cQuery := ChangeQuery( cQuery )	

dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasLot, .F., .T. )		

//--Se encontrar registros não permite desvincular o lote da viagem.
If (cAliasLot)->(!Eof()) .And. (cAliasLot)->TOTREG >= 1		
	lRet := .F. 			
EndIf

(cAliasLot)->(DbCloseArea())

Return lRet 
