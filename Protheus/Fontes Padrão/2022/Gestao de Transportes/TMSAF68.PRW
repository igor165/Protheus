#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSAF68.CH"
#INCLUDE "FWMVCDEF.CH"

Static lTMSExp    := SuperGetMv("MV_TMSEXP",.F.,.F.)	//-- Indica TMSExpress ativo
Static cTipDocMot := SuperGetMv("MV_DMOTEST",.F.," ")	//-- Tipos de documentos que pede motivo
Static cTMSOpDg   := SuperGetMv("MV_TMSOPDG", .F., .F.)	//-- Indica se a integração com Operadoras de Frota está ativa.
Static cAtvChgCli := SuperGetMv("MV_ATVCHGC",,"")		//-- Atividade de Chegada em Cliente
Static lTmf68Mnu  := ExistBlock("TMF68MNU")				//-- Verifica se existe ponto de entrada para inclusão de itens no menu da viagem modelo 3
Static lIntTPR    := SuperGetMV("MV_ROTAINT",,.F.)      //-- Integração Planejamento de Rotas (TPR)

/*{Protheus.doc} TMSAF68
Adiciona itens no menu da viagem modelo 3
@type Function
@author Valdemar Roberto Mognon
@since 12/08/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function TMSAF68(aRotina)
Local aEncerrame := {}
Local aFechament := {}
Local aComprovan := {}
Local aManifesto := {}
Local aCarregame := {}
Local aImpressao := {}
Local aManutenca := {}
Local aImpManife := {}
Local aRentabili := {}
Local aRotUsu    := {}
Local aIntMnu    := {}
Local nCntFor1   := 0
Local aRepom	 := {} 
Local aContrato	 := {} 
Local lRepom	 := AllTrim( SuperGetMV( 'MV_VSREPOM',, '1' ) ) == '2.2'
Local aFreteBr	 := {}
Local lTMSIntChk := TableIndic("DM0") .AND. SuperGetMV( "MV_TMAPCKL", , .F. ) .AND. ExistFunc( "TMSIntChk" ) .AND. ExistFunc( "TMSButCh" )
Local aRotTPR    := {}
Local lColent    := AliasInDic( "DN1" ) .And. ExistFunc( "TMSAC30" )

If lIntTPR 
	lIntTPR:= FindFunction('TMSROTEIRI') .And. AliasInDic("DMR")
EndIf

//-- Monta menu do carregamento da viagem
ADD OPTION aCarregame TITLE STR0014 ACTION "TMSAF68Sub( 1, 1)" OPERATION  2 ACCESS 0	//-- "Visualizar"
ADD OPTION aCarregame TITLE STR0015 ACTION "TMSAF68Sub( 1, 2)" OPERATION  2 ACCESS 0	//-- "Carregar"
ADD OPTION aCarregame TITLE STR0002 ACTION "TMSAF68Sub( 1, 3)" OPERATION  2 ACCESS 0	//-- "&Estornar"

//-- Monta menu dos manifestos da viagem
ADD OPTION aManifesto TITLE STR0006 ACTION "TMSAF68Sub( 2, 1)" OPERATION  2 ACCESS 0	//-- "Visual/Excluir"
ADD OPTION aManifesto TITLE STR0007 ACTION "TMSAF68Sub( 2, 2)" OPERATION  2 ACCESS 0	//-- "Manifestar"
ADD OPTION aManifesto TITLE STR0008 ACTION "TMSAF68Sub( 2, 3)" OPERATION  2 ACCESS 0	//-- "MDF-e"
ADD OPTION aManifesto TITLE STR0009 ACTION "TMSAF68Sub( 2, 4)" OPERATION  2 ACCESS 0	//-- "Tracking eventos MDFe"
If ExistFunc("TMSA73BX1") .And. TMSA73BX1()
	ADD OPTION aManifesto TITLE STR0010 ACTION "TMSAF68Sub( 2, 5)" OPERATION  2 ACCESS 0	//-- "Consulta"
EndIf
ADD OPTION aManifesto TITLE STR0011 ACTION "TMSAF68Sub( 2, 6)" OPERATION  2 ACCESS 0	//-- "Histórico MDF-e"
ADD OPTION aManifesto TITLE STR0012 ACTION "TMSAF68Sub( 2, 7)" OPERATION  2 ACCESS 0	//-- "Vis. Percurso"
ADD OPTION aManifesto TITLE STR0013 ACTION "TMSAF68Sub( 2, 8)" OPERATION  2 ACCESS 0	//-- "Editar Percurso"
ADD OPTION aManifesto TITLE STR0019 ACTION "TMSAF68Sub( 2, 9)" OPERATION  2 ACCESS 0	//-- "Inclusão Condutor"

//-- Monta menu do fechamento da viagem
ADD OPTION aFechament TITLE STR0003 ACTION "TMSAF68Sub( 3, 1)" OPERATION  2 ACCESS 0	//-- "Fechar"
ADD OPTION aFechament TITLE STR0002 ACTION "TMSAF68Sub( 3, 2)" OPERATION  2 ACCESS 0	//-- "&Estornar"

//-- Monta menu do encerramento da viagem
ADD OPTION aEncerrame TITLE STR0001 ACTION "TMSAF68Sub( 4, 1)" OPERATION  2 ACCESS 0	//-- "Encerrar"
ADD OPTION aEncerrame TITLE STR0002 ACTION "TMSAF68Sub( 4, 2)" OPERATION  2 ACCESS 0	//-- "&Estornar"

//-- Monta menu do comprovante de entrega eletrônico
ADD OPTION aComprovan TITLE STR0004 ACTION "TMSAF68Sub( 5, 1)" OPERATION  2 ACCESS 0	//-- "Monitora"
ADD OPTION aComprovan TITLE STR0005 ACTION "TMSAF68Sub( 5, 2)" OPERATION  2 ACCESS 0	//-- "Altera"

//-- Monta menu da rentabilidade prévia da viagem
ADD OPTION aRentabili TITLE STR0037 ACTION "TMSAF68Sub( 6, 1)" OPERATION  2 ACCESS 0	//-- "Simular Rentabilidade"
ADD OPTION aRentabili TITLE STR0038 ACTION "TMSAF68Sub( 6, 2)" OPERATION  2 ACCESS 0	//-- "Excluir Rentabilidade"

//-- Monta menu de manutenção da viagem
ADD OPTION aManutenca TITLE STR0016 ACTION "TMSAF68Sub( 8, 1)" OPERATION  2 ACCESS 0	//-- "Confirmação"
ADD OPTION aManutenca TITLE STR0017 ACTION Aclone(aCarregame)  OPERATION  2 ACCESS 0	//-- "Carregamento"
ADD OPTION aManutenca TITLE STR0018 ACTION Aclone(aManifesto)  OPERATION  2 ACCESS 0	//-- "Manifesto"
ADD OPTION aManutenca TITLE STR0020 ACTION "TMSAF68Sub( 8, 2)" OPERATION  2 ACCESS 0	//-- "Geração AWB"
ADD OPTION aManutenca TITLE STR0021 ACTION "TMSAF68Sub( 8, 3)" OPERATION  2 ACCESS 0	//-- "Operações"
ADD OPTION aManutenca TITLE STR0022 ACTION Aclone(aFechament)  OPERATION  2 ACCESS 0	//-- "Fechamento"
ADD OPTION aManutenca TITLE STR0023 ACTION "TMSAF68Sub( 8, 4)" OPERATION  2 ACCESS 0	//-- "Reg.Ocorrência"
ADD OPTION aManutenca TITLE STR0024 ACTION Aclone(aEncerrame)  OPERATION  2 ACCESS 0	//-- "Encerramento"
ADD OPTION aManutenca TITLE STR0025 ACTION Aclone(aComprovan)  OPERATION  2 ACCESS 0	//-- "Compr Entrega"
ADD OPTION aManutenca TITLE STR0026 ACTION "TMSAF68Sub( 8, 5)" OPERATION  2 ACCESS 0	//-- "Movto.Caixinha"
If lTMSExp
	ADD OPTION aManutenca TITLE STR0027 ACTION "TMSAF68Sub( 8, 6)" OPERATION  2 ACCESS 0	//-- "Estorno Express"
EndIf
ADD OPTION aManutenca TITLE STR0028 ACTION "TMSAF68Sub( 8, 7)" OPERATION  2 ACCESS 0	//-- "Retorno de Unitizadores"
ADD OPTION aManutenca TITLE STR0029 ACTION "TMSAF68Sub( 8, 8)" OPERATION  2 ACCESS 0	//-- "Fornecedores Adicionais"
If ExistFunc("TMA500AX1") .And. TMA500AX1() 
	ADD OPTION aManutenca TITLE STR0086 ACTION "TMSAF68Sub( 8, 9)" OPERATION  2 ACCESS 0	//-- "Manutenção de Transportes"
EndIf 
If cTMSOpDg $ "1:2"	//-- Vale Pedágio e Frota
	ADD OPTION aManutenca TITLE STR0036 ACTION "TMSAF68Sub( 8, 9)" OPERATION  2 ACCESS 0	//-- "Troca de Cartão"
EndIf

//-- Analisa a possibilidade de integração com Coleta/Entrega
If lTMSIntChk
	ADD OPTION aIntMnu TITLE STR0080 ACTION "TMSButCh()" OPERATION  2 ACCESS 0	//-- "Reenvia Checklist"
EndIf
If ExistFunc( "TMSAC26" ) .And. ( lColent .Or. lTMSIntChk )
	ADD OPTION aIntMnu TITLE STR0088 ACTION "TMSAC26()"	OPERATION  9 ACCESS 0	//-- "Open Street Map"
EndIf

//-- Inclui sub-menu de manutenção da viagem na rotina principal		
If lTMSExp
	ADD OPTION aImpManife TITLE STR0018 ACTION "TMSAF68Sub( 9, 1)" OPERATION  2 ACCESS 0	//-- "Manifesto"
	ADD OPTION aImpManife TITLE STR0030 ACTION "TMSAF68Sub( 9, 2)" OPERATION  2 ACCESS 0	//-- "DAMDFE"

	ADD OPTION aImpressao TITLE STR0031 ACTION "TMSAF68Sub(10, 1)" OPERATION  2 ACCESS 0	//-- "Contrato"
	ADD OPTION aImpressao TITLE STR0032 ACTION "TMSAF68Sub(10, 2)" OPERATION  2 ACCESS 0	//-- "Cheque"
	ADD OPTION aImpressao TITLE STR0018 ACTION Aclone(aImpManife)  OPERATION  2 ACCESS 0	//-- "Manifesto"

	ADD OPTION aRotina    TITLE STR0033 ACTION Aclone(aImpressao)  OPERATION  8 ACCESS 0	//-- "Im&primir"
EndIf	
ADD OPTION aRotina    TITLE STR0034 ACTION Aclone(aManutenca)  OPERATION  9 ACCESS 0	//-- "Manutencao"
ADD OPTION aRotina    TITLE STR0039 ACTION Aclone(aRentabili)  OPERATION 10 ACCESS 0	//-- "Rentabilidade Prévia"

If lIntTPR
	ADD OPTION aRotTPR TITLE STR0083 ACTION "TMSAF68Sub( 11, 1)" OPERATION  2 ACCESS 0	//-- "Visualiza Mapa"
	ADD OPTION aRotTPR TITLE STR0082 ACTION "TMSAF68Sub( 11, 2)" OPERATION  2 ACCESS 0	//-- "Painel Planejamento Rotas"

	ADD OPTION aRotina TITLE STR0081 ACTION Aclone(aRotTPR)  OPERATION 11 ACCESS 0	//-- "Planejamento Rotas (TPR)
EndIf

If lRepom 
	ADD OPTION aContrato TITLE STR0062 ACTION "TMSC15ARep(1)" OPERATION  1 ACCESS 0	//-- "Gerar Contrato
	ADD OPTION aContrato TITLE STR0063 ACTION "TMSC15ARep(2)" OPERATION  2 ACCESS 0	//-- "Atualiza Status
	ADD OPTION aContrato TITLE STR0066 ACTION "TMSC15ARep(3)" OPERATION  3 ACCESS 0	//-- "Consulta Status
	ADD OPTION aContrato TITLE STR0067 ACTION "TMSC15ARep(4)" OPERATION  4 ACCESS 0	//-- "Interrompe Contrato"
	ADD OPTION aContrato TITLE STR0068 ACTION "TMSC15ARep(5)" OPERATION  5 ACCESS 0	//-- "Bloqueia Contrato"
	ADD OPTION aContrato TITLE STR0069 ACTION "TMSC15ARep(6)" OPERATION  5 ACCESS 0	//-- "Desbloqueia Contrato"
	ADD OPTION aContrato TITLE STR0070 ACTION "TMSC15ARep(7)" OPERATION  5 ACCESS 0	//-- "Cancela Contrato"
	ADD OPTION aContrato TITLE STR0079 ACTION "TMSC15ARep(13)" OPERATION  5 ACCESS 0	//-- ""Consulta Quitação
	ADD OPTION aContrato TITLE STR0078 ACTION "TMSC15ARep(12)" OPERATION  5 ACCESS 0	//-- "Conciliacao Financeira"

	ADD OPTION aRepom 	TITLE STR0061 ACTION aClone(aContrato) OPERATION  4 ACCESS 0	//-- "Repom"
	
	ADD OPTION aRotina TITLE STR0060 ACTION aClone(aRepom)  OPERATION  8 ACCESS 0	//-- ""Operadora de Frota"   "
EndIf 

//-- Analisa a possibilidade de integração com Coleta/Entrega
If lColent .Or. lTMSIntChk
	ADD OPTION aRotina TITLE STR0092 ACTION Aclone(aIntMnu)  OPERATION 10 ACCESS 0 //-- "Integrações"
EndIf

//-----------------------------------------------------------------------------
//-- FRETEBRAS
//-----------------------------------------------------------------------------
If FindFunction( "TMSAFretBr") 
	Aadd( aFreteBr , { STR0072	, "A144FretBr" , 0,3,0,.F. } )	//-- Incluir
	Aadd( aFreteBr , { STR0073	, "A144FretBr" , 0,2,0,.F. } ) 	//-- Visualizar
	Aadd( aFreteBr , { STR0074	, "A144FretBr" , 0,4,0,.F. } ) 	//-- Alterar
	Aadd( aFreteBr , { STR0075	, "A144FretBr" , 0,4,0,.F. } )	//-- Renovar
	Aadd( aFreteBr , { STR0076 	, "A144FretBr" , 0,4,0,.F. } )	//-- Concretizar
	Aadd( aFreteBr , { STR0077  , "A144FretBr" , 0,5,0,.F. } )	//-- Excluir
	Aadd( aRotina, { STR0071 , aFreteBr , 0,6,0,.F. }) //-- Oferta de Frete
EndIF

//-- Executa ponto de entrada para inclusão de itens no menu da viagem modelo 3
If lTmf68Mnu
	aRotUsu := ExecBlock("TMF68MNU",.F.,.F., { aRotina } )
	If ValType(aRotUsu) == "A"
		FwFreeArray(aRotina)
		aRotina	:= {} 
		For nCntFor1 := 1 To Len(aRotUsu)
			ADD OPTION aRotina TITLE aRotUsu[nCntFor1,1] ACTION aRotUsu[nCntFor1,2] OPERATION aRotUsu [nCntFor1,4] ACCESS 0	//-- Opçoes do usuário
		Next nCntFor1
	EndIf
EndIf

FwFreeArray(aEncerrame)
FwFreeArray(aFechament)
FwFreeArray(aComprovan)
FwFreeArray(aManifesto)
FwFreeArray(aCarregame)
FwFreeArray(aImpressao)
FwFreeArray(aManutenca)
FwFreeArray(aImpManife)
FwFreeArray(aRentabili)
FwFreeArray(aRotTPR)
Return aRotina

/*{Protheus.doc} TMSAF68Sub
Controla as chamadas das funções do menu da viagem modelo 3
@type Function
@author Valdemar Roberto Mognon
@since 12/08/2020
@version version
@param nRotina (indica a rotina do menu) / nAcao (indica a ação que será executada em cada rotina do menu)
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function TMSAF68Sub(nRotina,nAcao)

Private cCadastro := STR0059	//-- "Viagem Modelo 3"

Default nRotina := 0
Default nAcao   := 0

If nRotina > 0 .And. nAcao > 0
	If nRotina == 1			//-- Carregamento da viagem
		ExecCarreg(nAcao)
	ElseIf nRotina == 2		//-- Manifestos da viagem
		ExecManife(nAcao)
	ElseIf nRotina == 3		//-- Fechamento da viagem
		ExecFecham(nAcao)
	ElseIf nRotina == 4		//-- Encerramento da viagem
		ExecEncerr(nAcao)
	ElseIf nRotina == 5		//-- Comprovante de entrega eletrônico
		ExecCompro(nAcao)
	ElseIf nRotina == 6		//-- Rentabilidade prévia da viagem
		ExecRentab(nAcao)
	ElseIf nRotina == 8		//-- Manutenções da viagem
		ExecManute(nAcao)
	ElseIf nRotina == 9		//-- Impressão dos manifestos (viagem express)
		ExecImpMan(nAcao)
	ElseIf nRotina == 10	//-- Impressões de contrato e cheque (viagem express)
		ExecImpres(nAcao)
	ElseIf nRotina == 11	//-- Integração Planejamento Rotas (TPR)
		ExecIntTPR(nAcao)
	EndIf
EndIf

Return

/*{Protheus.doc} ExecCarreg
Executa as funções do carregamento da viagem
@type Static Function
@author Valdemar Roberto Mognon
@since 13/08/2020
@version version
@param nAcao (indica a ação que será executada em cada rotina do menu)
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function ExecCarreg(nAcao)
Local aAreas := {DM6->(GetArea()),GetArea()}

Default nAcao := 0

//-- Verifica se já existe carregamento
DM6->(DbSetOrder(1))
If DM6->(DbSeek(xFilial("DM6") + DTQ->(DTQ_FILORI + DTQ_VIAGEM)))
	If nAcao == 1			//-- Visualizar
		If TmsAcesso(,"TMSAF90",,2)
			FWExecView(,"TMSAF90",MODEL_OPERATION_VIEW)
		EndIf
	ElseIf nAcao == 2		//-- Carregar alterando
		If TmsAcesso(,"TMSAF90",,4)
			FWExecView(,"TMSAF90",MODEL_OPERATION_UPDATE)
		EndIf
	Else					//-- Estornar
		If TmsAcesso(,"TMSAF90",,5)
			FWExecView(,"TMSAF90",MODEL_OPERATION_DELETE)
		EndIf
	EndIf
Else
	If nAcao == 2	//-- Carregar do início
		If TmsAcesso(,"TMSAF90",,3)
			FWExecView(,"TMSAF90",MODEL_OPERATION_INSERT)
		EndIf
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return

/*{Protheus.doc} ExecManife
Executa as funções dos manifestos da viagem
@type Static Function
@author Valdemar Roberto Mognon
@since 13/08/2020
@version version
@param nAcao (indica a ação que será executada em cada rotina do menu)
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function ExecManife(nAcao)
Local aAreas     := {DTR->(GetArea()),DTX->(GetArea()),GetArea()}
Local aIndexSub  := {}
Local aCores     := {}
Local aCampos    := {}
Local cFiltraSub := ""
Local lColig     := .T.
Local bFiltraSub

Private aRotina := {}

Default nAcao := 0

DTR->(DbSetOrder(1))
If DTR->(DbSeek(xFilial("DTR") + DTQ->(DTQ_FILORI + DTQ_VIAGEM))) .And. !Empty(DTR->DTR_NUMVGE) .And. !Empty(DTR->DTR_FILVGE)
	lColig := .T.
EndIf

If nAcao == 1			//-- Visual/Excluir
	SetFunName("TMSA190")

	DTX->(DbSetOrder(1))

	Aadd(aRotina,{STR0044,"TMSXPesqui",0,1})	//-- "&Pesquisar"
			
	If TmsAcesso(,"TMSA190",,2,.F.)
		Aadd(aRotina,{STR0014,"TmsA190Mnt",0,2})	//-- "&Visualizar"
	EndIf
	If TmsAcesso(,"TMSA190",,5,.F.)
		Aadd(aRotina,{STR0051,"TmsA190Mnt",0,5})	//-- "&Excluir"
	EndIf

	Aadd(aRotina,{STR0047,"TmsA190Leg",0,6})	//-- "&Legenda"
			
	If Len(aRotina) == 2
		Help("",1,"SEMPERM",,,03,00)
	Else
		aIndexSub  := {}
		cFiltraSub := "DTX_FILIAL == '" + xFilial("DTX") + "' .And. DTX_FILORI == '" + DTQ->DTQ_FILORI + "' .And. DTX_VIAGEM == '" + DTQ->DTQ_VIAGEM + "'"

		bFiltraSub := {|| FilBrowse("DTX",@aIndexSub,@cFiltraSub)}
		Eval(bFiltraSub)

		Aadd(aCores,{"Empty(DTX->DTX_NUMCTC)" ,"BR_VERDE"   })	//-- Em Aberto
		Aadd(aCores,{"!Empty(DTX->DTX_NUMCTC)","BR_VERMELHO"})	//-- Contrato Gerado

		MaWndBrowse(0,0,300,600,STR0007,"DTX",aCampos,aRotina,,,,.T.,,,,,,,,.F.,,,,,aCores)	//-- "Manisfestar"

		EndFilBrw("DTX",aIndexSub)
	EndIf
	SetFunName("TMSAF60")
ElseIf nAcao == 2		//-- Manifestar
	SetFunName("TMSA190")

	DTX->(DbSetOrder(3))
	If lColig .And. DTX->(DbSeek(xFilial("DTX") + DTR->(DTR_FILVGE + DTR->DTR_NUMVGE)))
		Help("",1,"TMSAF6802",,STR0049 + AllTrim(DTX->DTX_MANIFE) + " / " + STR0050 + AllTrim(DTR->DTR_FILVGE) + '-' + AllTrim(DTR->DTR_NUMVGE),03,00)	//-- "Viagem já manifestada." ### "Manifesto: " ### "Viagem Principal: "
	Else
		If TmsAcesso(,"TMSA190",,3)
			aRotina := {{"","",0,1},;
						{"","",0,2},;
						{"","",0,3},;
						{"","",0,5}}
			TmsA190Mnt("DTX",0,3,DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM)
		EndIf
	EndIf
	SetFunName("TMSAF60")
ElseIf nAcao == 3		//-- MDF-e
	If TmsAcesso(,"TMSAE73",,2,.F.)
		TMSAE73()
	Else
		Help("",1,"SEMPERM",,,03,00)
	EndIf
ElseIf nAcao == 4		//-- Tracking eventos MDFe
	If TmsAcesso(,"TMSAE74",,4,.F.)
		TMSAE74()
	Else
		Help("",1,"SEMPERM",,,03,00)
	EndIf
ElseIf nAcao == 5		//-- Consulta
	If TmsAcesso(,"TMSAE73B",,2,.F.)
		TMSAE73B()
	Else
		Help("",1,"SEMPERM",,,03,00)
	EndIf
ElseIf nAcao == 6		//-- Histórico MDF-e
	If TmsAcesso(,"TMSA190A",,2,.F.)
		TMSA190A(2)
	Else
		Help("",1,"SEMPERM",,,03,00)
	EndIf
ElseIf nAcao == 7		//-- Vis. Percurso
	If TmsAcesso(,"TMSAF68PER",,2,.F.)
		TMSAF68PER(.F.)
	Else
		Help("",1,"SEMPERM",,,03,00)
	EndIf
ElseIf nAcao == 8		//-- Editar Percurso
	If TmsAcesso(,"TMSAF68PER",,2,.F.)
		TMSAF68PER(.T.)
	Else
		Help("",1,"SEMPERM",,,03,00)
	EndIf
Else					//-- Inclusão condutor
	If TmsAcesso(,"TMSAF68TRM",,2,.F.)
		TMSAF68TRM()
	Else
		Help("",1,"SEMPERM",,,03,00)
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
FwFreeArray(aRotina)
FwFreeArray(aCampos)
FwFreeArray(aIndexSub)
FwFreeArray(aCores)

Return

/*{Protheus.doc} ExecFecham
Executa as funções do fechamento da viagem
@type Static Function
@author Valdemar Roberto Mognon
@since 13/08/2020
@version version
@param nAcao (indica a ação que será executada em cada rotina do menu)
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function ExecFecham(nAcao)

Local lCont     := .F.

Private aRotina := {{"","",0,1},;
					{"","",0,2},;
					{"","",0,3},;
					{"","",0,5}}

Default nAcao := 0

SetFunName("TMSA310")

If nAcao == 1			//-- Fechar
	If DTQ->DTQ_SERTMS == StrZero(2,Len(DTQ->DTQ_SERTMS)) 
		If DTQ->DTQ_TIPTRA == StrZero(1,Len(DTQ->DTQ_TIPTRA))	//-- Transporte Rodoviário
			lCont:= TmsAcesso(,"TMSA310B",,3)
		ElseIf DTQ->DTQ_TIPTRA == StrZero(2,Len(DTQ->DTQ_TIPTRA))	//-- Transporte Aereo
			lCont:= TmsAcesso(,"TMSA310C",,3)
		EndIf

	ElseIf DTQ->DTQ_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS)) 
		If DTQ->DTQ_TIPTRA == StrZero(1,Len(DTQ->DTQ_TIPTRA))	//-- Entrega Rodoviária
			lCont:= TmsAcesso(,"TMSA310D",,3)
		ElseIf DTQ->DTQ_TIPTRA == StrZero(2,Len(DTQ->DTQ_TIPTRA))	//-- Entrega Aereo
			lCont:= TmsAcesso(,"TMSA310F",,3)
		EndIf
	EndIf

	If lCont
		TMSA310Mnt("DTQ",DTQ->(Recno()),3,,.T.)
	EndIf

Else					//-- Estornar
	If DTQ->DTQ_SERTMS == StrZero(2,Len(DTQ->DTQ_SERTMS)) 
		If DTQ->DTQ_TIPTRA == StrZero(1,Len(DTQ->DTQ_TIPTRA))	//-- Transporte Rodoviário
			lCont:= TmsAcesso(,"TMSA310B",,4)
		ElseIf DTQ->DTQ_TIPTRA == StrZero(2,Len(DTQ->DTQ_TIPTRA))	//-- Transporte Aereo
			lCont:= TmsAcesso(,"TMSA310C",,4)
		EndIf

	ElseIf DTQ->DTQ_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS))
		If DTQ->DTQ_TIPTRA == StrZero(1,Len(DTQ->DTQ_TIPTRA))	//-- Entrega Rodoviária
			lCont:= TmsAcesso(,"TMSA310D",,4)
		ElseIf DTQ->DTQ_TIPTRA == StrZero(2,Len(DTQ->DTQ_TIPTRA))	//-- Entrega Aereo
			lCont:= TmsAcesso(,"TMSA310F",,4)
		EndIf
	EndIf	

	If lCont
		TMSA310Mnt("DTQ",DTQ->(Recno()),4,,.T.)
	EndIf	
EndIf

Return

/*{Protheus.doc} ExecEncerr
Executa as funções do encerramento da viagem
@type Static Function
@author Valdemar Roberto Mognon
@since 13/08/2020
@version version
@param nAcao (indica a ação que será executada em cada rotina do menu)
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function ExecEncerr(nAcao)

Local lCont    := .F.

Private aRotina := {{"","",0,1},;
				   {"","",0,2},;
				   {"","",0,3},;
				   {"","",0,5}}

Default nAcao := 0

SetFunName("TMSA340")

If nAcao == 1			//-- Encerrar
	If DTQ->DTQ_SERTMS == StrZero(2,Len(DTQ->DTQ_SERTMS)) 
		If DTQ->DTQ_TIPTRA == StrZero(1,Len(DTQ->DTQ_TIPTRA))	//-- Transporte Rodoviário
			lCont:= TmsAcesso(,"TMSA340B",,3)		
		ElseIf DTQ->DTQ_TIPTRA == StrZero(2,Len(DTQ->DTQ_TIPTRA))	//-- Transporte Aereo
			lCont:= TmsAcesso(,"TMSA340C",,3)	
		EndIf

	ElseIf DTQ->DTQ_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS)) 
		If DTQ->DTQ_TIPTRA == StrZero(1,Len(DTQ->DTQ_TIPTRA))	//-- Entrega Rodoviária
			lCont:= TmsAcesso(,"TMSA340D",,3)
		ElseIf DTQ->DTQ_TIPTRA == StrZero(2,Len(DTQ->DTQ_TIPTRA))	//-- Entrega Aereo
			lCont:= TmsAcesso(,"TMSA340F",,3)	
		EndIf
	EndIf
	
	If lCont
		TMSA340Mnt("DTQ",0,3)
	EndIf
Else					//-- Estornar
	If DTQ->DTQ_SERTMS == StrZero(2,Len(DTQ->DTQ_SERTMS)) 
		If DTQ->DTQ_TIPTRA == StrZero(1,Len(DTQ->DTQ_TIPTRA))	//-- Transporte Rodoviário
			lCont:= TmsAcesso(,"TMSA340B",,4)
		ElseIf DTQ->DTQ_TIPTRA == StrZero(2,Len(DTQ->DTQ_TIPTRA))	//-- Transporte Aereo
			lCont:= TmsAcesso(,"TMSA340C",,4)	
		EndIf

	ElseIf DTQ->DTQ_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS)) 
		If DTQ->DTQ_TIPTRA == StrZero(1,Len(DTQ->DTQ_TIPTRA))	//-- Entrega Rodoviária
			lCont:= TmsAcesso(,"TMSA340D",,4)
		ElseIf DTQ->DTQ_TIPTRA == StrZero(2,Len(DTQ->DTQ_TIPTRA))	//-- Entrega Aereo
			lCont:= TmsAcesso(,"TMSA340F",,4)	
		EndIf
	EndIf

	If lCont
		TMSA340Mnt("DTQ",DTQ->(Recno()),4)
	EndIf
EndIf

Return

/*{Protheus.doc} ExecCompro
Executa as funções do comprovante de entrega
@type Static Function
@author Valdemar Roberto Mognon
@since 13/08/2020
@version version
@param nAcao (indica a ação que será executada em cada rotina do menu)
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function ExecCompro(nAcao)

Default nAcao := 0

If DTQ->DTQ_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS))
	If nAcao == 1			//-- Monitora
		TMSAE71A()
	Else					//-- Altera
		TMSAE71B()
	EndIf
Else
	Help("",1,"TMSAF6807",,,03,00)	//-- "O comprovante de entrega só pode ser utilizado em viagens de entrega."
EndIf

Return

/*{Protheus.doc} ExecRentab
Executa as funções da rentabilidade da viagem
@type Static Function
@author Valdemar Roberto Mognon
@since 13/08/2020
@version version
@param / nAcao (indica a ação que será executada em cada rotina do menu)
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function ExecRentab(nAcao)

Default nAcao := 0

If nAcao == 1			//-- Simular Rentabilidade
	TMSAF68Rnt(1)
Else					//-- Excluir Rentabilidade
	TMSAF68Rnt(2)
EndIf

Return

/*{Protheus.doc} ExecManute
Executa as funções das manutenções da viagem
@type Static Function
@author Valdemar Roberto Mognon
@since 13/08/2020
@version version
@param nAcao (indica a ação que será executada em cada rotina do menu)
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function ExecManute(nAcao)
Local lCont      := .T.
Local aAreas     := {}
Local aIndexSub  := {}
Local aCores     := {}
Local aCampos    := {}
Local cFiltraSub := ""
Local nOpcDJM    := 0
Local oModelDJM  := Nil
Local bFiltraSub := Nil
Local lAcesso    := .F.
Local lAcesso2   := .F.
Local lAcesso3   := .F.
Local lAcesso5   := .F.

Private aRotina := {}

Default nAcao := 0

If nAcao == 1			//-- Confirmação
	SetFunName("TMSA142")

	If DTQ->DTQ_SERTMS == StrZero(2,Len(DTQ->DTQ_SERTMS)) 
		If DTQ->DTQ_TIPTRA == StrZero(1,Len(DTQ->DTQ_TIPTRA))	//-- Transporte Rodoviário
			lCont := TmsAcesso(,"TMSA142E",,3)
		ElseIf DTQ->DTQ_TIPTRA == StrZero(2,Len(DTQ->DTQ_TIPTRA))	//-- Transporte Aereo
			lCont := TmsAcesso(,"TMSA142F",,3)
		EndIf

	ElseIf DTQ->DTQ_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS)) 
		If DTQ->DTQ_TIPTRA == StrZero(1,Len(DTQ->DTQ_TIPTRA))	//-- Entrega Rodoviária
			lCont := TmsAcesso(,"TMSA142C",,3)
		ElseIf DTQ->DTQ_TIPTRA == StrZero(2,Len(DTQ->DTQ_TIPTRA))	//-- Entrega Aereo
			lCont := TmsAcesso(,"TMSA142D",,3)
		EndIf
	EndIf

	If lCont
		TmsA142(DTQ->DTQ_SERTMS,DTQ->DTQ_TIPTRA,.T.)
	EndIf

ElseIf nAcao == 2		//-- Geração AWB
	If DTQ->DTQ_TIPTRA == StrZero(2,Len(DTQ->DTQ_TIPTRA)) 
		aAreas := {DTV->(GetArea()),GetArea()}
	
		SetFunName("TMSA320")
	
		Aadd(aRotina,{STR0044,"AxPesqui",0,1})	//-- "&Pesquisar"
	
		If TmsAcesso(,"TMSA320",,2,.F.)
			Aadd(aRotina,{STR0014,"TMSAF68AWB",0,2})	//-- "&Visualizar"
		EndIf
		If TmsAcesso(,"TMSA320",,3,.F.)
			Aadd(aRotina,{STR0052,"TMSAF68AWB",0,3})	//-- "&Incluir"
		EndIf
		If TmsAcesso(,"TMSA320",,4,.F.)
			Aadd(aRotina,{STR0002,"TMSAF68AWB",0,5})	//-- "&Estornar"
		EndIf
		If TmsAcesso(,"TMSA320",,5,.F.)
			Aadd(aRotina,{STR0033,"TMSAF68IAW",0,4})	//-- "Im&primir"
		EndIf
	
		If Len(aRotina) == 1
			Help("",1,"SEMPERM",,,03,00)
		Else
			aIndexSub  := {}
			cFiltraSub := "DTV_FILIAL == '" + xFilial("DTV") + "' .And. DTV_FILORI == '" + DTQ->DTQ_FILORI + "' .And. DTV_VIAGEM == '" + DTQ->DTQ_VIAGEM + "'"
		
			bFiltraSub := {|| FilBrowse("DTV",@aIndexSub,@cFiltraSub)}
			Eval(bFiltraSub)
		
			MaWndBrowse(0,0,300,660,STR0020,"DTV",aCampos,aRotina,,,,.T.,,,,,,,,.F.,,,,,aCores)	//-- "Geracao AWB"
		
			EndFilBrw("DTV",aIndexSub)
		EndIf
		
		AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
		FwFreeArray(aRotina)
		FwFreeArray(aIndexSub)
		FwFreeArray(aCores)
		FwFreeArray(aCampos)
	Else
		Help("",1,"TMSAF6808",,,03,00)	//-- "A geração de AWB só pode ser utilizada em viagens de transferência."
	EndIf
ElseIf nAcao == 3		//-- Operações
	aAreas := {DTW->(GetArea()),GetArea()}

	SetFunName("TMSA350")

	DTW->(DbSetOrder(1))
	
	Aadd(aRotina,{STR0044,"TMSXPesqui",0,1})	//-- "&Pesquisar"
	
	If DTQ->DTQ_SERTMS == StrZero(2,Len(DTQ->DTQ_SERTMS)) 
		If  DTQ->DTQ_TIPTRA == StrZero(1,Len(DTQ->DTQ_TIPTRA))	//-- Transporte Rodoviário
			lAcesso2:= TmsAcesso(,"TMSA350B",,2,.F.)
			lAcesso3:= TmsAcesso(,"TMSA350B",,3,.F.)
			lAcesso5:= TmsAcesso(,"TMSA350B",,5,.F.)
		ElseIf  DTQ->DTQ_TIPTRA == StrZero(2,Len(DTQ->DTQ_TIPTRA))	//-- Transporte Aereo
			lAcesso2:= TmsAcesso(,"TMSA350C",,2,.F.)
			lAcesso3:= TmsAcesso(,"TMSA350C",,3,.F.)
			lAcesso5:= TmsAcesso(,"TMSA350C",,5,.F.)
		EndIf

	ElseIf DTQ->DTQ_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS)) 
		If DTQ->DTQ_TIPTRA == StrZero(1,Len(DTQ->DTQ_TIPTRA))	//-- Entrega Rodoviária
			lAcesso2:= TmsAcesso(,"TMSA350D",,2,.F.)
			lAcesso3:= TmsAcesso(,"TMSA350D",,3,.F.)
			lAcesso5:= TmsAcesso(,"TMSA350D",,5,.F.)		
			lAcesso := ExistFunc('TMSA351Vis') .And. !Empty(cAtvChgCli)
		
		ElseIf DTQ->DTQ_TIPTRA == StrZero(2,Len(DTQ->DTQ_TIPTRA))	//-- Entrega Aereo
			lAcesso2:= TmsAcesso(,"TMSA350F",,2,.F.)
			lAcesso3:= TmsAcesso(,"TMSA350F",,3,.F.)
			lAcesso5:= TmsAcesso(,"TMSA350F",,5,.F.)
		EndIf
	EndIf 

	If lAcesso2
		Aadd(aRotina,{STR0014,"TmsA350Mnt",0,2})	//-- "&Visualizar"
	EndIf
	If lAcesso3
		Aadd(aRotina,{STR0045,"TmsA350Mnt",0,3})	//-- "&Apontar"
	EndIf
	If lAcesso5
		Aadd(aRotina,{STR0002,"TmsA350Est",0,5})	//-- "&Estornar" 
	EndIf
	If lAcesso
		Aadd(aRotina,{STR0046,"TMSA351Vis",0,7})	//-- "Documentos"
	EndIf

	Aadd(aRotina,{STR0047,"TmsA350Leg",0,6})	//-- "&Legenda"

	If Len(aRotina) == 2
		Help("",1,"SEMPERM",,,03,00)
	Else
		aIndexSub  := {}
		cFiltraSub := "DTW_FILIAL == '" + xFilial("DTW") + "' .And. DTW_FILORI == '" + DTQ->DTQ_FILORI + "' .And. DTW_VIAGEM == '" + DTQ->DTQ_VIAGEM + "'"
	
		bFiltraSub := {|| FilBrowse("DTW",@aIndexSub,@cFiltraSub)}
		Eval(bFiltraSub)
	
		Aadd(aCores,{"DTW->DTW_STATUS == '1'","BR_VERDE"   })	//-- Em Aberto
		Aadd(aCores,{"DTW->DTW_STATUS == '2'","BR_VERMELHO"})	//-- Encerrado
		Aadd(aCores,{"DTW->DTW_STATUS == '9'","BR_PRETO"   })	//-- Cancelado
	
		MaWndBrowse(0,0,300,600,STR0021,"DTW",aCampos,aRotina,,,,.T.,,,,,,,,.F.,,,,,aCores)	//-- "Operações"
	
		EndFilBrw("DTW",aIndexSub)
	EndIf
	
	AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
	FwFreeArray(aRotina)
	FwFreeArray(aIndexSub)
	FwFreeArray(aCores)
	FwFreeArray(aCampos)
ElseIf nAcao == 4		//-- Reg.Ocorrência
	aAreas := {DTW->(GetArea()),GetArea()}

	SetFunName("TMSA360")

	TMA360Ini()	//-- Inicializa F12

	DUA->(DbSetOrder(1))
			
	Aadd(aRotina,{STR0044,"TMSXPesqui",0,1})	//-- "&Pesquisar"
			
	If TmsAcesso(,"TMSA360",,2,.F.)
		Aadd(aRotina,{STR0014,"TMSAF68OCO",0,2})	//-- "&Visualizar"
	EndIf
	
	If TmsAcesso(,"TMSA360",,3,.F.)
		Aadd(aRotina,{STR0045,"TMSAF68OCO",0,3})	//-- "&Apontar"	
	EndIf
	
	If TmsAcesso(,"TMSA360",,4,.F.)
		Aadd(aRotina,{STR0002,"TMSAF68OCO",0,6})	//-- "&Estornar"
	EndIf
	
	If TmsAcesso(,"TMSA360",,7,.F.)
		Aadd(aRotina,{STR0048,"TMSAF68OCO",0,6})	//-- "Aju&star"
	EndIf
		
	If Len(aRotina) == 1
		Help("",1,"SEMPERM",,,03,00)
	Else
		aIndexSub  := {}
		cFiltraSub := "DUA_FILIAL == '" + xFilial("DUA") + "'.And.DUA_FILORI == '" + DTQ->DTQ_FILORI + "'.And.DUA_VIAGEM == '" + DTQ->DTQ_VIAGEM + "'"
	
		bFiltraSub := {|| FilBrowse("DUA",@aIndexSub,@cFiltraSub)}
		Eval(bFiltraSub)
	
		MaWndBrowse(0,0,300,600,STR0023,"DUA",aCampos,aRotina,,,,.T.,,,,,,,,.F.)	//-- "Reg.Ocorrência"
	
		EndFilBrw("DUA",aIndexSub)
	EndIf
	
	AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
	FwFreeArray(aRotina)
	FwFreeArray(aIndexSub)
	FwFreeArray(aCores)
	FwFreeArray(aCampos)
ElseIf nAcao == 5		//-- Movto.Caixinha
	aAreas := {SEU->(GetArea()),GetArea()}

	SetFunName("FINA560")

	Aadd(aRotina,{STR0044,"AxPesqui",0,1})	//-- "&Pesquisar" 

	If TmsAcesso(,"FINA560",,2,.F.)
		Aadd(aRotina,{STR0014,"AxVisual",0,2})	//-- "&Visualizar"
	EndIf
	If TmsAcesso(,"FINA560",,3,.F.)
		Aadd(aRotina,{STR0052,"TMSA144Mcx",0,3})	//-- "&Incluir"
	EndIf
	If TmsAcesso(,"FINA560",,4,.F.)
		Aadd(aRotina,{STR0053,"TMSA144Mcx",0,5})	//-- "&Cancelar"
	EndIf
	If TmsAcesso(,"FINA560",,5,.F.)
		Aadd(aRotina,{STR0054,"TMSA144Mcx",0,4})	//-- "P&rest. de Contas"
	EndIf

	Aadd(aRotina,{STR0047,"FA560Legend",0,2})	//-- "&Legenda"

	If Len(aRotina) == 2
		Help("",1,"SEMPERM",,,03,00)
	Else
		aCores := {}
		Aadd(aCores,{"SEU->EU_TIPO = '00' .And. Empty(SEU->EU_BAIXA) .And. Empty(SEU->EU_NROADIA)","ENABLE"})	//-- Despesas nao baixadas
		Aadd(aCores,{"SEU->EU_TIPO = '00' .And. Empty(SEU->EU_BAIXA)"                             ,"BR_AZUL"})	//-- Despesas de adiantamento nao baixadas
		Aadd(aCores,{"SEU->EU_TIPO = '01' .And. SEU->EU_SLDADIA > 0"                              ,"BR_AMARELO"})	//-- Adiantamento com saldo (em aberto)
		Aadd(aCores,{"!Empty(SEU->EU_BAIXA)"                                                      ,"DISABLE"})	//-- Despesas baixadas e outros movimentos
	
		aIndexSub  := {}
		cFiltraSub := "EU_FILIAL == '" + xFilial("SEU") + "' .And. EU_FILORI == '" + DTQ->DTQ_FILORI + "' .And. EU_VIAGEM == '" + DTQ->DTQ_VIAGEM + "'"

		bFiltraSub := {|| FilBrowse("SEU",@aIndexSub,@cFiltraSub)}
		Eval(bFiltraSub)
	
		MaWndBrowse(0,0,300,660,STR0026,"SEU",aCampos,aRotina,,,,.T.,,,,,,,,.F.,,,,,aCores)	//-- "Movto.Caixinha"
	
		EndFilBrw("SEU",aIndexSub)
	EndIf
	
	AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
	FwFreeArray(aRotina)
	FwFreeArray(aIndexSub)
	FwFreeArray(aCores)
	FwFreeArray(aCampos)
ElseIf nAcao == 6		//-- Estorno Express
	If FindFunction('TF64EstExp')
		FWMsgRun(, {|| TF64EstExp(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM)},STR0027)   //"Estorno Express
	EndIf
ElseIf nAcao == 7		//-- Retorno de Unitizadores
	If DTQ->DTQ_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS))
		If TmsAcesso(,"TmsA141RU",,2,.F.)
			//TmsA141RU()
		Else
			Help("",1,"SEMPERM",,,03,00)
		EndIf
	Else
		Help("",1,"TMSAF6809",,,03,00)	//-- "O retorno de unitizadores só pode ser utilizado em viagens de entrega."
	EndIf
ElseIf nAcao == 8		//-- Fornecedores Adicionais
	aAreas := {DJM->(GetArea()),GetArea()}

	DJM->(DbSetOrder(1))
	If DbSeek(xFilial("DJM") + DTQ->(DTQ_FILORI + DTQ_VIAGEM))
		If TmsAcesso(,"TMSA151",,4,.F.)
			nOpcDJM := MODEL_OPERATION_UPDATE
		EndIf
	Else
		If TmsAcesso(,"TMSA151",,3,.F.)
			nOpcDJM := MODEL_OPERATION_INSERT
		EndIf
	EndIf

	If nOpcDJM != 0	
		oModelDJM := FWLoadModel("TMSA151")
		oModelDJM:SetOperation(nOpcDJM)
		oModelDJM:Activate()
		
		If nOpcDJM == MODEL_OPERATION_INSERT
			oModelDJM:GetModel("TMSA151_CAB"):SetValue("DJM_FILORI",DTQ->DTQ_FILORI)
			oModelDJm:GetModel("TMSA151_CAB"):SetValue("DJM_VIAGEM",DTQ->DTQ_VIAGEM)
		EndIf
	
		FWExecView("TMSA151",nOpcDJM,,{|| .T.},,,,,,,oModelDJM)
		oModelDJM:DeActivate()
	Else
		Help("",1,"SEMPERM",,,03,00)
	EndIf
	
	AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
ElseIf nAcao == 9 //-- Manutenção de Transporte (TMSA500)
	If DTQ->DTQ_STATUS == StrZero(4,Len(DTQ->DTQ_STATUS)) //--Chegada em Filial 
		If ExistFunc("TMSF62VDoc")
			TMSF62VDoc(DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM )
		EndIf 
	Else
		Help( " ",1,"TMSAF6810") //--Manutenção de Transportes permitida somente para viagem com chegada em filial
	EndIf 	

Else	//-- Troca de Cartão
	TMSA161()
EndIf

Return

/*{Protheus.doc} ExecImpMan
Executa as funções das impressões dos manifestos da viagem (express)
@type Static Function
@author Valdemar Roberto Mognon
@since 13/08/2020
@version version
@param nAcao (indica a ação que será executada em cada rotina do menu)
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function ExecImpMan(nAcao)

Default nAcao := 0

If nAcao == 1			//-- Manifesto
	TMSAF68IMn("NORMAL")
Else					//-- DAMDFE
	TMSAF68IMn("DAMDFE")
EndIf

Return

/*{Protheus.doc} ExecImpres
Executa as funções das impressões da viagem (express)
@type Static Function
@author Valdemar Roberto Mognon
@since 13/08/2020
@version version
@param nAcao (indica a ação que será executada em cada rotina do menu)
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function ExecImpres(nAcao)

Default nAcao := 0

If nAcao == 1			//-- Contrato
	TMSAF68ICt()
Else					//-- Cheque
	TMSAF68ICh()
EndIf

Return

/*{Protheus.doc} Tmsaf68Per
Função para chamar a visualização/edição do percurso com a viagem posicionada
@type Function
@author Valdemar Roberto Mognon
@since 14/08/2020
@version version
@param lEdita Indica se edit percurso
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function Tmsaf68Per(lEdit)

Default lEdit := .F.

If lEdit .And. !DTQ->DTQ_STATUS $ "1:2:5"	//-- 1-Em Aberto; 2-Em Transito; 5-Fechada
	Help("",1,"TMSAF6801")	//-- Não é possível editar o Percurso com status da viagem diferente de Em Aberto, Em Transito ou Fechada.
Else
	F16ExbPerc(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,lEdit)
EndIf

Return

/*{Protheus.doc} Tmsaf68TrM
Chamada da função para inclusão de condutor
@type Function
@author Valdemar Roberto Mognon
@since 14/08/2020
@version version
@param
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function Tmsaf68TrM()
Local aAreas := {GetArea()}

If DTQ->DTQ_STATUS == StrZero(2,Len(DTQ->DTQ_STATUS))	//-- Viagem em trânsito
	//-- Indica para o modelo da viagem que é inclusão de condutor
	TMFSetStat("lIncMot",.T.)
	//-- Executa a alteração da viagem
	FWExecView(,"TMSAF60",MODEL_OPERATION_UPDATE)
	//-- Indica para o modelo da viagem que não é inclusão de condutor
	TMFSetStat("lIncMot",.F.)
Else
  Help("",1,"TMSXFUNA25")
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
FwFreeArray(aRotina)
   
Return 

/*{Protheus.doc} Tmsaf68Oco
Chamada para o registro de ocorrências
@type Function
@author Valdemar Roberto Mognon
@since 14/08/2020
@version version
@param
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function Tmsaf68Oco(cAlias,nTMSReg,nOpcx)

Default cAlias  := ""
Default nTMSReg := 0
Default nOpcx   := 0

If nOpcx == 3
	Tmsa360Mnt(cAlias,0,nOpcx,DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM)
Else
	Tmsa360Mnt(cAlias,DUA->(Recno()),nOpcx)
EndIf

Return


/*{Protheus.doc} TMSAF68IMn
Imprime Manifesto
@type Static Function
@author Valdemar Roberto Mognon
@since 14/08/2020
@version version
@param
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function TMSAF68IMn(cTipMan)
Local aAreas := {DTX->(GetArea()),GetArea()}

Default cTipMan := ""

DTX->(DbSetOrder(3))
If DTX->(MsSeek(xFilial("DTX") + DTQ->(DTQ_FILORI + DTQ_VIAGEM)))
	TmsA190Imp("DTX",DTX->(Recno()),7,cTipMan)
Else
	Help("",1,"TMSAF6805")	//-- Manifesto não encontrado.
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return

/*{Protheus.doc} TMSAF68ICt
Imprime Contrato de Carreteiro
@type Static Function
@author Valdemar Roberto Mognon
@since 14/08/2020
@version version
@param
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function TMSAF68ICt()
Local aAreas   := {DTY->(GetArea()),GetArea()}
Local lRTMSR06 := ExistBlock("RTMSR06")

DTY->(DbSetOrder(2))
If DTY->(!DbSeek(xFilial("DTY") + DTQ->(DTQ_FILORI + DTQ_VIAGEM)))
	Help("",1,"TMSAF6806")	//-- "Contrato não encontrado"
	Return( Nil )
ElseIf lRTMSR06
	// -- Se a rotina de impressão do contrato do carreteiro estiver sendo executada por outro usuário o sistema não imprime o contrato
	If LockByName("IMPCTC",.T.,.F.)
		Pergunte("RTMSR06",.F.)

		MV_PAR01 := DTQ->DTQ_FILORI
		MV_PAR02 := DTQ->DTQ_FILORI
		MV_PAR03 := DTQ->DTQ_VIAGEM
		MV_PAR04 := DTQ->DTQ_VIAGEM
	
		ExecBlock("RTMSR06",.F.,.F.)

		UnLockByName("IMPCTC",.T.,.F.)
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return

/*{Protheus.doc} TMSAF68ICh
Imprime cheques vinculados ao Contrato
@type Function
@author Valdemar Roberto Mognon
@since 14/08/2020
@version version
@param
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function TMSAF68ICh()
Local aAreas   := {GetArea()}
Local lRTMSR13 := ExistBlock("RTMSR13")

If lRTMSR13
	ExecBlock("RTMSR13",.F.,.F.)
Endif

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return


/*{Protheus.doc} TMSAF68Rnt
Calcula a rentabilidade da viagem
@type Static Function
@author Valdemar Roberto Mognon
@since 14/08/2020
@version version
@param
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function TMSAF68Rnt(nMenu)
Local nOpc := 0	

Default nMenu := 1 

nOpc := Iif(nMenu == 1,3,5)

TMSRentab(nOpc,DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM)
	
Return

/*{Protheus.doc} TMSAF68IAW
Imprime cheques vinculados ao Contrato
@type Function
@author Valdemar Roberto Mognon
@since 14/08/2020
@version version
@param
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function TMSAF68IAW()
Local aAreas   := {GetArea()}
Local lRTMSR08 := ExistBlock("RTMSR08")

If lRTMSR08
	ExecBlock("RTMSR08",.F.,.F.)
Endif

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return

/*{Protheus.doc} TMSAF68IAW
Chamada para o Geracao de AWB Somente em Transp Aereo 
@type Function
@author Katia
@since 29/06/2021
@version version
@param
@return return, return_type, return_description
@example
(examples)
Funcionalidade da rotina TMSA144AWB
*/
Function TMSAF68AWB(cAlias, nTmsRec, nOpc)
Local lRet

If nOpc == 3
	Inclui := .T.
	lRet   := TMSA320Mnt(cAlias, 0, nOpc, DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM)
Else
	Inclui := .F.
	lRet   := TMSA320Mnt(cAlias, DTV->(Recno()), nOpc)
EndIf

Return( lRet )


/*{Protheus.doc} ExecIntTPR
Executa as funções da integração com Planejamento de Rotas (TPR)
@type Static Function
@author Katia
@since 22/09/2021
@version version
@param nAcao (indica a ação que será executada em cada rotina do menu)
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function ExecIntTPR(nAcao)
Local aArea   := GetArea()

Default nAcao := 0

If nAcao == 1			//-- Visualiza Mapa
	TMSAC24Map('DTQ', DTQ->(Recno()), 2)
ElseIf nAcao == 2		//-- Consulta
	T146PnlTPR('DTQ', DTQ->(Recno()), 2)
EndIf

RestArea(aArea)
FwFreeArray(aArea)
Return
