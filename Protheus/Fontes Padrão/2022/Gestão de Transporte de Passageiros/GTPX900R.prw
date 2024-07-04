#INCLUDE 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "DBTREE.CH"
#INCLUDE "MSOLE.CH"
#INCLUDE "GTPX900R.ch"

//-----------------------------------------------------------------------
/*/{Protheus.doc} GTPX900R
Imprime o contrato de fretamento contínuo
@type function
@author gtp
@since 24/05/2021
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTPX900R()
Local lRet				:= .T.
Local lConfSimples		:= GY0->GY0_STATUS $ '1|3|4|5|7'

Processa( {|| GerDocContr(lConfSimples) },, OemToAnsi(STR0001) ) // "Gerando contrato de fretamento..."

Return(lRet)

/*/{Protheus.doc} GerDocContr
Gera contrato de Fretamento Contínuo conforme modelo word (.Dot) definido via
parametro do sistema. 
@type function
@author gtp
@since 25/05/2021
@version 1.0
@param lConfSimples, ${param_type}, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GerDocContr(lConfSimples)
Local cNumero		:= ''
Local cPath			:= Alltrim(SuperGetMv( "MV_DIRDOC", .F., "\WORD\" ) )
Local cArqDot		:= Alltrim(SuperGetMv( "MV_MODFRT", .F., "FRETAMENTOGTP.DOT" )  )
Local cWord			:= ""
Local cFileDot		:= ""
Local cFileDoc		:= ""
Local aDados  		:= {}
Local nInd    		:= 0
Local nPCliName		:= 0
Local nRet      	:= 0
Local cCpfCnpj		:= ""
Local lRet			:= .T.
Local aRet      	:= {}
Local aParamBox		:= {}
Local nNumCop   	:= GTPGetRules('NUMCOPIAS')
Local oMdl900		:= FwLoadModel('GTPA900')
Local cVigencia		:= ''
Local cPreConv		:= ''
Local cPreExtra		:= ''
Local lGtpImpCon	:= ExistBlock("GTPIMPCON")
Local cChaveGY0		:= ''

Default lConfSimples	:= .T.

oMdl900:SetOperation(MODEL_OPERATION_VIEW)
oMdl900:Activate()

If lGtpImpCon // Ponto de Entrada para customização da impressão do contrato
	cChaveGY0 := xFilial('GY0')+GY0->GY0_NUMERO+GY0->GY0_REVISA
	ExecBlock("GTPIMPCON", .f., .f., cChaveGY0)
	Return
Endif

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
		MsgStop(STR0002, STR0003) //"Arquivo não encontrado", "Verifique os parâmetros MV_DIRDOC e MV_MODFRT"
		lRet := .F.
	Else
		MsgStop(STR0002, STR0003) //"Arquivo não encontrado", "Verifique os parâmetros MV_DIRDOC e MV_MODFRT"
		lRet := .F.
	EndIf
	Return
Endif

// Valida se a instância, com a aplicação Microsoft Word, encontra-se válida.
If lRet .And. cWord == "-1" 
	OLE_CloseFile( cWord )
	OLE_CloseLink( cWord )
	MsgStop(STR0004, STR0005) //"Erro", "Não foi possível estabelecer comunicação com o Microsoft Word"
	lRet := .F.
Else	
	
	ProcRegua( 3 )
			
	SA1->(dbSetOrder(1))
	SA1->(dbSeek(xFilial('SA1')+oMdl900:GetValue('GY0MASTER', 'GY0_CLIENT')+;
			oMdl900:GetValue('GY0MASTER', 'GY0_LOJACL')))

	// Contrato apenas p/ conferencia (Antes da Confirmação da Proposta)
	If lConfSimples
		Aadd(aDados, {STR0006, STR0007}) // "Conferência", "SIMPLES CONFERÊNCIA"
	Else
		Aadd(aDados, {STR0006, ""}) // "Conferência"
	EndIf

	cNumero := oMdl900:GetValue('GY0MASTER', 'GY0_NUMERO')

	cCpfCnpj := Transform(SA1->A1_CGC, If(Len(Alltrim(SA1->A1_CGC)) == 14, "@R 99.999.999/9999-99", "@R 999.999.999-99"))

	cVigencia := AllTrim(Str(oMdl900:GetValue('GY0MASTER', 'GY0_VIGE'))) + ' ' +;
					GTPXCBOX('GY0_UNVIGE', Val(oMdl900:GetValue('GY0MASTER', 'GY0_UNVIGE')))

	cPreConv  := GTPXCBOX('GYD_PRECON', Val(oMdl900:GetValue('GYDDETAIL', 'GYD_PRECON')))
	cPreExtra := GTPXCBOX('GYD_PREEXT', Val(oMdl900:GetValue('GYDDETAIL', 'GYD_PREEXT')))

	// Dados Gerais do Contrato.
	Aadd(aDados, {"nrcontrato"			, oMdl900:GetValue('GY0MASTER', 'GY0_NUMERO')})
	Aadd(aDados, {"dDtPrint"			, dDataBase})
	Aadd(aDados, {"cHrPrint"			, Time()})
	Aadd(aDados, {"nomecontratante"		, SA1->A1_NOME})
	Aadd(aDados, {"CPFCNPJContrate"		, cCpfCnpj })
	Aadd(aDados, {"IEContratante"		, SA1->A1_INSCR})
	Aadd(aDados, {"Endcontratante"		, SA1->A1_END})
	Aadd(aDados, {"Bairrocontratante"	, SA1->A1_BAIRRO})
	Aadd(aDados, {"Cidadecontratante"	, SA1->A1_MUN})
	Aadd(aDados, {"UFcontratante"		, SA1->A1_EST})   
	Aadd(aDados, {"Telcontratante"		, SA1->A1_TEL})
	Aadd(aDados, {"RGcontratante"		, SA1->A1_RG})
	Aadd(aDados, {"nomecontratada"		, SM0->M0_NOMECOM })  
	Aadd(aDados, {"Endcontratada"		, SM0->M0_ENDCOB })
	Aadd(aDados, {"Bairrocontratada"	, SM0->M0_BAIRCOB })
	Aadd(aDados, {"Cidadecontratada"	, SM0->M0_CIDCOB })
	Aadd(aDados, {"UFcontratada"		, SM0->M0_ESTCOB })
	Aadd(aDados, {"CNPJcontratada"		, Transform(SM0->M0_CGC, "@R 99.999.999/9999-99" ) })
	Aadd(aDados, {"IEcontratada"		, SM0->M0_INSC })

	Aadd(aDados, {"prazoContrato"		, cVigencia})
	Aadd(aDados, {"dataInicioVigencia"	, oMdl900:GetValue('GY0MASTER', 'GY0_DTINIC')})
	Aadd(aDados, {"valor"				, oMdl900:GetValue('GYDDETAIL', 'GYD_VLRTOT', 1)})
	Aadd(aDados, {"precoConvencional"	, cPreConv})
	Aadd(aDados, {"valorExtra"			, oMdl900:GetValue('GYDDETAIL', 'GYD_VLREXT', 1)})
	Aadd(aDados, {"precoExtra"			, cPreExtra})
	Aadd(aDados, {"cidade"				, SM0->M0_CIDCOB })	
	
	//----------------------------------------------------------+
	//                REALIZA INTEGRAÇÃO COM WORD               |
	//----------------------------------------------------------+		
	
	//-------------------------------------------+
	//³ Criando link de comunicacao com o word   |
	//-------------------------------------------+                             
	cWord := OLE_CreateLink()
	
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
	CpyS2T( cFileDot, "C:\CONTRATOGTP\", .T. )

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
	OLE_SetProperty( cWord, oleWdPrintBack, .T. )

	//-----------------------------------------------------------------+	
	// Essa eh a parte mais importante. Gerando variaveis do documento |                                       
	//-----------------------------------------------------------------+
	For nInd := 1 To Len( aDados )
		OLE_SetDocumentVar(cWord, aDados[nInd,1], aDados[nInd,2] )
	Next nInd
	
	//----------------------------------------------+
	// Informe a quantidade de copias para ipressão |
	//----------------------------------------------+
	aAdd(aParamBox, {1, STR0008, nNumCop, "999",, "",, 20, .F.}) //"Informe a quantidade de cópias"

	ParamBox(aParamBox, STR0009, @aRet) //"Impressão do contrato de fretamento contínuo"

    If(Len(aRet) > 0)
		For nInd := 1 To aRet[1]
			OLE_SetDocumentVar(cWord, 'nrVia', cValToChar(nInd) )
				
			//-------------------------------------------+		
			// Atualizando a exibicao das variaveis do documento                     
			//-------------------------------------------+
			OLE_UpdateFields(cWord)

			//-------------------------------------------+	
			//Imprime o documento.
			//-------------------------------------------+
			OLE_PrintFile( cWord, "ALL",,, 1 )
			Sleep(2000)	// Espera 2 segundos pra dar tempo de imprimir.

			//-------------------------------------------+
			// DEFINE NOME DO DOCUMENTO A SER SALVO      |
			//-------------------------------------------+		
			
			nPCliName := aScan(aDados,{|x| x[1] == "nomecontratante"}) 
				
			cFileDoc := Substr(aDados[nPCliName,2],1,20) + dtos(dDataBase) + Alltrim(cNumero) + StrTran(Time(),":","")
			
			IncProc(AllTrim(STR0010 + cFileDoc) ) //"Processando contrato: "
				
			If File(cFileDoc)
				FErase(cFileDoc)	
			EndIf
		
			//-------------------------------------------+
			// SALVA DOCUMENTO WORD		                 |
			//-------------------------------------------+		
			OLE_SaveAsFile( cWord, AllTrim( "C:\CONTRATOGTP\" + cFileDoc ) )
		Next 	
	EndIf			

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

If oMdl900:IsActive()
	oMdl900:DeActivate()
	oMdl900:Destroy()
Endif

Return(lRet)

