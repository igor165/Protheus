#include 'protheus.ch'

//amarracao por falha na geracao do ptm
//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} CS440ManJob

Fun��o respons�vel pela funcionalidade multi-thread para compor os saldo do bloco k300 das n empresas
do conglomerado.

Vale ressaltar que a composi��o do saldo � efetuada atrav�s da funcionalidade CtGerPlan(..). Para cada empresa 
a ser processada, uma thread ser� aberta para processar em paralelo.

@params:
    oModelA:	Objeto. Inst�ncia da classe FwFormModel(). Modelo CTBS440A
	cIDBlK:		Caractere. C�digo do bloco K
	cCodCta:	Caractere. C�digo da conta cont�bil que ser� processada para carregar o saldo dentro do per�odo
	cMoeda:		Caractere. C�digo da moeda cont�bil.
	cTpSald:	Caractere. C�digo do tipo de saldo
	dDataLP:	Data. Data de Lucros e Perdas
	dDataIni:	Data. Data inicial do per�odo de apura��o do saldo da conta cont�bil
	dDataFim:	Data. Data final do per�odo de apura��o do saldo da conta cont�bil
	lImpAntLP:	L�igico. .t. efetua an�lise de lucros e perdas para a composi��o do saldo da conta cont�bil
	   
@return: 
	nSaldo:		Num�rico. Saldo retornado pela CtGerPlan(..) das n Contas Cont�beis por empresa do conglomerado (bloco K210)
@sample:
	nSaldo := CS440ManJob(oModelA,cIDBlK,cCodCta,cMoeda,cTpSald,dDataLP,dDataIni,dDataFim,lImpAntLP)
@author Fernando Radu Muscalu

@since 13/03/2019
@version 1.0
*/
//------------------------------------------------------------------------------------------------------
Function CS440ManJob(oModelA,cIDBlK,cCodCta,cMoeda,cTpSald,dDataLP,dDataIni,dDataFim,lImpAntLP)

Local nX        := 0
Local nP        := 0
Local nSaldo    := 0
Local nSldGrp   := 0

Local cEmpBkp   := ""
Local cFilLanc  := ""
Local cError    := ""

Local aEmpresas := {}
Local aContas   := {}

Local oModelCQU
Local oModelCQV

/*
	MAPA de aEmpresas

		aEmpresas:	Array. Contem os dados das empresas que ser�o processadas
			aEmpresas[n,1]:	Caractere. C�digo da Empresa
			aEmpresas[n,2]: Array. Dados da filial e contas cont�beis pertecente a empresa do elemento [1] deste array
				aEmpresas[n,2,x,1]: 	Caractere. Filial da conta cont�bil	
				aEmpresas[n,2,x,2]: 	Caractere. C�digo da conta cont�bil	

	MAPA de aContas
		aContas: Array. POssui dados de filial e c�digo de conta
			aContas[n,1]: 	Caractere. Filial da conta cont�bil	
			aContas[n,2]: 	Caractere. C�digo da conta cont�bil	

*/
If ( oModelA:IsActive() )
    
    oModelCQU 	:= oModelA:GetModel("CQUMASTER")
    oModelCQV 	:= oModelA:GetModel("CQVDETAIL")
    cEmpBkp		:= cEmpAnt
    
    //Carrega o Saldo da conta cadastrada do bloco K200
	nSaldo := CTBS440Sld(cIDBlK,oModelCQU:GetValue("CQU_CODCTA"),cMoeda,cTpSald,dDataLP,Nil,.f.,dDataIni,dDataFim,lImpAntLP)
   	
	   //Possui empresas para carregar saldo ? (bloco K210) 
	If ( oModelCQV:Length() > 1 .Or. !Empty(oModelCQV:GetValue("CQV_IDBLK",1)) )
   
	   //Efetua a separa��o das empresas e contas das demais empresas do conglomerado (bloco K210) 
	    For nX := 1 to oModelCQV:Length()
	        
	        nP := aScan(aEmpresas, {|x| Alltrim(Upper(x[1])) == Alltrim(Upper(oModelCQV:GetValue("CQV_XGRP",nX)))})
	
	        If ( nP == 0 ) //cEmpBkp <> oModelCQV:GetValue("CQV_XGRP",nX) .And. nP == 0 
	            
	            aAdd(aEmpresas,{oModelCQV:GetValue("CQV_XGRP",nX),aClone(aContas)})
	            nP := Len(aEmpresas)
	            aContas := {}
	            
	        EndIf    
	        
	        cFilLanc := oModelCQV:GetValue("CQV_XEMP",nX) + oModelCQV:GetValue("CQV_XUNEG",nX) + oModelCQV:GetValue("CQV_XFIL",nX)
	
	        //Para n�o usar a mesma conta para a mesma empresa do bloco k200 (C�digo do Grupo de empresas e filial tem de ser diferente se a conta � a mesma)
	        If ( Alltrim(cEmpAnt+cFilAnt) <> Alltrim(oModelCQV:GetValue("CQV_GRUFIL",nX)) .Or. oModelCQV:GetValue("CQV_CTAEMP",nX) <> oModelCQU:GetValue("CQU_CODCTA") )
	        	aAdd(aContas,{cFilLanc,oModelCQV:GetValue("CQV_CTAEMP",nX)})
	        EndIf
	
	        If ( nP > 0 )
	           aEmpresas[nP,2] := aClone(aContas)
	        EndIf
	
	        cEmpBkp := oModelCQV:GetValue("CQV_XGRP",nX)
	
	    Next nX
	
    EndIf

	//efetua o processamento dos saldos de cada conta de cada empresa
	If ( Len(aEmpresas) > 0 )
		//RETIRADO TRATAMENTO MULTITHREAD POIS INICIALIZACAO AMBIENTE MUITO LENTO
		VarSetUID("CTBS440B_VAR", .T.)

		For nX := 1 to Len(aEmpresas)
			//Chamando diretamente a funcao que era anteriormente chamado por job em multithread
			//Retirado a instru��o de chamar por job pois apresentou se muito lento a inicializacao de ambiente
			CT440BJob(aEmpresas[nX,1],aEmpresas[nX,2],cIDBlK,cMoeda,cTpSald,dDataLP,dDataIni,dDataFim,lImpAntLP) 
		Next nX
						
		If !Empty(cError) //tratava quando era por multithread e uma das threads caiu por erro
			CS440AddLog(oModelCQU:GetValue("CQU_CODCTA"), Alltrim(cError) )
		Else
			//Recupera-se os saldos das empresas do bloco k210 que foram alocadas em vari�veis globais	
			For nX := 1 to Len(aEmpresas)
				
				If ( VarGetX( "CTBS440B_VAR","SLD_GERPLAN"+aEmpresas[nX,1], @nSldGrp ) )				
					nSaldo += nSldGrp				
				Endif
		
			Next nX    
			
		Endif 

		//limpa o espa�o alocado para as vari�veis globais do processamento multi-thread
		VarClean("CTBS440B_VAR")

	EndIf
    
EndIf

Return(nSaldo)


//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} CT440BJob

Fun��o respons�vel pela execu��o na thread aberta, do processamento da CtGerPlan(..).

@params:
    cEmp:		Caractere. C�digo da empresa que ser� montado o ambiente para a exeu��o da thread
	aCtaEmp:	Array. Matriz com os dados de filial e conta.
		aCtaEmp[n,1]: Caractere: c�digo da filial
		aCtaEnp[n,2]: Caractere: c�digo da conta cont�bil
	cIDBlK:		Caractere. C�digo do bloco K
	cCodCta:	Caractere. C�digo da conta cont�bil que ser� processada para carregar o saldo dentro do per�odo
	cMoeda:		Caractere. C�digo da moeda cont�bil.
	cTpSald:	Caractere. C�digo do tipo de saldo
	dDataLP:	Data. Data de Lucros e Perdas
	dDataIni:	Data. Data inicial do per�odo de apura��o do saldo da conta cont�bil
	dDataFim:	Data. Data final do per�odo de apura��o do saldo da conta cont�bil
	lImpAntLP:	L�igico. .t. efetua an�lise de lucros e perdas para a composi��o do saldo da conta cont�bil
	   
@return: 
	nSaldo:		Num�rico. Saldo retornado pela CtGerPlan(..) das n Contas Cont�beis por empresa do conglomerado (bloco K210)
@sample:
	nSaldo := CS440ManJob(oModelA,cIDBlK,cCodCta,cMoeda,cTpSald,dDataLP,dDataIni,dDataFim,lImpAntLP)
@author Fernando Radu Muscalu

@since 13/03/2019
@version 1.0
*/
//------------------------------------------------------------------------------------------------------
Function CT440BJob(cEmp,aCtaEmp,cIDBlK,cMoeda,cTpSald,dDataLP,dDataIni,dDataFim,lImpAntLP)

Local cFilBkp   := ""

Local nSaldo    := 0
Local nSldGrp   := 0
Local nI        := 0

Local lClearEnv := .f.

Local aInfFil := {}  //este array deve ser passado vazio e retornara preenchido
					 //com 3 elementos
					 // Elemento 1 = Empresa logada
					 // Elemento 2 = Filial Logada
					 // Elemento 3 = alias temporario do sx2 atual

Local cEmprAux := Space(2)
Local cFilAux := Space(Len(CT2->CT2_FILIAL))

If ( Len(aCtaEmp) > 0 )

	//Verifica se necessita preparar um ambiente novo ou se somente atualiza a filial corrente
    If ( Type('cEmpAnt') == "U" .Or. cEmpAnt <> cEmp )

		//retirado tratamento multithread pois inicializar ambiente tornou-se lento - efetuado tratamento com SX2
		cEmprAux := cEmp
		cFilAux := aCtaEmp[1,1]		
		//TRATAMENTO PARA ABRIR SX2 de outro grupo empresa
		//troca SX2 Atual para o da Empresa enviada 2o. parametro - manipula cEmpAnt e cFilAnt
		Ctb440TSX2(aInfFil, cEmprAux, cFilAux)

        lClearEnv := .t.

        cFilBkp := cFilAnt

    ElseIf ( cFilAnt <> aCtaEmp[1,1] )
        cFilBkp := cFilAnt
        cFilAnt := aCtaEmp[1,1]
    EndIf
        
    For nI := 1 to Len(aCtaEmp)

		If ( cFilAnt <> aCtaEmp[nI,1] )
            cFilAnt := aCtaEmp[nI,1]
        EndIf	

        nSldGrp += CTBS440Sld(cIDBlK,aCtaEmp[nI,2],cMoeda,cTpSald,dDataLP,nil,.f.,dDataIni,dDataFim,lImpAntLP)

    Next nI
	
	//Prepara a vari�vel global para transa��o que a atualizar� de acordo com o saldo retornado pela fun��o CTBS440Sld(..)
    If ( VarBeginT("CTBS440B_VAR","SLD_GERPLAN"+cEmp) )

        //Capta valor atualizado da vari�vel global SLD_GERPLAN+[Codigo EMpresa]
        VarGetXD("CTBS440B_VAR","SLD_GERPLAN"+cEmp, @nSaldo )

		nSaldo += nSldGrp

		//Atualiza a vari�vel global com o valor atulizado do saldo
        VarSetXD("CTBS440B_VAR","SLD_GERPLAN"+cEmp, @nSaldo )

		//Finaliza a transa��o
        VarEndT("CTBS440B_VAR","SLD_GERPLAN"+cEmp)

    EndIf 

    cFilAnt := cFilBkp

	If ( lClearEnv )

    	//retirado tratamento multithread RpcClearEnv() pois se torna muito lento 
		//TRATAMENTO PARA RETORNAR SX2 DA EMPRESA ORIGEM
		//Retorna sx2 da empresa logada e retorna cEmpAnt e cFilAnt
		Ctb440RSX2(aInfFil)

	EndIf  

EndIf    

Return()

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} Ctb440TSX2

Troca SX2 para o da empresa passada como parametro e seta variaveis cEmpAnt com empresa passada 
e cFilAnt com a filial passada no parametro
Para poder recuperar o SX2 ORIGINAL deve se passar um array vazio no primeiro parametro que 
armazenara conforme segue:
 alias temporario do SX2 na primeira posicao 
 empresa original na segunda posicao
 filial original na terceira posicao

@params:
	aInfFil: array vazio para armazenar alias temporario SX2 - Empresa Original - Filial Original
	cEmprAux: Grupo Empresa a ser aberto o SX2 e setado a variavel cEmpAnt
	cFilAux: Filial a ser setado a variavel cFilAnt
@return: 
	lRet:	L�gico. .t. Valido; .f. N�o valido
@sample:
	
@author Paulo Carnelossi

@since 29/10/2019
@version 1.0
*/
//------------------------------------------------------------------------------------------------------
Static Function Ctb440TSX2(aInfFil, cEmprAux, cFilAux)

Local cAliasAux := CriaTrab(,.F.)
//grava as informacoes da empresa logada Grupo / Filial / aliasTmpSX2
aInfFil := {}
aAdd(aInfFil, cEmpAnt)
aAdd(aInfFil, cFilAnt)
aAdd(aInfFil, cAliasAux)

cEmpAnt := cEmprAux
cFilAnt := cFilAux

//verifica se ja tem um alias com SX2TMP aberto e fecha
If Select("SX2TMP") <> 0
	dbSelectArea("SX2TMP")
	dbCloseArea()
EndIf	
//abre SX2 da Empresa passada no parametro com alias SX2TMP
OpenSxs(,,,,cEmprAux,"SX2TMP","SX2",,.F.)
//Se ocorrer erro aborta todo o processamento
If Select("SX2TMP") <= 0
	Final("SX2 Grupo Empresa: "+cEmprAux+" nao encotrado. Verifique!")
EndIf
//seta indice 1 do SX2TMP
dbSetOrder(1)

//Utiliza funcao DBChangeAlias( < cOldAlias >, < cNewAlias > ) para mudar alias SX2 ATUAL
lRet := DBChangeAlias( "SX2",  cAliasAux )

If lRet  //se conseguir mudar o alias ai muda o alias do SX2TMP para SX2
	lRet := DBChangeAlias( "SX2TMP",  "SX2" )
EndIf

If !lRet
	Final("Error: SX2 Gr Empr: "+cEmprAux+" , verify!")
EndIf

Return(aInfFil)


//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} Ctb440RSX2

Retorna alias SX2 ORIGINAL gravado na funcao que troca o SX2 fazendo retornar o SX2 ORIGINAL
Utiliza o array aInfFil onde:
1a. posicao - alias temporario SX2 ORIGINAL
2a. posicao - Empresa Original
3a. posicao - Filial Original

@params:
	aInfFil: array que contem 
	posicao 1 = cEmpAnt := aInfFil[1]
	posicao 2 = cFilAnt := aInfFil[2]
	posicao 3 = cAliasAux := aInfFil[3]
@return: 
	lRet:	L�gico. .t. Valido; .f. N�o valido
@sample:
	
@author Paulo Carnelossi

@since 29/10/2019
@version 1.0
*/
//------------------------------------------------------------------------------------------------------

Static Function Ctb440RSX2(aInfFil)
Local lRet := .T.
Local cAliasAux := ""

cEmpAnt := aInfFil[1]
cFilAnt := aInfFil[2]
cAliasAux := aInfFil[3]

//verifica se SX2 esta aberto e fecha
If Select("SX2") <> 0
	dbSelectArea("SX2")
	dbCloseArea()
EndIf	

//Utiliza funcao DBChangeAlias( < cOldAlias >, < cNewAlias > ) para mudar alias SX2 ATUAL
If Select(cAliasAux) <> 0
	lRet := DBChangeAlias( cAliasAux, "SX2" )
EndIf

If !lRet
	Final("Error: SX2 Gr Empr: "+cEmpAnt+" , verify!")
EndIf

Return(lRet)
