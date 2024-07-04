#INCLUDE "PROTHEUS.CH"
Static __lMVMCASP := NIL

//---------------------------------------------------------------------------------
/*/{Protheus.doc} Is_MCASP
Retorno do parametro MV_MCASP para habilitar itens de menu referente a MCASP
@author Totvs
@since 28/12/2020
@version P12

/*/
//---------------------------------------------------------------------------------

Function Is_MCASP(lAutomato, lTstAutom)
Local lRet := .F.
Local cStringF  := ""

Default lAutomato := .F.
Default lTstAutom := .F.

//PARAMETRIZACAO CONTIDA NO ARQUIVO GRAVADO NA SYSTEM DENOMINADO MCASP.INI
//SENDO QUE NA LINHA 1 CONTEM A SEGUINTE EXPRESSAO MCASP=1
//SE CONTEUDO DO ARQUIVO ESTIVER VAZIO SERA CONSIDERADO HABILITADO MCASP

// TIPO CARACTER '0' = MENU MCASP DESABILITADO ; '1' - MENU MCASP HABILITADO
//OPTAMOS POR SER CARACTER PQ FUTURO PODE TER ALGUMAS IMPLEMENTACOES DE VARIACOES DE MCASP
If lAutomato

	lRet := lTstAutom

Else

	If __lMVMCASP == NIL
		If File("mcasp.ini")   //verifica se existe o arquivo mcasp.ini 
			cStringF := MEMOREAD("mcasp.ini")
			If Empty(Alltrim(cStringF))  //se conteudo do arquivo estiver vazio retorna true para indicar que eh MCASP
				lRet := .T.
			Else
				//procura palavra mcasp= na string
				If AT("MCASP=", Upper(cStringF)) > 0
					//Quando encontrado somente retorna true se estiver configurado com 1
					If Alltrim(Subs(cStringF,AT("=", Upper(cStringF))+1)) == "1"  
						lRet := .T.
					EndIf
				Else  
					//se nao encontrou tb retorna true para indicar que eh segmento MCASP
					lRet := .T.
				EndIf
			EndIf
		EndIf
		__lMVMCASP := lRet
	Else
		lRet := __lMVMCASP
	EndIf

EndIf

Return(lRet)

//---------------------------------------------------------------------------------
/*/{Protheus.doc} ExecInPco
Retorno Item do Menu SIGAPCO que deve ser habilitado ou nao dependendo do parametro MV_MCASP  referente a MCASP
@author Totvs
@since 28/12/2020
@version P12

/*/
//---------------------------------------------------------------------------------

Function ExecInPco(cItem)
Local lRet := .T.
Local lMCASP := .F.
Local lAutomato := .F.
Local lVarRobo  := .F.

If IsInCallStack("CTBMNU_003") .OR. IsInCallStack("CTBMNU_004") //tratamento para caso de teste - automacao
	lAutomato := .T.
	If Type("lVarAutom") == "U"
		lVarAutom := .F.
	EndIf
	lVarRobo := lVarAutom  //lVarAutom eh variavel private declarada dentro dos casos de teste
EndIf

If lAutomato
   lMCASP := Is_MCASP(lAutomato, lVarRobo)   
Else
   lMCASP := Is_MCASP()
EndIf

	DO CASE

	CASE cItem == "PCOA165"
	   lRet := lMCASP
	
	CASE cItem == "PCOA175"
	   lRet := lMCASP   

	CASE cItem == "PCOA260"
	   lRet := lMCASP   

	CASE cItem == "PCOA265"
	   lRet := lMCASP   

	CASE cItem == "PCOA270"
	   lRet := lMCASP   

	CASE cItem == "PCOA275"
	   lRet := lMCASP   

	CASE cItem == "PCOA280"
	   lRet := lMCASP   

	CASE cItem == "PCOA285"
	   lRet := lMCASP   

	CASE cItem == "PCOA290"
	   lRet := lMCASP   

	CASE cItem == "PCOA295"  //Retirado comentário após solicitação P.O. descida para master fontes MCASP
	   lRet := lMCASP   

	CASE cItem == "PCOA297"
	   lRet := lMCASP   

	CASE cItem == "PCOA298"
	   lRet := lMCASP   

	CASE cItem == "PCOA299"
	   lRet := lMCASP   

	CASE cItem == "PCOA303"
	   lRet := lMCASP   

	CASE cItem == "PCOA304"
	   lRet := lMCASP   

	CASE cItem == "PCOA305"
	   lRet := lMCASP   

	CASE cItem == "PCOA306"
	   lRet := lMCASP   

	CASE cItem == "PCOA307"
	   lRet := lMCASP   

	CASE cItem == "PCOR070"
	   lRet := lMCASP   

	CASE cItem == "PCOR071"
	   lRet := lMCASP   

	CASE cItem == "PCOR072"
	   lRet := lMCASP   

	CASE cItem == "PCOR073"
	   lRet := lMCASP   

	CASE cItem == "PCOR074"
	   lRet := lMCASP   

	CASE cItem == "PCOR075"
	   lRet := lMCASP   

	CASE cItem == "PCOR076"
	   lRet := lMCASP   

	CASE cItem == "PCOR077"
	   lRet := lMCASP   

	CASE cItem == "PCOR078"
	   lRet := lMCASP   

	CASE cItem == "PCOR079"
	   lRet := lMCASP   

	CASE cItem == "PCOR080"
	   lRet := lMCASP   

	CASE cItem == "PCOR081"
	   lRet := lMCASP   

	CASE cItem == "PCOR082"
	   lRet := lMCASP   

	CASE cItem == "PCOR083"
	   lRet := lMCASP   

	CASE cItem == "PCOR084"
	   lRet := lMCASP   

	CASE cItem == "PCOR085"
	   lRet := lMCASP   

	CASE cItem == "PCOR086"
	   lRet := lMCASP
	
	CASE cItem == "PCOR087"
	   lRet := lMCASP   

	CASE cItem == "PCOR088"
	   lRet := lMCASP   

	CASE cItem == "PCOR089"
	   lRet := lMCASP   

	CASE cItem == "PCOR090"
	   lRet := lMCASP   

	CASE cItem == "PCOR091"
	   lRet := lMCASP   

   ENDCASE

Return(lRet)

//---------------------------------------------------------------------------------
/*/{Protheus.doc} ExecInCtb
Retorno Item do Menu SIGACTB que deve ser habilitado ou nao dependendo do parametro MV_MCASP  referente a MCASP
@author Totvs
@since 28/12/2020
@version P12

/*/
//---------------------------------------------------------------------------------

Function ExecInCtb(cItem)
Local lRet := .T.
Local lMCASP := .F.
Local lAutomato := .F.
Local lVarRobo  := .F.

If IsInCallStack("CTBMNU_001") .OR. IsInCallStack("CTBMNU_002")  //tratamento para caso de teste - automacao
	lAutomato := .T.
	If Type("lVarAutom") == "U"
		lVarAutom := .F.
	EndIf
	lVarRobo := lVarAutom  //lVarAutom eh variavel private declarada dentro dos casos de teste
EndIf

If lAutomato
   lMCASP := Is_MCASP(lAutomato, lVarRobo)   
Else
   lMCASP := Is_MCASP()
EndIf

//--Desvio Removido para descida do projeto MCASP para branch master 

   DO CASE

        CASE cItem == "CTBA519"
           lRet := lMCASP

        CASE cItem == "CTBA520"
            lRet := lMCASP

        CASE cItem == "CTBR500P"
            lRet := lMCASP

        CASE cItem == "CTBR505P"
            lRet := lMCASP

        CASE cItem == "CTBR506P"
            lRet := lMCASP

        CASE cItem == "CTBR507P"
            lRet := lMCASP

        CASE cItem == "CTBR508P"
            lRet := lMCASP

        CASE cItem == "CTBR509P"
            lRet := lMCASP

        CASE cItem == "CTBR510P"
            lRet := lMCASP

        CASE cItem == "CTBR511P"
            lRet := lMCASP

        CASE cItem == "CTBR512P"
            lRet := lMCASP

        CASE cItem == "CTBR513P"
            lRet := lMCASP

        CASE cItem == "CTBR514P"
            lRet := lMCASP

        CASE cItem == "CTBR515P"
            lRet := lMCASP

        CASE cItem == "CTBR516P"
            lRet := lMCASP

        CASE cItem == "CTBR517P"
            lRet := lMCASP

        CASE cItem == "CTBR518P"
            lRet := lMCASP

        CASE cItem == "CTBR519P"
            lRet := lMCASP

        CASE cItem == "CTBR530P"
            lRet := lMCASP

        CASE cItem == "CTBR560P"
            lRet := lMCASP

   ENDCASE

Return(lRet)