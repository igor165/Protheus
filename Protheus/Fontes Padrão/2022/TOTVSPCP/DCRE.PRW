#Include "Protheus.Ch"

//-----------------------------------------------------------------------
/*/{Protheus.doc} DCRE
Preparacao do meio-magnetico para o DCR-E - Zona Franca 

@author Sergio S. Fuzinaka      
@since 07.06.04
@version 1.0
/*/
//-----------------------------------------------------------------------
function DCRE(lLista,aFilsCalc)

local aRet			:=	{}
local cPerg 		:= 'DCRE'
local cProd			:= ''
local cIndSD1		:= ''   
local cIndImp		:= ''
local cFilOrig		:= cFilAnt
local cValid		:= GetNewPar("MV_DCRE09","SB1->B1_TIPO<>'MO'")	//Validacao Parametrizada
local lDCRE			:= ExistBlock("DCRECF")
local nIndSD1		:= 0      
local nforFilial	:= 0
local cProdOp       :=''

//Ativa a validacao do componente Pai
private lValPai		:= GetNewPar("MV_DCRE12",.F.)

//Validacao do Produto/Estrutura 
private bValid		:= {||.T.}

//Contadores do Registro Tipo 2, 3 e 4 
private nReg2Num	:= 0
private nReg3Num	:= 0
private nReg4Num	:= 0

//Gera Registro 3 - Subcomponentes Importados 
private lReg3		:= GetNewPar("MV_DCRE01",.F.)	

//Utilizado para verificar se eh um SubComponente Importado 
private cProdAnt	:= ""

//Utilizado para gerar um relatorio de conferencia de Produtos Importados
private lImpr		:= Iif(Valtype(lLista)=="L",lLista,.F.)

//Utilizados posteriormente para passar para o Estoque referente estrutura do Produto
private dDataDe		:= mv_par01
private dDataAte	:= mv_par02
private cOp			:= ''
private lExisOp		:= .f.

//Utilizados posteriormente para posicionar na NF conforme lote informado
private cLote		:= ''

default lLista		:= .F.
default aFilsCalc	:= { { .T., cFilAnt } }

//Destruir Objetos das Tabelas Temporarias 
If Type("oTmpR00") == "O"
	oTmpR00:Delete()
EndIf
If Type("oTmpR01") == "O"
	oTmpR01:Delete()
EndIf
If Type("oTmpR02") == "O"
	oTmpR02:Delete()
EndIf
If Type("oTmpR03") == "O"
	oTmpR03:Delete()
EndIf
If Type("oTmpR04") == "O"
	oTmpR04:Delete()
EndIf


//Objetos das Tabelas Temporarias 
Private oTmpR00 
Private oTmpR01 
Private oTmpR02 
Private oTmpR03 
Private oTmpR04 

//Verifica se ha alguma validacao cadastrada no parametro MV_DCRE09 
if !empty(cValid)
	cValid			:= "{|| "+cValid+"}"
	bValid			:= &cValid
endif

//Gera arquivos temporarios
GeraTemp()

if Pergunte(cPerg,.T.)

	//alimentando variáveis private
	cProd 	:= cProdAnt := mv_par04	//Codigo do Produto
	cOp		:= alltrim( mv_par15 )
	//cLote	:= alltrim( mv_par16 )
	lExisOp:= iif(! empty(cOp), .t., .f. )
	
	for nforFilial := 1 to len(aFilsCalc)
		if aFilsCalc[nforFilial, 1]
			cFilAnt := aFilsCalc[ nforFilial, 2 ]
			if !empty(cProd)

				If lExisOp
					DbSelectArea("SC2")
					DbSetorder(1) //C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD
					If (DbSeek(xFilial("SC2")+cOp))
						cProdOp:=SC2->C2_PRODUTO
					Endif
				Endif

				If !lExisOp .Or. cProd==cProdOp

					//Processa o arquivo DCRE.INI
					_aTotal[99] := .T.
				
					//Grava Registro Tipo 0 - Informacoes Gerais do DCRE 
					GravaReg0(cProd)
					
					//Grava Registro Tipo 1 - Modelos, Tipos e Referencias
					GravaReg1(cProd)
					
					//Processa Estrutura de Produtos (SG1)
					/* Executa execblock para verificar se produto sera fabricado ou comprado  "COMPONENTE FABRICADO OU COMPRADO" */
					
					if lDCRE
						ExecBlock("DCRECF",.F.,.F.,{cProd})
					else	
						dbselectarea("SG1")		//Arquivo de Estrutura de Produtos
						dbsetorder(1)
						ProcEstru(cProd, cOP)	
					endif 
				
					while .T.
						aRet := SelOpc ()
						if (aRet[1]==1)
							AltEstru(1)	
						elseif (aRet[1]==2)
							AltEstru(2)	
						elseif (aRet[1]==3)
							AltEstru(3)
						else
							Exit
						endif
					enddo
					
					#ifNDEF TOP
						//Deletando os Indices 
						dbselectarea("SD1")
						RetIndex("SD1")
						dbClearFilter()
						Ferase(cIndSD1+OrdBagExt())
					#endif

				endif
			endif
		endif
	next
	
	cFilAnt := cFilOrig	
endif


return nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} ProcEstru
Processa Estrutura dos Produtos (SG1) - Funcao Recursiva

@author Sergio S. Fuzinaka      
@since 07.06.04
@version 1.0
/*/
//-----------------------------------------------------------------------
static function ProcEstru(cProd,cOP)

local aCompone	:= {'',0}
local nRecno	:= Recno()
local nQtdIt	:= 1
local nX		:= 0
local lPCPREVATU	:= FindFunction('PCPREVATU') 

default cProd	:= ''
default cOP		:= ''

//Se o cliente não informar a OP no momento da geração da DCRE será efetuado o legado, trazendo informações somente da estrutura e não do que realmente foi utilizado na devida Ordem de Produção
if empty(cOP)  
	
	if dbSeek(xFilial("SG1")+cProd)
		while !Eof() .And. SG1->G1_FILIAL+SG1->G1_COD == xFilial("SG1")+cProd
			SB1->(dbsetorder(1))
			SB1->(dbSeek(xFilial("SB1")+SG1->G1_COMP))
			if lValPai
				nQtdIt := ExplEstr(1,,RetFldProd(SB1->B1_COD,"B1_OPC"),IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU) )		//Validacao do Componente
			endif
	        if nQtdIt > 0
				ProcReg(SG1->G1_COMP,SG1->G1_COD,SG1->G1_QUANT)
				ProcEstru(SG1->G1_COMP)
			endif
			dbSkip()
		enddo
	endif
	
	dbGoTo(nRecno)

else

	/*/ Busco os componentes utilizados na estrutura do produto (Materiais) # Retorno: Posição 1 = Quantidade utilizada # 2 = Código Componente /*/
	aCompone := DCREOP(cProd,cOP,dDataDe,dDataAte)

	for nX:= 1 to len( aCompone )
		ProcReg(aCompone[nX,2],cProd,aCompone[nX,1],.T.)
	next

endif

return(.T.)

//-----------------------------------------------------------------------
/*/{Protheus.doc} ProcReg
Processa Registros 

@author Sergio S. Fuzinaka      
@since 07.06.04
@version 1.0
/*/
//-----------------------------------------------------------------------
static function ProcReg(cComp,cProd,nQuant,lOP)

local aArea		:= GetArea()

default lOP		:= .f.

//Valida o Componente da Estrutura 
if CheckComp(cComp,lOP)
	
	//Processa Cadastro de Produtos 
	dbselectarea("SB1")
	dbsetorder(1)
	if dbSeek(xFilial("SB1")+cComp)
		
		//Validacao Parametrizada ( MV_DCRE09 )
		if Eval(bValid)
			
			//Grava Componentes do Produtos 
			if SB1->B1_ORIGEM $ "0 "						
				GravaReg2(cComp,nQuant)						//Registro Tipo 2 - Componente Nacional
			else
				cIndImp := SB1->B1_ORIGEM
				//Tratamento retirado provisoriamente, pois o Registro 3 é gerado de forma incorreta. Sendo assim, os subcomponentes serão considerados no Registro 2(Nacional) ou Registro 4(Importado).
				//Posteriormente será realizado tratamento conforme específicação issue DSERFIS1-17 e alinhamento entre PO Fiscal e Materias
				/*if lReg3 .And. cProd<>cProdAnt
					GravaReg3(cComp,cProd,nQuant,cIndImp)	//Registro Tipo 3 - SubComponente Importado
				else										
					GravaReg4(cComp,nQuant,cIndImp)			//Registro Tipo 4 - Componente Importado
				endif		*/		
				GravaReg4(cComp,nQuant,cIndImp)			//Registro Tipo 4 - Componente Importado	
			endif
		endif
	endif
endif
RestArea(aArea)

return nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} GravaReg0
Grava Registro Tipo 0 - Informacoes Gerais do DCRE

@author Sergio S. Fuzinaka      
@since 07.06.04
@version 1.0
/*/
//-----------------------------------------------------------------------
static function GravaReg0(cComp)

local xProcesso 

//Tratamento tipo MV_PAR10 - devido alteração no pergunte, pois no AtuSx não aceita campo numérico com tamanho maior que 17
if valtype( mv_par10 ) == "C"
	xProcesso := strzero(val(mv_par10),17)
elseif valtype( mv_par10 ) == "N"
	xProcesso := strzero(mv_par10,17)
endif

dbselectarea("SB1")
dbsetorder(1)
if dbSeek(xFilial("SB1")+cComp)
	RecLock("R00",.T.)
	R00->CNPJ		:= strzero(Val(aRetDig(SM0->M0_CGC,.F.)),14)
	R00->CPF		:= strzero(Val(aRetDig(mv_par05,.F.)),11)
	R00->PPB		:= upper(mv_par06)
	R00->DESCPROD	:= upper(SB1->B1_DESC)
	R00->NCM		:= SB1->B1_POSIPI
	R00->UNIDADE	:= upper(SB1->B1_UM)
	R00->PESO_BRUTO	:= SB1->B1_PESBRU
	R00->SALARIO 	:= mv_par12													//Total dos Custos com Salarios e Ordenados ja convertidos
	R00->ENCARGO 	:= mv_par13													//Total dos Custos com Encargos Sociais e Trabalhistas ja convertidos
	R00->TP_DCRE	:= Iif(mv_par08==1,"N",Iif(mv_par08==2,"R","S"))
	R00->DCRE_ANT	:= Iif(mv_par08==1,replicate(" ",10),strzero(mv_par09,10))
	R00->PROCESSO	:= Iif(mv_par08==2,xProcesso,replicate(" ",17))
	R00->TP_COEFIC  := Iif(mv_par07==1,"F","V")
	MsUnlock()
endif

return nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} GravaReg1
Grava Registro Tipo 1 - Outros Modelos

@author Sergio S. Fuzinaka      
@since 07.06.04
@version 1.0
/*/
//-----------------------------------------------------------------------
static function GravaReg1(cComp)

local aArea 		:= GetArea()
local aPrcMoe		:= {}
local cMVB1PRECO	:= alltrim(GetNewPar("MV_B1PRECO",''))		//Array contendo os campos criados ou utilizados na tabela SB1 referente ao Preço de Venda Estimado e Moeda referente ao Preço
local nPrcVenda		:= 1									//Preço de Venda conforme tratamento anterior
local nPrcVen		:= 0
local nMoeda		:= 0


dbselectarea("SB1")
dbsetorder(1)

if dbSeek(xFilial("SB1")+cComp)
	RecLock("R01",.T.)
	R01->MODELO			:= mv_par14						//Modelo 
	R01->DESCRICAO		:= upper(SB1->B1_DESC)			//Descricao do Produto
	R01->CODPROD		:= cComp						//Codigo do Componente
	
	/*Tratamento para considerar o valor do Preço de Venda, caso esteja configurado na Tabela de Preço de Venda. Caso não esteja, continuará com o valor padrão 1.
	Não é passada data para que seja considerada a data atual */
	
	//Validação para que seja apresentado o conteúdo corretamente
	if !empty(cMVB1PRECO) .And. left(cMVB1PRECO,1)=="{" .And. substr(cMVB1PRECO,len(cMVB1PRECO),1)=="}" .And. len(&(cMVB1PRECO))==2  
		
		aPrcMoe			:=	&(cMVB1PRECO)
		
		if len(aPrcMoe) == 2 .and. (SB1->(FieldPos(aPrcMoe[1]))>0 .and. SB1->(FieldPos(aPrcMoe[2]))>0)
			nPrcVen		:= SB1->(&(aPrcMoe[1]))
			nMoeda		:= SB1->(&(aPrcMoe[2]))
			
			If MV_PAR11 == 0
				nPrcVenda	:=  xMoeda(nPrcVen,nMoeda,01,,2) // Foi passado 01 quando o parâmetro estava zerado, porque o xMoeda estava se perdendo. Ora calculava, ora não calculava.
			else
				nPrcVenda	:=  xMoeda(nPrcVen,nMoeda,MV_PAR11,,2)
			Endif
		endif
		
	endif
	
	R01->PRC_VENDA		:= nPrcVenda						//Preco de Venda - Deve ser alterado no programa DCR-E caso não utilize os campos específicos na tabela de Produtos
	
	MsUnlock()
endif

RestArea(aArea)

return nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} GravaReg2
Grava Registro Tipo 2 - Componentes Nacionais

@author Sergio S. Fuzinaka      
@since 07.06.04
@version 1.0
/*/
//-----------------------------------------------------------------------
static function GravaReg2(cComp,nQuant)
  
local aDados		:= {}
local aArea			:= GetArea()

dbselectarea("R02")
dbsetorder(1)
if !dbSeek(cComp)

	aDados	:= RetDINf(cComp,"N")

	if aDados[14] //Se encontrou documento de aquisição
		RecLock("R02",.T.)
		R02->CODPROD	:= cComp
		R02->NUMERO 	:= strzero(++nReg2Num,4)							//Numero Identificador do Componente Nacional dentro do arquivo
		R02->NF			:= aDados[05]
		R02->SERIE		:= aDados[06]
		R02->DATAEMIS	:= aDados[07]
		R02->CNPJ		:= aDados[08]
		R02->IE			:= aDados[09]
	    R02->DESCPROD	:= if(empty(aDados[12]),upper(SB1->B1_DESC),aDados[12])
		R02->UNIDADE	:= upper(SB1->B1_UM)
		R02->NCM		:= SB1->B1_POSIPI
		R02->CUSTO_UNIT	:= if(empty(aDados[13]),aDados[11],aDados[13])
		
		R02->QTDE 		+= nQuant
		
		MsUnlock()
	endif
else
	RecLock("R02",.F.)
		R02->QTDE += nQuant
	MsUnlock()
endif	


RestArea(aArea)

return nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} GravaReg3
Grava Registro Tipo 3 - SubComponentes Importados

@author Sergio S. Fuzinaka      
@since 07.06.04
@version 1.0
/*/
//-----------------------------------------------------------------------
static function GravaReg3(cComp,cProd,nQuant,cIndImp)

local aDados	:= {}
local aArea		:= GetArea()
local cBCIncII	:= GetNewPar("MV_DCRE02","")	//Campo B5 - Indicador de inclusao deste componente no calculo do II - S-Sim ou N-Nao
local cIndSusp	:= GetNewPar("MV_DCRE03","")	//Campo B5 - Indicador de utilizacao do regime com suspensao de impostos durante a importacao - S-Sim ou N-Nao
local cIndRedu	:= GetNewPar("MV_DCRE04","")	//Campo B5 - Indicador de utilizacao de coeficiente de reducao do II - N-Nao ou S-Sim

dbselectarea("SB5")
dbsetorder(1)
if dbSeek(xFilial("SB5")+cComp)

	dbselectarea("R03")
	dbsetorder(1)
	if !dbSeek(cComp)
	
		aDados := RetDINf(cComp,"D",cIndImp)
	
		if aDados[14] //Se encontrou documento de aquisição
			RecLock("R03",.T.)
			R03->CODPROD	:= cComp							//SubComponente Importado de um Componente Nacional
			R03->NROSUB 	:= strzero(++nReg3Num,4)			//Numero Identificador do Subcomponente Nacional dentro do arquivo
			R03->NUMERO 	:= strzero(++nReg3Num,4)			//Numero Identificador do Componente Nacional dentro do arquivo
		
			if !empty(cBCIncII)
				R03->INCLUI_BC	:= Iif(SB5->(FieldPos(cBCIncII))>0,SB5->&(cBCIncII),"S")
			else
				R03->INCLUI_BC	:= "S"
			endif
			
			//Indicador de inclusao deste componente no calculo do II
			if R03->INCLUI_BC == "N"
				if !empty(cIndSusp)
					R03->INDIC_SUSP	:= Iif(SB5->(FieldPos(cIndSusp))>0,SB5->&(cIndSusp),"S")
				else
					R03->INDIC_SUSP	:= "S"
				endif
			else
				R03->INDIC_SUSP	:= "S"
		    endif
	
	       R03->IMP_DIR    := Iif(	cIndImp=="1", "S", "N")    
			R03->DI			:= aDados[02]
			R03->NUM_ADICAO	:= aDados[03]
			R03->NUM_ITEM	:= aDados[04]
			R03->NF			:= aDados[05]
			R03->SERIE		:= aDados[06]
			R03->DATAEMIS	:= aDados[07]
			R03->CNPJ		:= aDados[08]
			R03->IE			:= aDados[09]
		    R03->DESCPROD	:= if(empty(aDados[12]),upper(SB1->B1_DESC),aDados[12])
			R03->UNIDADE	:= Iif(cIndImp == "1", "", SB1->B1_UM)
			R03->NCM		:= Iif(cIndImp == "1", replicate("0",8), SB1->B1_POSIPI)
			
			if !empty(cIndRedu)
				R03->IND_RED_II	:= Iif(SB5->(FieldPos(cIndRedu))>0,SB5->&(cIndRedu),"N")
			else
				R03->IND_RED_II	:= "N"
			endif
			
	 		R03->CUSTO_UNIT	:= if(empty(aDados[13]),aDados[11],aDados[13])
	 		
	 		R03->QTDE += nQuant
			MsUnlock()
	 	endif
	else
		RecLock("R03",.F.)
			R03->QTDE += nQuant
		MsUnlock()
	endif
	
endif

RestArea(aArea)

return nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} GravaReg4
Grava Registro Tipo 4 - Componentes Importados

@author Sergio S. Fuzinaka      
@since 07.06.04
@version 1.0
/*/
//-----------------------------------------------------------------------
static function GravaReg4(cComp,nQuant,cIndImp)
                                
local aDados	:= {}
local aArea		:= GetArea()
local cIndSusp	:= GetNewPar("MV_DCRE03","")					//Campo B5 - Indicador de utilizacao do regime com suspensao de impostos durante a importacao - S-Sim ou N-Nao
local cIndRedu	:= GetNewPar("MV_DCRE04","")					//Campo B5 - Indicador de utilizacao de coeficiente de reducao do II - N-Nao ou S-Sim
local cOrigemImp := SuperGetMV("MV_DCRE13",.T.,"2")  //Origens de Produto considerados Importados diretamente
local lImpNfImp := SuperGetMV("MV_DCRE14",.F.,.F.)  // Imprime as notas de produtos importados diretamente?

dbselectarea("SB5")
dbsetorder(1)
if dbSeek(xFilial("SB5")+cComp)

	dbselectarea("R04")
	dbsetorder(1)
	if !dbSeek(cComp)
	
		aDados := RetDINf(cComp,"D",cIndImp)
	
		if aDados[14] //Se encontrou documento de aquisição
			RecLock("R04",.T.)
			R04->NUMERO 	:= strzero(++nReg4Num,4)				//Numero Identificador do Componente Nacional dentro do arquivo
			R04->CODPROD	:= cComp
			
			if !empty(cIndSusp)
				R04->INDIC_SUSP	:= Iif(SB5->(FieldPos(cIndSusp))>0,SB5->&(cIndSusp),"")
			endif
	
			R04->IMP_DIR    := Iif(	(cIndImp $ cOrigemImp)  , "S", "N")    		
			R04->DI			:= aDados[02]
			R04->NUM_ADICAO	:= aDados[03]
			R04->NUM_ITEM	:= aDados[04]
			R04->NF			:= aDados[05]
			R04->SERIE		:= aDados[06]
			R04->DATAEMIS	:= aDados[07]
			R04->CNPJ		:= aDados[08]
			R04->IE			:= aDados[09]
		    R04->DESCPROD	:= ALLTRIM(cComp) + '-' + if(empty(aDados[12]),upper(SB1->B1_DESC),aDados[12])
			R04->UNIDADE	:= Iif(((cIndImp $ cOrigemImp)  .and. !lImpNfImp), "", SB1->B1_UM)
			R04->NCM		:= Iif(((cIndImp $ cOrigemImp)  .and. !lImpNfImp), replicate("0",8), SB1->B1_POSIPI)
			
			if !empty(cIndRedu)
				R04->IND_RED_II	:= Iif(SB5->(FieldPos(cIndRedu))>0,SB5->&(cIndRedu),"")
			endif
	 		R04->CUSTO_UNIT	:= if(empty(aDados[13]),aDados[11],aDados[13])
	 		
	 		R04->QTDE += nQuant
			MsUnlock()
	 	endif

	else
		RecLock("R04",.F.)
			R04->QTDE += nQuant
		MsUnlock()
	endif	
	
endif

RestArea(aArea)
return nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} RetDINf
Retorna dados da DI ou Nf

@author Sergio S. Fuzinaka      
@since 07.06.04
@version 1.0
/*/
//-----------------------------------------------------------------------
static function RetDINf(cComp,cTp,cIndImp)

local aStru		:= {} 
local aSigaEIC	:= {}
local aArea 	:= GetArea()
local cQuery	:= ''
local cAlias	:= ''
local cD1DI		:= GetNewPar("MV_DCRE05","")			//Sem Integracao EIC - Campo D1 - Contem o numero da DI
local cD1Adic	:= GetNewPar("MV_DCRE06","")		//Sem Integracao EIC - Campo D1 - Contem o numero da Adicao
local cD1AliqII	:= GetNewPar("MV_DCRE07","")			//Sem Integracao EIC - Campo D1 - Contem o taxa da Aliquota de II
local cD1It		:= GetNewPar("MV_DCRE08","")			//Sem Integracao EIC - Campo D1 - Contem o numero do Item da Adicao
local cDescrSD1	:= GetNewPar("MV_DCRE10","")			//Descricao da tabela SD1
local cValDolar	:= GetNewPar("MV_DCRE11","")			//Valor Unitario em Dolar
local cOrigemImp:= SuperGetMV("MV_DCRE13")  //Origens de Produto considerados Importados diretamente
local lImpNfImp := SuperGetMV("MV_DCRE14")  // Imprime as notas de produtos importados diretamente?
local dDtProc	:= mv_par01								//Data Base de Processamento das NF
local lChave		:= .F.
local lQuery	:= .F.
local lEasy		:= GetNewPar("MV_EASY","N")=="S"		//Integracao EIC
local lFisGetEIC	:= Findfunction("FISGETEIC")		//Verifica se a função existe no RPO
local lLote		:= !empty(cLote)
local nCUnit	:= 0
local nX		:= 0
local aDados	:= {	""					, ;			//01-Tipo DI ou NF
						""					, ;			//02-DI
						""					, ;			//03-No. Adicao
						""					, ;			//04-No. Item
						replicate("0",10)	, ;			//05-NF
						""					, ;			//06-Serie
						ctod("")			, ;			//07-Data de Entrada
						replicate("0",14)	, ;			//08-CNPJ
						""					, ;			//09-IE
						0					, ;			//10-Aliquota do II (Imposto de Importacao)
						0					, ;			//11-Custo Unitario do Componente
						Space(80)			, ;			//12-Descricao do Produto no SD1
						0					, ;			//13-Custo Unitario em Dolar no SD1
						.F.					}			//14-Se encontrou ou não documento de aquisição
									
						
#ifDEF TOP
    if TcSrvType() <> "AS/400"
    	lQuery := .T.
    endif
#endif    

if lQuery
	cAlias := "TopSD1"
	aStru  := SD1->(dbStruct())

	cQuery := "SELECT * "
	cQuery += "FROM "+RetSqlName("SD1")+" "
	cQuery += "WHERE D1_FILIAL='"+xFilial("SD1")+"' AND "
	cQuery += "D1_COD='"+cComp+"' AND "
	if cTp == "D"
	    cQuery += "(D1_TIPO_NF IN ('1','3') OR "
    else
        cQuery += "(D1_TIPO = 'N' OR "
    endif
	cQuery += " SUBSTRING(D1_CF,1,1)='3')  AND "
	if lLote .and. !lExisOp
		cQuery += " D1_LOTECTL='"+cLote+"' AND "
	endif
	cQuery += " D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY D1_EMISSAO DESC, D1_DOC DESC"

	cQuery := ChangeQuery(cQuery)
	dbusearea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

	for nX := 1 To len(aStru)
		if aStru[nX][2] <> "C" 
			TcSetField(cAlias,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
		endif
	next nX
	dbselectarea(cAlias)
else
	cAlias := "SD1"
	dbselectarea("SD1")
	if cTp == "N"
		dbsetorder(3)	//Por Emissao
		dbSeek(xFilial("SD1")+Dtos(dDtProc),.T.)	
		while !Bof()
			if lLote
				lChave:= D1_TIPO == "N" .And. D1_FILIAL+D1_COD == xFilial("SD1")+cComp .And. D1_EMISSAO <= dDtProc .and. D1_LOTECTL == cLote .and. !lExisOp
			else
				lChave:= D1_TIPO == "N" .And. D1_FILIAL+D1_COD == xFilial("SD1")+cComp .And. D1_EMISSAO <= dDtProc
			endif
			
			if lChave
				Exit
			endif			
			dbSkip(-1)
		enddo	
	else
		dbsetorder(6)	//Por DtDigit
		dbSeek(xFilial("SD1")+Dtos(dDtProc),.T.)	
		while !Bof()
				
			if lLote
				lChave:= D1_TIPO_NF $ "13" .And. D1_FILIAL+D1_COD == xFilial("SD1")+cComp .And. D1_DTDIGIT <= dDtProc .and. D1_LOTECTL == cLote .and. !lExisOp
			else
				lChave:= D1_TIPO_NF $ "13" .And. D1_FILIAL+D1_COD == xFilial("SD1")+cComp .And. D1_DTDIGIT <= dDtProc
			endif
			
			if lChave
				Exit
			endif							
			dbSkip(-1)
		enddo	
	endif
endif

if (cAlias)->D1_FILIAL+(cAlias)->D1_COD == xFilial("SD1")+cComp
	dbselectarea("SF1")
	dbsetorder(1)
	if dbSeek(xFilial("SF1")+(cAlias)->D1_DOC+(cAlias)->D1_SERIE+(cAlias)->D1_FORNECE+(cAlias)->D1_LOJA)
	
		if lEasy .And. lFisGetEIC	//Integracao SIGAEIC
			aSigaEIC	:= FisGetEIC(xFilial("SF1"),(cAlias)->D1_DOC,(cAlias)->D1_SERIE,,,,{"W6_DI_NUM","W8_ADICAO","W8_SEQ_ADI","W6_TX_US_D","YE_VLFISCA","YD_PER_II","WN_PRUNI","WN_PRECO"},,(cAlias)->D1_COD,(cAlias)->D1_TEC,(cAlias)->D1_EMISSAO,cTp,mv_par11)						
		endif			
	
		if cTp == "N"											//Nota Fiscal - Componente Nacional	
			aDados[05]	:= strzero(Val((cAlias)->D1_DOC),10)	//NF
			aDados[06]	:= (cAlias)->D1_SERIE					//Serie
			aDados[07]	:= (cAlias)->D1_EMISSAO					//Data de Emissao
				
			dbselectarea("SA2")
			dbsetorder(1)
			if dbSeek(xFilial("SA2")+(cAlias)->D1_FORNECE+(cAlias)->D1_LOJA)
				aDados[08] := strzero(Val(aRetDig(SA2->A2_CGC,.F.)),14)			//CNPJ
				aDados[09] := strzero(Val(aRetDig(SA2->A2_INSCR,.F.)),15)		//IE
			endif

		    nCUnit		:= Iif((cAlias)->(FieldPos(cValDolar))>0,(cAlias)->&(cValDolar),0)
		    if nCUnit==0
		   	   nCUnit	:= (cAlias)->D1_VUNIT		//Custo Unitario
			   	nCUnit	+= (cAlias)->D1_VALFRE / (cAlias)->D1_QUANT
			   	nCUnit	+= (cAlias)->D1_SEGURO / (cAlias)->D1_QUANT
			   	nCUnit	+= (cAlias)->D1_DESPESA / (cAlias)->D1_QUANT
		   	endif   
			aDados[11] := nCUnit
		else		 	//DI - Componente Importado
			if lImpr .Or. ((cIndImp $ cOrigemImp)  .and. lImpNfImp) .Or. !(cIndImp $ cOrigemImp)  // Conforme tabela A CST.  
				aDados[05]	:= strzero(Val((cAlias)->D1_DOC),10)	//NF
				aDados[06]	:= (cAlias)->D1_SERIE					//Serie
				aDados[07]	:= (cAlias)->D1_DTDIGIT         		//Data de Entrada
			endif			
			
			If ((cIndImp $ cOrigemImp) .and. lImpNfImp) .Or. !(cIndImp $ cOrigemImp)   // Importados  
				dbselectarea("SA2")
				dbsetorder(1)
				if dbSeek(xFilial("SA2")+(cAlias)->D1_FORNECE+(cAlias)->D1_LOJA)
					aDados[08] := strzero(Val(aRetDig(SA2->A2_CGC,.F.)),14)			//CNPJ
					aDados[09] := strzero(Val(aRetDig(SA2->A2_INSCR,.F.)),15)		//IE   
				    if aDados[09] == "000000000000000"
				        aDados[09] := ""
				    endif
				endif	                             
			endif

			//Tipo do Documento: D=DI
			aDados[01]	:= "D"
			//Numero da DI
			aDados[02]	:=strzero(Val(Iif((cAlias)->(FieldPos(cD1DI))>0,(cAlias)->&(cD1DI),"")),10)
			//Numero da Adicao
			aDados[03]	:= strzero(Val(Iif((cAlias)->(FieldPos(cD1Adic))>0,(cAlias)->&(cD1Adic),"")),3)
			//Numero do Item da Adicao
			aDados[04]	:= strzero(Val(Iif((cAlias)->(FieldPos(cD1It))>0,(cAlias)->&(cD1It),"")),2)
			//Aliquota de II
			aDados[10]	:= Iif((cAlias)->(FieldPos(cD1AliqII))>0,(cAlias)->&(cD1AliqII),0)
			//Custo Unitario
			if lEasy .And. lFisGetEIC	//Integracao SIGAEIC
				aDados[11]	:= round(aSigaEIC[7],6)
			else
				aDados[11]	:= Iif((cAlias)->(FieldPos(cValDolar))>0,(cAlias)->&(cValDolar),0)
			endif
			//Descricao do Item
			aDados[12]	:= Iif((cAlias)->(FieldPos(cDescrSD1))>0,(cAlias)->&(cDescrSD1),"")

		    nCUnit		:= aDados[11]
   		    if nCUnit==0
		   	   nCUnit	:= (cAlias)->D1_VUNIT		//Custo Unitario
			   	nCUnit	+= (cAlias)->D1_VALFRE / (cAlias)->D1_QUANT
			   	nCUnit	+= (cAlias)->D1_SEGURO / (cAlias)->D1_QUANT
			   	nCUnit	+= (cAlias)->D1_DESPESA / (cAlias)->D1_QUANT
		   	endif
		   	
		   	if lEasy .And. ((cAlias)->(FieldPos(cD1DI))==0 .Or. ((cAlias)->(FieldPos(cD1DI))>0 .And. empty((cAlias)->&(cD1DI)))) 
				//Numero da DI
				aDados[02]	:= strzero(Val(aSigaEIC[1]),10)
				//Numero da Adicao
				aDados[03]	:= strzero(Val(aSigaEIC[2]),3)
				//Numero do Item da Adicao
				aDados[04]	:= strzero(Val(aSigaEIC[3]),2)			
				//Aliquota de II
				aDados[10]	:= aSigaEIC[6]
		   	endif
		   	
		endif	
		
		//Custo Unitario do Componente convertido na moeda selecionada (MV_PAR11)
		if SF1->F1_MOEDA <> mv_par11
			if lEasy .And. lFisGetEIC	//Integracao SIGAEIC
			   	if cTp <> "N"			//Nota Fiscal - Componente Importado
				  	//Tratamento retirado pois há valores de custo unitário dentro da propria tabela / Caso não tenha valor no campo WN_PRECO será considerado o tratamento anterior
				  	if aSigaEIC[8]>0
				  		aDados[11] := aSigaEIC[8]
				  	elseif aSigaEIC[4]>0
	  				 	aDados[11] := round((nCUnit/aSigaEIC[4]),6)
	  			  	elseif aSigaEIC[5]>0
						aDados[11] := round((nCUnit/aSigaEIC[5]),6)
				  	endif  	
			   	else					//Nota Fiscal - Componente Nacional
	  			  	if aSigaEIC[1]>0
	  				 	aDados[11] := round((nCUnit/aSigaEIC[1]),6)
				  	endif
			   	endif
			else
				aDados[11] := xMoeda(nCUnit,SF1->F1_MOEDA,mv_par11,Iif(cTp=="N",SF1->F1_EMISSAO,SF1->F1_DTDIGIT),4)
			endif
		else
			aDados[11] := nCUnit
	   	endif   		
	endif
	
	//Tratamento para informar se encontrou ou não documento de aquisição
	//Conforme alinhamento através da issue DSERFIS1-17 pois não deveria gerar se não houver aquisição (Produto por aquisição própria ou sem aquisições )
	aDados[14] := .T.
	
endif

if lQuery
	dbselectarea(cAlias)
	dbCloseArea()
endif

RestArea(aArea)

return(aDados)

//-----------------------------------------------------------------------
/*/{Protheus.doc} CheckComp
Verifica se o componte eh valido 

@author Sergio S. Fuzinaka      
@since 07.06.04
@version 1.0
/*/
//-----------------------------------------------------------------------
static function CheckComp(cComp,lOp)

local aArea		:= GetArea()
local cRevisao	:= mv_par03		//Revisao da Estrutura
local dDtValid	:= mv_par02		//Data de Validade do Componente
local lRet		:= .T.

default lOP 	:= .F.

If !lOP // Quando for geração por OP, deve-se considerar todos os componentes utilizados

	// Tratamento somente sera feito se a revisao for preenchida
	if !empty(cRevisao)	.And. !(cRevisao >= SG1->G1_REVINI .And. cRevisao <= SG1->G1_REVFIM)
		lRet := .F.
	endif
	
	// Tratamento da validade do componente na estrutura 
	if  lRet .And. !(dDtValid >= SG1->G1_INI .And. dDtValid <= SG1->G1_FIM)
		lRet := .F.
	endif	
	
	// Verifica se o componente e produzido ou comprado
	if lRet
		dbselectarea("SG1")
		dbsetorder(1) 
		if dbSeek(xFilial("SG1")+cComp)
			lRet := .F.
			while !Eof() .And. SG1->G1_FILIAL+SG1->G1_COD == xFilial("SG1")+cComp
				if !(dDtValid >= SG1->G1_INI .And. dDtValid <= SG1->G1_FIM)
					lRet := .F.
	            	Exit
	   			else
					lRet := .T.   			
	   			endif
		    	dbSkip()
			enddo
		endif
	endif

EndIf

RestArea(aArea)

return(lRet)

//-----------------------------------------------------------------------
/*/{Protheus.doc} GeraTemp
Gera arquivos temporarios

@author Sergio S. Fuzinaka      
@since 07.06.04
@version 1.0
/*/
//-----------------------------------------------------------------------
static function GeraTemp()

local aStru		:= {}
local cArq		:= ''
local nTamCod	:= TamSx3("B1_COD")[1]


//Registro Tipo 0 - Informacoes Gerais do DCRE 
aadd(aStru,{"CNPJ"			,"C",014,0})		//CNPJ do Estabelecimento do DCRE
aadd(aStru,{"CPF"			,"C",011,0})		//CPF do Representante Legal
aadd(aStru,{"PPB"			,"C",080,0})		//Identificacao do Processo Produtivo Basico
aadd(aStru,{"DESCPROD"		,"C",080,0})		//Descricao do Produto
aadd(aStru,{"NCM"			,"C",008,0})		//NCM
aadd(aStru,{"UNIDADE"		,"C",080,0})		//Unidade de Comercializacao do Produto
aadd(aStru,{"PESO_BRUTO"	,"N",014,5})		//Peso Bruto
aadd(aStru,{"SALARIO"		,"N",015,4})		//Total dos Custos com Salarios/Ordenados
aadd(aStru,{"ENCARGO"		,"N",015,4})		//Total dos Custos com Encargos Sociais e Trabalhistas
aadd(aStru,{"TP_DCRE"		,"C",001,0})		//Tipo de DCRE: N-Novo, R-Retificador e S-Substituto
aadd(aStru,{"DCRE_ANT"		,"C",010,0})		//Numero do DCRE Anterior que esta sendo Retificado ou Substituido
aadd(aStru,{"PROCESSO"		,"C",017,0})		//Numero do Processo Retificador
aadd(aStru,{"VERSAO"		,"C",004,0})		//Versao
aadd(aStru,{"ORIDCRE"		,"C",001,0})		//Origem do DCRE
aadd(aStru,{"TP_COEFIC"		,"C",001,0})		//Tipo do coeficiente da DCRE

oTmpR00:= FWTemporaryTable():New("R00", aStru )
oTmpR00:Create()

//Registro Tipo 1 - Informacoes sobre os Modelos diferentes do Produto 
aStru	:= {}
cArq	:= ""
aadd(aStru,{"CODPROD"		,"C",nTamCod,0})	//Codigo do Produto
aadd(aStru,{"MODELO"		,"C",004,0})		//Modelo
aadd(aStru,{"DESCRICAO"		,"C",080,0})		//Descricao do Produto
aadd(aStru,{"PRC_VENDA"		,"N",015,2})		//Preco de Venda

oTmpR01:= FWTemporaryTable():New("R01", aStru )
oTmpR01:Create()

//Registro Tipo 2 - Informacoes sobre Componentes Nacionais  
aStru	:= {}
cArq	:= ""
aadd(aStru,{"CODPROD"		,"C",nTamCod,0})	//Codigo do Produto
aadd(aStru,{"NUMERO"		,"C",004,0})		//Numero do Componente Nacional dentro do arquivo
aadd(aStru,{"NF"			,"C",010,0})
aadd(aStru,{"SERIE"			,"C",005,0})
aadd(aStru,{"CNPJ"			,"C",014,0})		//CNPJ do fornecedor
aadd(aStru,{"IE"			,"C",015,0})		//IE do fornecedor
aadd(aStru,{"DATAEMIS"		,"D",008,0})		//Data de Entrada da NF
aadd(aStru,{"DESCPROD"		,"C",080,0})		//Especificacao do Produto
aadd(aStru,{"UNIDADE"		,"C",080,0})
aadd(aStru,{"NCM"			,"C",008,0})
aadd(aStru,{"QTDE"			,"N",015,7})
aadd(aStru,{"CUSTO_UNIT"	,"N",015,6})

oTmpR02:= FWTemporaryTable():New("R02", aStru )
oTmpR02:AddIndex( "Ind01" , {"CODPROD"} )
oTmpR02:Create()

//Registro Tipo 3 - Informacoes sobre Subcomponentes Importados 
aStru	:= {}
cArq	:= ""
aadd(aStru,{"CODPROD"		,"C",nTamCod,0})	//Codigo do Produto
aadd(aStru,{"NROSUB"		,"C",004,0})		//Numero do Subcomponente Nacional dentro do arquivo
aadd(aStru,{"NUMERO"		,"C",004,0})		//Numero do Componente Nacional dentro do arquivo
aadd(aStru,{"INCLUI_BC"		,"C",001,0})		//Indicador de Inclusao deste componente no calculo do II N-Nao ou S-Sim
aadd(aStru,{"IMP_DIR"		,"C",001,0})		//Indicador importacao Direta
aadd(aStru,{"INDIC_SUSP"	,"C",001,0})		//Indicador de utilizacao do regime com suspensao de impostos durante a importacao N-Nao ou S-Sim
aadd(aStru,{"DI"			,"C",010,0})
aadd(aStru,{"NUM_ADICAO"	,"C",003,0})		//Numero de Adicao
aadd(aStru,{"NUM_ITEM"		,"C",002,0})
aadd(aStru,{"NF"			,"C",010,0})
aadd(aStru,{"SERIE"			,"C",005,0})
aadd(aStru,{"CNPJ"			,"C",014,0})
aadd(aStru,{"IE"			,"C",015,0})
aadd(aStru,{"DATAEMIS"		,"D",008,0})
aadd(aStru,{"DESCPROD"		,"C",080,0})		//Especificacao do Produto
aadd(aStru,{"UNIDADE"		,"C",080,0})
aadd(aStru,{"NCM"			,"C",008,0})
aadd(aStru,{"QTDE"			,"N",015,7})
aadd(aStru,{"IND_RED_II"	,"C",001,0})		//Indicador de utilizacao de coeficiente de reducao II N-Nao ou S-Sim
aadd(aStru,{"CUSTO_UNIT"	,"N",015,6})		//Custo Unitario do componente em US$(Dolar)

oTmpR03:= FWTemporaryTable():New("R03", aStru )
oTmpR03:AddIndex( "Ind01" , {"CODPROD"} )
oTmpR03:Create()

//Registro Tipo 4 - Informacoes sobre Componentes Importados 
aStru	:= {}
cArq	:= ""
aadd(aStru,{"CODPROD"		,"C",nTamCod,0})	//Codigo do Produto
aadd(aStru,{"NUMERO"		,"C",004,0})		//Numero do Componente Nacional dentro do arquivo
aadd(aStru,{"IMP_DIR"		,"C",001,0})		//Indicador importacao Direta
aadd(aStru,{"INDIC_SUSP"	,"C",001,0})
aadd(aStru,{"DI"			,"C",010,0})
aadd(aStru,{"NUM_ADICAO"	,"C",003,0})
aadd(aStru,{"NUM_ITEM"		,"C",002,0})
aadd(aStru,{"NF"			,"C",010,0})
aadd(aStru,{"SERIE"			,"C",005,0})
aadd(aStru,{"CNPJ"			,"C",014,0})
aadd(aStru,{"IE"			,"C",015,0})
aadd(aStru,{"DATAEMIS"		,"D",008,0})
aadd(aStru,{"DESCPROD"		,"C",080,0})
aadd(aStru,{"UNIDADE"		,"C",080,0})
aadd(aStru,{"NCM"			,"C",008,0})
aadd(aStru,{"QTDE"			,"N",015,7})
aadd(aStru,{"ALIQUOTA"		,"N",005,2})
aadd(aStru,{"IND_RED_II"	,"C",001,0})
aadd(aStru,{"CUSTO_UNIT"	,"N",015,6})		//Custo Unitario do componente em US$(Dolar)

oTmpR04:= FWTemporaryTable():New("R04", aStru )
oTmpR04:AddIndex( "Ind01" , {"CODPROD"} )
oTmpR04:Create()

return nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} AltEstru
Alteracao dos Arquivos para geracao do DCRE

@author Edstron E. Correia        
@since 26.04.05
@version 1.0
/*/
//-----------------------------------------------------------------------
static function AltEstru(nOpc)

local oDlg
local aArea		:= GetArea()
local aAltera	:= {}
local cReg		:= ""
local nTamCod	:= TamSx3("B1_COD")[1]

private aHeader	:= {}
private aRotina := { {"Pesquisar","AxPesqui",0,1},{"Alterar","AltEstru",0,4,2}}
Default lAutoMacao := .F.  

if nOpc==1
	cReg := "R02"
	aAltera	:= {'CODPROD','NUMERO','NF','SERIE','CNPJ','IE','DATAEMIS','DESCPROD','UNIDADE','NCM','QTDE','CUSTO_UNIT'}
	aadd(aHeader,{ 'Codigo do Produto',	'CODPROD',"@!",nTamCod,0,"","",'C','R02',"" } )
	aadd(aHeader,{ 'Numero da Nota','NF',"@!",05,0,"","",'C','R02',"" } )
	aadd(aHeader,{ 'Serie','SERIE',"@!",05,0,"","",'C','R02',"" } )
	aadd(aHeader,{ 'CNPJ','CNPJ',"@!",14,0,"","",'C','R02',"" } )
	aadd(aHeader,{ 'IE','IE',"@!",15,0,"","",'C','R02',"" } )
	aadd(aHeader,{ 'Dt.Emissao','DATAEMIS',"@D",08,0,"","",'C','R02',"" } )
	aadd(aHeader,{ 'Unidade','UNIDADE',"@!",80,0,"","",'C','R02',"" } )
	aadd(aHeader,{ 'NCM','NCM',"@!",08,0,"","",'C','R02',"" } )
	aadd(aHeader,{ 'Quantidade','QTDE',"@E 999,999,999.999999",15,6,"","",'N','R02',"" } )
	aadd(aHeader,{ 'Custo Unitario','CUSTO_UNIT',"@E 999,999,999.9999",15,4,"","",'N','R02',"" } )
else
	if nOpc==2
		cReg := "R03"
	else
		cReg := "R04"
	endif
	aAltera	:= {"CODPROD","TIPO_DOC","INDIC_SUSP","DI","NUM_ADICAO","NUM_ITEM","NF","SERIE","CNPJ","IE","DATAEMIS","DESCPROD","UNIDADE","NCM","QTDE","ALIQUOTA","IND_RED_II","CUSTO_UNIT"}
	aadd(aHeader,{ 'Codigo do Produto','CODPROD',"@!",nTamCod,0,"","",'C',cReg,"" } )
	aadd(aHeader,{ 'Indicador Suspensao','INDIC_SUSP',"@!",01,0,"","",'C',cReg,"" } )
	aadd(aHeader,{ 'Número da DI','DI',"@!",10,0,"","",'C',cReg,"" } )
	aadd(aHeader,{ 'Número da Adição','NUM_ADICAO',"@!",03,0,"","",'C',cReg,"" } )
	aadd(aHeader,{ 'Número do Item da Adição','NUM_ITEM',"@!",02,0,"","",'C',cReg,"" } )
	aadd(aHeader,{ 'Numero da Nota','NF',"@!",10,0,"","",'C',cReg,"" } )
	aadd(aHeader,{ 'Serie','SERIE',"@!",05,0,"","",'C',cReg,"" } )
	aadd(aHeader,{ 'CNPJ','CNPJ',"@!",14,0,"","",'C',cReg,"" } )
	aadd(aHeader,{ 'IE','IE',"@!",15,0,"","",'C','R04',"" } )
	aadd(aHeader,{ 'Dt.Emissao','DATAEMIS',"@D",08,0,"","",'C',cReg,"" } )
	aadd(aHeader,{ 'Descr.Produto','DESCPROD',"@!",80,0,"","",'C',cReg,"" } )
	aadd(aHeader,{ 'Unidade','UNIDADE',"@!",80,0,"","",'C',cReg,"" } )
	aadd(aHeader,{ 'NCM','NCM',"@!",08,0,"","",'C',cReg,"" } )
	aadd(aHeader,{ 'Quantidade','QTDE',"@E 999,999,999.999999",15,6,"","",'N',cReg,"" } )
	aadd(aHeader,{ 'Aliquota II','ALIQUOTA',"@E 999.99",05,2,"","",'N',cReg,"" } )
	aadd(aHeader,{ 'Indicador Redução','IND_RED_II',"@!",01,0,"","",'C',cReg,"" } )
	aadd(aHeader,{ 'Custo Unitario','CUSTO_UNIT',"@E 999,999,999.9999",15,4,"","",'N',cReg,"" } ) 
endif

dbselectarea(cReg)
dbsetorder(0)

aSize   := MsAdvSize()
nOpcx   := 2
aObjects:= {}

aadd( aObjects, { 100, 100, .t., .t. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

IF !lAutoMacao
	DEFINE MSDIALOG oDlg TITLE OemtoAnsi("Alteração de Informaçoes DCRE - Registro Tipo "+Str(nOpc+1,1)) From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	oGetDb := MsGetDB():New(aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4],nOpcx,,,,,aAltera,,,LastRec(),cReg)
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,oDlg:End()},{||oDlg:End()})
ENDIF

RestArea(aArea)
return(.t.)

//-----------------------------------------------------------------------
/*/{Protheus.doc} SelOpc
Funcao de selecao da opcao de baixa, permite baixar a apropriacao erronea

@author Gustavo G. Rueda         
@since 01/07/04
@version 1.0
/*/
//-----------------------------------------------------------------------
static function SelOpc()

local oTipo	
local aRet   := {}
local nOpcao := 1
local nOpcBt := 1
Default lAutoMacao := .F.


	IF !lAutoMacao	
		DEFINE MSDIALOG oSelOpcDlg FROM 325,396 TO 559,612 TITLE OemToAnsi("Manutenção TXT - DCRE") PIXEL
		@ 05, 05 TO 115, 105 OF oSelOpcDlg PIXEL
		@ 11, 25 RADIO oTipo VAR nOpcao PROMPT OemToAnsi("Registro Tipo 2"),OemToAnsi("Registro Tipo 3"),OemToAnsi("Registro Tipo 4") OF oSelOpcDlg PIXEL SIZE 75,12
		@ 40, 10 TO 110, 100 OF oSelOpcDlg PIXEL
		@ 45, 15 SAY OemToAnsi ("As alterações efetuadas nos ") OF oSelOpcDlg PIXEL
		@ 55, 15 SAY OemToAnsi ("registros Tipo 2 , 3 e 4 do ") OF oSelOpcDlg PIXEL
		@ 65, 15 SAY OemToAnsi ("DCRE serão efetuadas somente") OF oSelOpcDlg PIXEL
		@ 75, 15 SAY OemToAnsi ("nas tabelas temporárias.") OF oSelOpcDlg PIXEL 
		DEFINE SBUTTON FROM 92,11 TYPE 02 ACTION (nOpcBt := 1, oSelOpcDlg:End()) ENABLE OF oSelOpcDlg
		DEFINE SBUTTON FROM 92,70 TYPE 01 ACTION (nOpcBt := 2, oSelOpcDlg:End()) ENABLE OF oSelOpcDlg
		ACTIVATE MSDIALOG oSelOpcDlg CENTERED
	ENDIF
	if nOpcBt == 1
		nOpcao := 4
	endif
	aRet := {nOpcao}
return (aRet)

function PesqDCRE()
return(.t.)

//-----------------------------------------------------------------------
/*/{Protheus.doc} DCREOP
Retorna os componentes utilizados na OP selecionada no Pergunte (caso uma OP não seja selecionada, essa função não será executada e o programa utilizará a Estrutura do Produto - Tabela SG1).

@Param  cOP      = OP selecionada no Pergunte
		dDataDe  = Modo de Execução
		dDataAte = Release Corrente do Cliente
@Return aProdQtd = Array contendo: [1]=Quantidade utilizada / [2]=Código Componente

@author Ulisses P. Oliveira      
@since 26.12.2017
@version 1.0
/*/
//-----------------------------------------------------------------------
Static Function DCREOP(cProd,cOP,dDataDe,dDataAte)
Local aProdQtd :={}
Local cQuery   :=""
Local cAliasTmp:=GetNextAlias()

Default cOP     := ''
Default dDataDe := CtoD("  /  /    ")
Default dDataAte:= CtoD("  /  /    ")

If !Empty(cOP)
	cOP	   := Left(cOP,TamSx3("C2_NUM")[1])

	cQuery := "SELECT SD3.D3_COD, "
    cQuery += "       SUM(CASE WHEN SD3.D3_CF LIKE ('DE%') THEN (SD3.D3_QUANT*-1) "
    cQuery += "                WHEN SD3.D3_CF LIKE ('RE%') THEN (SD3.D3_QUANT) " 
    cQuery += "                ELSE                        0  "
    cQuery += "       END) D3_QUANT "
    cQuery += "FROM "+RetSQLName("SD3")+" SD3 JOIN "+RetSQLName("SB1")+" SB1 ON (SB1.B1_FILIAL='"+xFilial('SB1')+"' AND SB1.B1_COD=SD3.D3_COD                                         AND SB1.D_E_L_E_T_='') "
    cQuery += "                               JOIN "+RetSQLName("SC2")+" SC2 ON (SC2.C2_FILIAL='"+xFilial('SC2')+"' AND SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN+SC2.C2_ITEMGRD=SD3.D3_OP AND SC2.D_E_L_E_T_='') "
    cQuery += "WHERE SD3.D3_FILIAL='"+xFilial('SD3')+"'                            AND "
    cQuery += "SC2.C2_NUM='"+cOP+"'                                                AND "
    cQuery += "SD3.D3_ESTORNO=''                                                   AND "
    cQuery += "SC2.C2_ITEM  <>'OS'                                                 AND "
    cQuery += "SD3.D3_OP<>''                                                       AND "
    cQuery += "(SD3.D3_CF LIKE 'RE%' OR SD3.D3_CF LIKE 'DE%')                      AND "
    cQuery += "SD3.D3_EMISSAO BETWEEN '"+DtoS(dDataDe)+"' AND '"+DtoS(dDataAte)+"' AND "
    cQuery += "SD3.D_E_L_E_T_ = '' "
    cQuery += "GROUP BY SD3.D3_COD "
    cQuery += "HAVING (SUM(CASE WHEN SD3.D3_CF LIKE ('DE%') THEN (SD3.D3_QUANT*-1) WHEN SD3.D3_CF LIKE ('RE%') THEN (SD3.D3_QUANT) ELSE 0 END))>0 "
    cQuery += "ORDER BY SD3.D3_COD "

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)
	
	While !(cAliasTmp)->(Eof())
		Aadd( aProdQtd ,{(cAliasTmp)->D3_QUANT, (cAliasTmp)->D3_COD})
		(cAliasTmp)->(DbSkip())
	EndDo
	
	(cAliasTmp)->(DbCloseArea())
	
EndIf 

Return(aProdQtd)
