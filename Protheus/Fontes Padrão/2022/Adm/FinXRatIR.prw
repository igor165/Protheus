#INCLUDE "PROTHEUS.CH"

//Dummy Function
Function FinXRatIR()
Return

/*/{Protheus.doc} FinBCRateioIR
	Classe responsavel pelo calculo do rateio de IRRF progressivo
	com base na tabela FKJ
	@type  Class
	@author Vitor/Karen
	@since 01/04/2020
	@version 1.0
	@see https://tdn.totvs.com/x/v8l-I
/*/
Class FinBCRateioIR From LongClassName

	//Propriedades 
    Data nBaseIr    as Numeric
    Data aRatIRF    as Array
    Data lBaixa     as Logical
    Data cFilOrig   as Character
    Data cFornece   as Character
    Data cLoja      as Character
	Data cTipoFor   as Character
    Data nValorAces as Numeric
    Data cIdDoc     as Character
	Data lMinimoIR  as Logical
	Data lPropComp  as Logical
	Data nTitImp	as Numeric

	// Métodos básicos
    Method New() CONSTRUCTOR
	Method Clean()
	
	// Setters e Getters
	Method SetIRBaixa(lIrBaixa)
    Method SetBaseIR(nBaseIrrf)
    Method SetFilOrig(cFilOrig)
    Method SetForLoja(cFornecedor,cLoja)
    Method SetValAces(nValAcessorios)
	Method SetIrRetido(nRetIr,nPosicao)
    Method GetIdDoc(cChave)
	Method GetIRRetido(cIdOrig)

	// Criação
    Method StructFKJ()

	// Processamento
	Method CalcRatIr()

EndClass

/*/{Protheus.doc} New()
	Metodo construtor da classe, responsavel pela inicialização
	das propriedades
	@type  Method
	@author Vitor/Karen
	@since 01/04/2020
	@version 1.0
	@see (links_or_references)
/*/
Method new() Class FinBCRateioIR
	::nBaseIr   	:= 0
    ::aRatIRF   	:= {} 
    ::lBaixa    	:= .F.  
    ::cFilOrig  	:= cFilAnt
    ::cFornece  	:= ""
    ::cLoja     	:= ""
	::cTipoFor		:= ""
    ::nValorAces	:= 0
	::lMinimoIR 	:= .F. 
	::lPropComp		:= .F.
	::nTitImp		:= 0
Return NIL

/*/{Protheus.doc} SetBaseIR()
	Recebe a base de IRRF que sera tratada no rateio
	@type  Method
	@author Vitor/Karen
	@since 01/04/2020
	@param nBaseIrrf, Numeric, Base do IR que sera considerada 
	@version 1.0
	@see (links_or_references)
/*/
Method SetBaseIR(nBaseIrrf) Class FinBCRateioIR
    ::nBaseIr   := nBaseIrrf
Return NIL

/*/{Protheus.doc} SetFilOrig()
	Recebe a filial de origem (FILORIG)
	@type  Method
	@author Vitor/Karen
	@since 01/04/2020
	@param cFilOrig, Character, Filial de origem - _FILORIG 
	@version 1.0
	@see (links_or_references)
/*/
Method SetFilOrig(cFilOrig) Class FinBCRateioIR
    ::cFilOrig  := PadR(cFilOrig,FWSizeFilial())
Return NIL

/*/{Protheus.doc} SetIrRetido()
	Recebe o valor de IR PF ja retido
	@type  Method
	@author Vitor/Karen
	@since 01/04/2020
	@param cFilOrig, Character, Filial de origem - _FILORIG 
	@version 1.0
	@see (links_or_references)
/*/
Method SetIrRetido(nRetIr, nPosicao) Class FinBCRateioIR
    ::aRatIRF[nPosicao][7] += nRetIr
Return NIL

/*/{Protheus.doc} SetForLoja()
	Recebe o codigo do fornecedor e a loja que serão utilizados
	na construção do rateio
	@type  Method
	@author Vitor/Karen
	@since 01/04/2020
	@param cFornecedor, Character, Codigo do fornecedor (A2_COD)
	@param cLoja, Character, Loja do fornecedor (A2_LOJA)
	@version 1.0
	@see (links_or_references)
/*/
Method SetForLoja(cFornecedor, cLoja) Class FinBCRateioIR
    ::cFornece  := cFornecedor
    ::cLoja     := cLoja

	//Com o fornecedor e loja preenchido sera montado a estrutura do rateio
	If !Empty(::cFornece) .and. !Empty(::cLoja)
		Self:StructFKJ()
	EndIf	
Return NIL

/*/{Protheus.doc} SetValAces()
	Recebe os valores acessorios do titulo
	(Juros,Multa,Desconto,Acrescimo,Decrescimo,Valores acessorios (VA))
	@type  Method
	@author Vitor/Karen
	@since 01/04/2020
	@param nValAcessorios, Numeric
	@version 1.0
	@see (links_or_references)
/*/
Method SetValAces(nValAcessorios) Class FinBCRateioIR
    ::nValorAces:= nValAcessorios
Return NIL

/*/{Protheus.doc} SetIRBaixa()
	Define se o caculo do IR é na baixa
	@type  Method
	@author Vitor/Karen
	@since 01/04/2020
	@param lIrBaixa, Logico, Define se o calculo ira acontecer pela baixa
	@version 1.0
	@see (links_or_references)
/*/
Method SetIRBaixa(lIRBaixa) Class FinBCRateioIR
    ::lBaixa := lIRBaixa
Return NIL

/*/{Protheus.doc} GetIdDoc()
	Retorna o FK7_IDDOC do titulo 
	@type  Method
	@author Vitor/Karen
	@since 01/04/2020
	@param cChave, Caractere, Chave do titulo no formato FK7_CHAVE
	@version 1.0
	@see (links_or_references)
/*/
Method GetIdDoc(cChave) Class FinBCRateioIR
    ::cIdDoc    := FINGRVFK7('SE2', cChave)
Return self:cIdDoc

/*/{Protheus.doc} GetIRRetido()
	Função para verificar o Ir progressivo retido por CPF
	@type  Method
	@author Vitor/Karen
	@since 01/04/2020
	@version 1.0
	@example
	@see (links_or_references)
/*/
Method GetIRRetido(cIdOrig,cTable) Class FinBCRateioIR
	Local nPos 		As Numeric
	Local aArea		As Array
	Local aAreaFK3	As Array
	Local aAreaFK4	As Array 
	Local cAglImPJ  As Character

	Default cTable	:= Iif(::lBaixa, "FK2", "SE2")

	nPos 		:= 0
	aArea		:= GetArea()
	aAreaFK3	:= FK3->(GetArea())
	aAreaFK4	:= FK4->(GetArea())
	cAglImPJ	:= SuperGetMv("MV_AGLIMPJ",.T.,"1")
	

	FK4->(DbSetOrder(1))
	FK3->(DbSetOrder(2))

	If FK3->(DbSeek(xFiliaL("FK3",::cFilOrig)+cTable+cIdOrig+"IRF"))
		While FK3->(!EOF()) .and. FK3->FK3_IDORIG == cIDOrig
			If FK4->(DbSeek(xFilial("FK4",::cFilOrig)+FK3->FK3_IDRET))
				nPos := Ascan(::aRatIRF,{ |x| AllTrim(x[3]) == AllTrim(FK4->FK4_CGC) } )
				If nPos > 0
					Self:SetIrRetido(FK4->FK4_VALOR,nPos)  
					If cAglImPJ != '1' 
						::aRatIRF[nPos][9] := Iif(FK4->FK4_BASIMP > ::aRatIRF[nPos][9], FK4->FK4_BASIMP, ::aRatIRF[nPos][9])
					Endif						
				EndIf	
			Endif
			FK3->(DbSkip())
		EndDo		
	Endif

	RestArea(aAreaFK3)
	RestArea(aAreaFK4)
	RestArea(aArea)
Return NIL

/*/{Protheus.doc} StructFKJ()
	Monta estrutura de Rateio IR Progressivo p/ CPF
	@type  Method
	@author Vitor/Karen
	@since 01/04/2020
	@version 1.0
	@example
		Estrutura do aRatIrf
		[1]  = Codigo do Fornecedor
		[2]  = Loja do Fornecedor
		[3]  = CPF do Fornecedor
		[4]  = Percentual de Rateio
		[5]  = Base do Imposto
		[6]  = Imposto Calculado
		[7]  = Imposto Retido
		[8]  = Nome do Fornecedor
		[9]  = Base do imposto quando o MV_AGLIMPJ != 1 

	@see (links_or_references)
/*/
Method StructFKJ() Class FinBCRateioIR			
	Local aArea			As Array
	Local aAreaSA2		As Array
	Local aAreaFKJ		As Array
	Local cFilFKJ		As Character

	::aRatIRF	:= Array(0)

	//Inicialização das variaveis
	aArea		:= GetArea()
	aAreaSA2	:= SA2->( GetArea() )
	aAreaFKJ	:= {}
	cFilFKJ		:= ""
	
	// Busca Fornecedor do Título
	SA2->( DbSetOrder(1) )
	If !Empty(::cFornece+::cLoja) .And. SA2->( DbSeek(xFilial("SA2",::cFilOrig) + ::cFornece + ::cLoja) ) 

		::cTipoFor := SA2->A2_TIPO
		
		If SA2->A2_MINIRF == "2"
			::lMinimoIR := .T.
		Endif

		// Verifica se o fornecedor trata o rateio IR Progressivo p/ CPF
		If SA2->A2_TIPO == 'F' .OR. ( SA2->A2_TIPO == 'J' .AND. SA2->A2_IRPROG == '1' .And. !Empty(SA2->A2_CPFIRP) )

			aAreaFKJ := FKJ->( GetArea() )

			cFilFKJ := xFilial("FKJ", ::cFilOrig)
			// Procura Rateios p/ CPF - TABELA FKJ
			FKJ->( DbSetOrder(1) ) // FKJ_FILIAL, FKJ_COD, FKJ_LOJA, FKJ_CPF
			If FKJ->( DbSeek( cFilFKJ + ::cFornece + ::cLoja ) )

				While FKJ->(!Eof()) .And. FKJ->(FKJ_FILIAL+FKJ_COD+FKJ_LOJA) ==  cFilFKJ + ::cFornece + ::cLoja  
					aAdd(::aRatIRF, { FKJ->FKJ_COD, FKJ->FKJ_LOJA, FKJ->FKJ_CPF, FKJ->FKJ_PERCEN, 0, 0, 0, FKJ->FKJ_NOME ,0 }) 
					FKJ->( DbSkip() )
				EndDo 

			Else
				aAdd(::aRatIRF, { SA2->A2_COD, SA2->A2_LOJA, IIF(SA2->A2_TIPO == 'F',SA2->A2_CGC,SA2->A2_CPFIRP), 100, 0, 0, 0, SA2->A2_NOME, 0 })
			EndIf
			
			RestArea(aAreaFKJ)
			FwFreeArray(aAreaFKJ)
		EndIf

	EndIf

	Restarea(aAreaSA2)
	RestArea(aArea)
	FwFreeArray(aAreaSA2)
	FwFreeArray(aArea)
Return NIL 

/*/{Protheus.doc} CalcRatIr()
	Metodo responsvel pelo calculo do rateio, que sera
	armazenado na variavel aRatIRF
	@type  Method
	@author Vitor/Karen
	@since 01/04/2020
	@version 1.0
	@example
	@see (links_or_references)
/*/
Method CalcRatIr(nBaseTit) Class FinBCRateioIR
	Local nX 			As Numeric
	Local lJurMulDes	As Logical
	Local nValor 		As Numeric
	Local cAcmIrrf 		As Character
	Local lIrfRetAnt 	As Logical
	Local nVlRetir		As Numeric

	Default nBaseTit	:= 0

	nX 			:= 0 
	lJurMulDes 	:= SuperGetMv("MV_IMPBAIX",.t.,"2") == "1"
	nValor 		:= 0
	cAcmIrrf 	:= SuperGetMv("MV_ACMIRRF",.T.,"1")
	lIrfRetAnt 	:= .F.
	nVlRetIR 	:= SuperGetMv("MV_VLRETIR",.T.,0)
	::nTitImp   := 0 
	
	// Rateio p/ CPF
		For nX := 1 To Len(::aRatIRF)
			
			/*	[1]  = Codigo do Fornecedor
				[2]  = Loja do Fornecedor
				[3]  = CPF do Fornecedor
				[4]  = Percentual de Rateio
				[5]  = Base do Imposto
				[6]  = Imposto Calculado
				[7]  = Imposto Retido
				[8]  = Nome do CPF ou Fornecedor
				[9]  = Base do imposto quando o MV_AGLIMPJ != 1 

			// Aplica rateio do IRRF */

			If ::aRatIRF[nX][9] > 0 .AND. nBaseTit > 0
				::nBaseIr := nBaseTit + ::aRatIRF[nX][9]	
			Endif

			If ::lBaixa .and. lJurMulDes
				::aRatIRF[nX][5] := (::nBaseIr+::nValorAces)*( ::aRatIRF[nX][4]/100 )
			Else
				::aRatIRF[nX][5] := ::nBaseIr * ( ::aRatIRF[nX][4]/100 )
			Endif

			::aRatIRF[nX][6] := fa050TabIR(::aRatIRF[nX][5],.F.)
			::aRatIRF[nX][7] := If( Empty(::aRatIRF[nX][7]), 0, ::aRatIRF[nX][7])

			nValor	+= Round(NoRound(::aRatIRF[nX][6],3),2)

			//Diminuo do valor calculado, o IRRF já retido
			If cAcmIrrf <> "2" .OR. ::cTipoFor == 'F' //Não acumular os valores do IRRF  -> PF sempre acumular
				::aRatIRF[nX][6] -= Iif(::lBaixa .and. ::lPropComp,0,::aRatIRF[nX][7])
				nValor -= Iif(::lBaixa .and. ::lPropComp,0,::aRatIRF[nX][7])
			Endif

			//Controle de retencao anterior no mesmo periodo
			lIrfRetAnt := IIF(::aRatIRF[nX][7] > nVlRetir, .T., .F.)

			// Verifica se o fornecedor trata o valor minimo de retencao.- FINANCEIRO
			If (::lMinimoIR .And. (::aRatIRF[nX][6] <= nVlRetir .and. !lIrfRetAnt)) .OR. ::aRatIRF[nX][6] < 0
				nValor -= ::aRatIRF[nX][6]
				::aRatIRF[nX][6] := 0
			Endif

			::nTitImp += ::aRatIRF[nX][6]
		Next nX

Return nValor

/*/{Protheus.doc} Clean()
	Metodo responsavel pela limpeza das propriedades 
	@type  Method
	@author Vitor/Karen
	@since 01/04/2020
	@version 1.0
	@example
	@see (links_or_references)
/*/
Method Clean() Class FinBCRateioIR
	::nBaseIr   	:= 0 
    ::lBaixa    	:= .F.  
    ::cFilOrig  	:= cFilAnt
    ::cFornece  	:= ""
    ::cLoja     	:= ""
	::cTipoFor		:= ""
    ::nValorAces	:= 0
	::lMinimoIR 	:= .F.
	::lPropComp		:= .F.
	::nTitImp		:= 0
	
	FwFreeArray(::aRatIRF)
	::aRatIRF		:= {}
Return NIL
