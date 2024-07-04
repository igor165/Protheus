#Include "GTPX600R.ch"
#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "DBTREE.CH"
#INCLUDE "MSOLE.CH"

//-----------------------------------------------------------------------
/*/{Protheus.doc} GTPX600R
Imprime o contrato de locação
@type function
@author jacomo.fernandes
@since 02/08/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTPX600R()
Local lRet				:= .T.
Local lConfSimples		:= G6R->G6R_STATUS <> '2' //DIFERENTE GANHA

Processa( {|| GerDocContr(lConfSimples) },, OemToAnsi(STR0001) ) //"STR0001" //"Gerando contrato de viagens..."


Return(lRet)

/*/{Protheus.doc} GerDocContr
Gera contrato de Viagens Especiais conforme modelo word (.Dot) definido via
parametro do sistema. 
@type function
@author jacomo.fernandes
@since 28/11/2018
@version 1.0
@param lConfSimples, ${param_type}, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GerDocContr(lConfSimples)

Local cNumProp	:= G6R->G6R_PROPOS
Local cPath		:= Alltrim(SuperGetMv( "MV_DIRDOC", .F., "\WORD\" ) )
Local cArqDot	:= Alltrim(SuperGetMv( "MV_MODCON", .F., "CONTRATOGTP.DOT" )  )
Local cItinerar	:= ""
Local cWord		:= ""
Local cFileDot	:= ""
Local cFileDoc	:= ""
Local aDados  	:= {}
Local aParc		:= {}
Local nInd    	:= 0
Local nTotProd 	:= 0
Local nPCliName	:= 0
Local nRet      := 0
Local cCpfCnpj	:= ""
Local lCliente	:= .T.
Local lRet		:= .T.
Local aRet      := {}
Local aParamBox	:= {}
Local nNumCop   := GTPGetRules('NUMCOPIAS')

DEFAULT lConfSimples	:= .T.

If SubStr(cPath,-1) <> "\"
	cPath += "\" 
Endif

cFileDot := AllTrim(cPath + cArqDot) 

If !(ExistDir( cPath ))
	nRet := MakeDir( cPath )
EndIf

// Verifica a existencia do DOT no ROOTPATH Protheus / Servidor
If !File(cFileDot)
	lRet := RESOURCE2FILE(cArqDot, cFileDot)
	If lRet .AND. !File(cFileDot)
		MsgStop(STR0003,STR0002) //"GTPX600R" //"Verifique os parametros MV_DIRDOC e MV_MODCON."
		lRet := .F.
	Else
		MsgStop(STR0004,STR0002) //"O modelo (.Dot) do contrato não foi encontrado, verifique os parametros MV_DIRDOC e MV_MODCON." //"GTPX600R"
	EndIf
Endif

// Valida se a instância, com a aplicação Microsoft Word, encontra-se válida.
If lRet .And. cWord == "-1" 
	OLE_CloseFile( cWord )
	OLE_CloseLink( cWord )
	MsgStop(STR0005, STR0002) //"GTPX600R" //"Impossível estabelecer comunicação com o Microsoft Word."
	lRet := .F.
Else	
	
	ProcRegua( 3 )
			
	//------------------------------------------------------------+
	// BUSCA OS DADOS DA CONTRATO (PROPOSTA) PARA JOGAR NO  WORD. |
	//------------------------------------------------------------+		

	// Recupera o valor total de produtos informado.	
	nTotProd := G6R->G6R_VALACO
	
	// Posiciona no cliente ou Prospect
	If !Empty(G6R->G6R_SA1COD)
		SA1->(DbSetOrder(1))
		SA1->(DbSeek(xFilial("SA1")+G6R->G6R_SA1COD+G6R->G6R_SA1LOJ))
		lCliente := .T.
	Else
		SUS->(DbSetOrder(1))
		SUS->(DbSeek(xFilial("SUS")+G6R->G6R_SUSCOD+G6R->G6R_SUSLOJ))
		lCliente := .F.
	Endif
	
	// Contrato apenas p/ conferencia (Antes da Confirmação da Proposta)
	If lConfSimples
		Aadd(aDados, {"Conferencia", "SIMPLES CONFERÊNCIA"})
	Else
		Aadd(aDados, {"Conferencia", ""})
	EndIf
	
	If lCliente
		cCpfCnpj := SA1->A1_CGC
	Else
		cCpfCnpj := SUS->US_CGC
	Endif 
	
	cCpfCnpj := Transform(cCpfCnpj, If(Len(Alltrim(cCpfCnpj)) == 14, "@R 99.999.999/9999-99", "@R 999.999.999-99"))
	
	// Dados Gerais do Contrato.
	Aadd(aDados, {"nrcontrato"			, G6R->G6R_PROPOS})
	Aadd(aDados, {"dDtPrint"			, dDataBase})
	Aadd(aDados, {"cHrPrint"			, Time()})
	Aadd(aDados, {"nomecontratante"		, If(lCliente,SA1->A1_NOME,SUS->US_NOME) })
	Aadd(aDados, {"CPFCNPJContrate"		, cCpfCnpj })
	Aadd(aDados, {"IEContratante"		, If(lCliente,SA1->A1_INSCR,SUS->US_INSCR) })
	Aadd(aDados, {"Endcontratante"		, If(lCliente,SA1->A1_END,SUS->US_END) })
	Aadd(aDados, {"Bairrocontratante"	, If(lCliente,SA1->A1_BAIRRO,SUS->US_BAIRRO) })
	Aadd(aDados, {"Cidadecontratante"	, If(lCliente,SA1->A1_MUN,SUS->US_MUN) })
	Aadd(aDados, {"UFcontratante"		, If(lCliente,SA1->A1_EST,SUS->US_EST) })   
	Aadd(aDados, {"Telcontratante"		, If(lCliente,SA1->A1_TEL,SUS->US_TEL) })
	Aadd(aDados, {"RGcontratante"		, If(lCliente,SA1->A1_RG,'') })
	
	Aadd(aDados, {"nomecontratada"		, SM0->M0_NOMECOM })  
	Aadd(aDados, {"CFOPcontratada"		, Posicione('SF4',1,xFilial("SF4")+G6R->G6R_TES,"F4_CF")})
	Aadd(aDados, {"Endcontratada"		, SM0->M0_ENDCOB })
	Aadd(aDados, {"Bairrocontratada"	, SM0->M0_BAIRCOB })
	Aadd(aDados, {"Cidadecontratada"	, SM0->M0_CIDCOB })
	Aadd(aDados, {"UFcontratada"		, SM0->M0_ESTCOB })
	Aadd(aDados, {"CNPJcontratada"		, Transform(SM0->M0_CGC, "@R 99.999.999/9999-99" ) })
	Aadd(aDados, {"IEcontratada"		, SM0->M0_INSC })
	Aadd(aDados, {"agencia"				, SM0->M0_CIDCOB })
	Aadd(aDados, {"QtdePassageiros"		, G6R->G6R_POLTR })
	Aadd(aDados, {"QtdeCarro"			, G6R->G6R_QUANT})
	
	// Primeira linha
	Aadd(aDados, {"horaini"				, Transform(G6R->G6R_HRIDA, PesqPict("G6R","G6R_HRIDA")) })
	Aadd(aDados, {"dataini"				, G6R->G6R_DTIDA})
	
	
	Aadd(aDados, {"localembraque"		, G6R->G6R_ENDEMB })
	Aadd(aDados, {"horafim"				, Transform(G6R->G6R_HRVLTA, PesqPict("G6R","G6R_HRVLTA")) })
	Aadd(aDados, {"datafim"				, G6R->G6R_DTVLTA })
	
	cItinerar :=	AllTrim(Posicione('GI1',1,xFilial('GI1')+G6R->G6R_LOCORI,"GI1_DESCRI")) + ;
					" - " + ;
					AllTrim(Posicione('GI1',1,xFilial('GI1')+G6R->G6R_LOCDES,"GI1_DESCRI"))
	
	Aadd(aDados, {"itinerario"			, cItinerar })
	Aadd(aDados, {"valor"				, Transform(nTotProd, PesqPict("G6R", "G6R_VALACO"))+ " ("+Extenso(nTotProd)+" )"  })
	Aadd(aDados, {"kmrodados"			, Transform(G6R->G6R_KMCONT, PesqPict("G6R","G6R_KMCONT")) })
	Aadd(aDados, {"kmexcedente"			, Transform(G6R->G6R_KMEXCE, PesqPict("GIP","GIP_KMEXCE")) })

	
	// -- Define numero de parcelas |
	aParc := Condicao(nTotProd,G6R->G6R_CONDPG, ,  )
	If Len(aParc) > 0
		Aadd(aDados, {"condpag", Str( Len(aParc) ) + "X" })	
	Else
		Aadd(aDados, {"condpag", "" })	
	EndIf
	
	Aadd(aDados, {"contrat"			, If(G6R->G6R_DESPPG == '1', "CONTRATADA","CONTRATANTE") })
	Aadd(aDados, {"refeicao"		, If(G6R->G6R_REFEIC,"X","") })
	Aadd(aDados, {"pernoite"		, If(G6R->G6R_PERNOI,"X","") })
	Aadd(aDados, {"estacionamento"	, If(G6R->G6R_ESTACI,"X","") })
	

	Aadd(aDados, {"cidade"			, SM0->M0_CIDCOB })	
	Aadd(aDados, {"disponibilidade"	, If(G6R->G6R_DISPVE <> "1","Sim","Não") } ) 
	
	If !Empty(G6R->G6R_OBSERV)
		Aadd(aDados, {"claususaadicional"	, "DÉCIMA QUINTA: "} )
		Aadd(aDados, {"conteudoclaususaadicional"	, G6R->G6R_OBSERV } )
	Else
		Aadd(aDados, {"claususaadicional"			, "" } )	
		Aadd(aDados, {"conteudoclaususaadicional"	, "" } )	
	Endif	  

	//----------------------------------------------------------+
	//                REALIZA INTEGRAÇÃO COM WORD               |
	//----------------------------------------------------------+		
	
	//-------------------------------------------+
	//³ Criando link de comunicacao com o word   |
	//-------------------------------------------+  
	if !IsBlind()                           
		cWord := OLE_CreateLink()
	EndIf
	
	//-------------------------------------------+
	//³ Exibe ou oculta a janela principal da aplicacao Word                
    //-------------------------------------------+
	OLE_SetProperty( cWord, oleWdVisible, .T. )

	//-------------------------------------------+			
	//Local HandleWord (onde sera criado o arquivo local)
	//-------------------------------------------+
	MontaDir("C:\CONTRATOGTP\")

	//-----------------------------------------------------------------------+
	//Copia do Server para o Remote, eh necessario para que o wordview e o   
	//proprio word possam preparar o arquivo para impressao e ou visualizacao
	//Copia o DOT que esta no ROOTPATH Protheus para o PATH da estacao, por exemplo C:\CONTRATOGTP\
	//-----------------------------------------------------------------------+
	if !IsBlind()		                                               
		CpyS2T( cFileDot, "C:\CONTRATOGTP\", .T. )
	EndIf

	//-------------------------------------------+
    // Cria um novo baseado no modelo.           |
	//-------------------------------------------+
    OLE_NewFile( cWord, "C:\CONTRATOGTP\" + cArqDot )

	//-------------------------------------------+			
	// Deixa a janela do documento visivel ou nao. .T. ou .F. (opcional)     
	//-------------------------------------------+		
	OLE_SetProperty( cWord, oleWdVisible, .T. )

	//-------------------------------------------+	
	// Ativa ou desativa impressao em segundo plano. (opcional)              
	//-------------------------------------------+
	OLE_SetProperty( cWord, oleWdPrintBack, .F. )

	//-----------------------------------------------------------------+	
	// Essa eh a parte mais importante. Gerando variaveis do documento |                                       
	//-----------------------------------------------------------------+
	For nInd := 1 To Len( aDados )
		OLE_SetDocumentVar(cWord, aDados[nInd,1], aDados[nInd,2] )
	Next nInd
	
	OLE_SetDocumentVar(cWord, 'nrVia')
		
	//-------------------------------------------+		
	// Atualizando a exibicao das variaveis do documento                     
	//-------------------------------------------+
	OLE_UpdateFields(cWord)

	Sleep(2000)	// Espera 2 segundos pra dar tempo de imprimir.

	//-------------------------------------------+
	// DEFINE NOME DO DOCUMENTO A SER SALVO      |
	//-------------------------------------------+		
	
	nPCliName := aScan(aDados,{|x| x[1] == "nomecontratante"}) 
		
	cFileDoc := Substr(aDados[nPCliName,2],1,20) + dtos(dDataBase) + Alltrim(cNumProp) + StrTran(Time(),":","")
	
	IncProc(AllTrim(STR0008 + cFileDoc) ) //"Processando contrato: "
		
	If File(cFileDoc)
		FErase(cFileDoc)	
	EndIf

	//-------------------------------------------+
	// SALVA DOCUMENTO WORD		                 |
	//-------------------------------------------+		
	OLE_SaveFile( cWord)

	//-------------------------------------------+	
	// Fecha o documento.                        | 
	//-------------------------------------------+		                           
	OLE_CloseFile( cWord )

	//-------------------------------------------+		
	//- Funcao que fecha o Link com o Word       |
	//-------------------------------------------+		
	OLE_CloseLink( cWord )

	//-- Limpa as variaveis
	cFileDoc := ""
	cFileDot := ""
	cWord	 := ""		
	

EndIf

Return(lRet)

