#Include "Plsmger.ch"
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "Colors.ch"
#Include "Plsm250.ch"

#define __aCdCri231 {"0A4","Redu็ใo de custo."} 

STATIC ltpApli	:= B65->(fieldPos("B65_TPAPLI")) > 0

/*	
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSM250   บAutor  ณMicrosiga           บ Data ณ  02/02/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina implementada p/ aplicar reducao do custo operacional บฑฑ
ฑฑบ          ณ de procedimento medico de acordo com o item 4.2 das instru-บฑฑ
ฑฑบ          ณ coes gerais da CBHPM 5a edicao                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPLS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PLSM250()
Local aSays        := {}
Local aButtons     := {}
Local cCadastro    := STR0001 //Reducao do custo de procedimentos
Private cPerg      := "PLSM250   "
Private aRecProc   := {}  
Private aEvePacote := {}

//Validacao
If !PLSALIASEXI("B65")
	MsgAlert(STR0011 ) //"Nใo ้ possํvel utilizar esta rotina! (Execute o compatibilizador da rotina)" 
	Return                                                  
EndIf

//Monta texto para janela de processamento                                 
aAdd(aSays,STR0002)//Aplicacao de reducao de custo nas contas medicas

//Monta botoes para janela de processamento                                
aAdd(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T.)}})
aAdd(aButtons, { 1,.T.,{|| MsAguarde({|| PLSM250Pro(cPerg)}, "", "Processando", .T.),FechaBatch()}}) //Processamento
aAdd(aButtons, { 2,.T.,{|| FechaBatch()}})

//Exibe janela de processamento                                            ณ
FormBatch(cCadastro, aSays, aButtons, , 160)


Return	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSM250ProบAutor  ณMicrosiga           บ Data ณ  02/02/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Processamento da reducao de custo dos procedimentos pagos  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPLS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
function PLSM250Pro(cPerg, lMudFas, cOrigem, aInfRed, lExbMsg)
local cRdaDe   	:= ""
local cRdaAte  	:= ""
local cDtPrDe  	:= ""
local cDtPrAte 	:= ""
local cCodGrp  	:= ""
local cCodInt  	:= ""
local cMatric  	:= ""
local cRda	   	:= ""
local cData	   	:= ""
local cProPrin 	:= "" // Codigo do procedimento principal
local cPrPriBk 	:= "" // Codigo do procedimento principal anterior
local cGrupMF	:= ""
local nRetGrp  	:= 0
local nNumGrp  	:= 0  // Numero de grupos de redu็ใo cadastrados
local aPerPrin 	:= {} // Array com a alteracao do percentual principal
local aRetGrp  	:= {} // Grupo redutor e itens
local aAtuGrp  	:= {} // BD7s com seus percentuais a serem atualizados
Local nEND			:= 0
Local aAtuCOP		:= {}

default lMudFas	:= .f.//Quando aplicado via mudan็a de fase
default lExbMsg	:= .f.

pergunte(cPerg,.f.)  

cRdaDe	:= mv_par01
cRdaAte	:= mv_par02
cDtPrDe	:= iIf( valtype(mv_par03) == 'D',dtos(mv_par03),mv_par03)
cDtPrAte:= iIf( valtype(mv_par04) == 'D',dtos(mv_par04),mv_par04)
cCodGrp	:= iIf( ! empty(MV_PAR05), allTrim(MV_PAR05), "") 
cCodInt	:= plsIntPad()

//Carrego os procedimentos do grupo redutor
aRetGrp	:= iIf(!lMudFas, grupRedut(cCodGrp,cCodInt,cDtPrDe,cDtPrAte,lMudFas), {})

// Se nao tenho nenhum procedimento no grupo ja abandono o processamento
if ! lMudFas .and. ! aRetGrp[1] 
	nEND := 1
endIf

If Select("TRBBD7") > 0
	TRBBD7->(dbCloseArea())
EndIf

if ! lMudFas .AND. nEND == 0

	if ! cargaBD7(cRdaDe,cRdaAte,cDtPrDe,cDtPrAte) 
		nEND := 2
	endIf
	
	If nEND == 0
		aRetGrp := grupRedut(cCodGrp,cCodInt,cDtPrDe,cDtPrAte,lMudFas,PlsMntGRed())
	EndIf
	
elseif nEND == 0
	//RDA - Cod Operadora - Cod. Emrpesa - Matricula - TipReg - Data		
	if ! plsBD7Red(cOrigem, aInfRed[1,1], aInfRed[2,1], aInfRed[3,1], aInfRed[4,1], aInfRed[5,1], aInfRed[6,1], aInfRed[7,1], aInfRed[8,1], nil, aInfRed[9,1])	
		nEND := 3
	endIf
	
	if nEND == 0
		aRetGrp := grupRedut('',cCodInt,"",cDtPrAte,lMudFas,PlsMntGRed())
	endIf
endIf

if nEND == 0
	//inicia a reducao 
	for nNumGrp := 2 to len(aRetGrp)

		cPrPriBk := ""
		cProPrin := ""
		cGrupo   := ""
		
		// percorro todos os procedimentos encontrados no grupo redutor
		for nRetGrp := 7 to len(aRetGrp[nNumGrp]) 
		
			While ! TRBBD7->(eof())
			
	 			If ! lMudFas
	 			
	 				//Verifica se o procedimento pertence ao grupo
					if ! PertGrp(TRBBD7->(BD7_CODPAD+BD7_CODPRO),aRetGrp[nNumGrp]) 
						TRBBD7->(dbSkip())
						Loop
					endIf
					
				Else
				
					if ! (TRBBD7->(B65_CODIGO) == aRetGrp[nNumGrp,4])
						TRBBD7->(dbSkip())
						Loop
					endIf
						
				endIf		
	
				If cMatric <> TRBBD7->(BD7_OPEUSR+BD7_CODEMP+BD7_MATRIC+BD7_TIPREG) .or. cRda <> TRBBD7->(BD7_CODRDA) .or. cData <> TRBBD7->BD7_DATPRO .Or. cGrupo <> aRetGrp[nNumGrp][4]
				   
					IniChvGrp(@cMatric,@cRda,@cData,@cProPrin)
					
					cGrupo := aRetGrp[nNumGrp][4]
					
					//Evitar repeti็ใo de um mesmo grupo
					iIf(cGrupo $ cGrupMF, "", cGrupMF += cGrupo + ",") 
					
					//Verifica quando mudar o procedimento principal, se existe BD6_QTDPRO > 1
					//para criar um divisor do Percentual Principal. Isto porque somente a   	
					//primeira quantidade tera o percentual principal. Exemplo:				
					//Proc.Princ.  Perc=[100%:70%] e Qtd=4 --> Perc=(100+70+70+70)/4 = [77,5] 
					if cPrPriBk <> cProPrin 
					
						cPrPriBk := cProPrin
						aPerPrin := PercPrinc(TRBBD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN+BD7_CODPAD+BD7_CODPRO),aRetGrp[nNumGrp])
					 	
					 	If aPerPrin[1]
		             		aRetGrp[nNumGrp][5] := .T.
					 		aRetGrp[nNumGrp][6] := aPerPrin[2]
					 	Else
					 		aRetGrp[nNumGrp][5] := .F.	
				 			aRetGrp[nNumGrp][6] := aPerPrin[2]
					 	EndIf
					 	
					Else  
					
		   				aPerPrin := PercPrinc(TRBBD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN+BD7_CODPAD+BD7_CODPRO),aRetGrp[nNumGrp])
					 	
					 	If aPerPrin[1]
		             		aRetGrp[nNumGrp][5] := .T.
					 		aRetGrp[nNumGrp][6] := aPerPrin[2]
					 	Else
					 		aRetGrp[nNumGrp][5] := .F.	
				 			aRetGrp[nNumGrp][6] := aPerPrin[2]
					 	EndIf		
					 		
		            EndIf
		            
				EndIf
		
				//Se eu encontrar o procedimento e a unidade de medida no grupo, vou aplicar o percentual redutor para este item
				If TRBBD7->(BD7_CODPAD+BD7_CODPRO) == aRetGrp[nNumGrp][nRetGrp,1]+aRetGrp[nNumGrp][nRetGrp,2] .and. allTrim(TRBBD7->(BD7_CODUNM)) $ allTrim(aRetGrp[nNumGrp][nRetGrp,3])
					
					If cProPrin == TRBBD7->(BD7_CODPAD+BD7_CODPRO)
					
						If aRetGrp[nNumGrp][5] .and. aRetGrp[nNumGrp][6] == aRetGrp[nNumGrp][2] 	// Primeira vez que passa por este procedimento com M้dia
		
							aAdd(aAtuGrp,{	.t.,;      				// Evento principal .T. = Sim
											TRBBD7->R_E_C_N_O_,; 	// Recno BD7
											aRetGrp[nNumGrp][2]})   // B66_PERPRI - Percentual a ser aplicado    
								
								aRetGrp[nNumGrp][5] := .F. 		 	// Declaro que jแ calculou M้dia alguma vez
								
								
						ElseIf ! aRetGrp[nNumGrp][5] .and. aRetGrp[nNumGrp][6] <> aRetGrp[nNumGrp][2] 	// Primeira vez que passa por este procedimento sem M้dia
							
							aAdd(aAtuGrp,{	.t.,;      				// Evento principal .T. = Sim
											TRBBD7->R_E_C_N_O_,; 	// Recno BD7
											aRetGrp[nNumGrp][6]})   // B66_PERPRI - Percentual a ser aplicado*/  
											aRetGrp[nNumGrp][6] := aRetGrp[nNumGrp][2]   // Retorno o  Valor 
						
						// Segunda ou mais vezes que passa por este procedimento e jแ teve M้dia
						Else
						
							aAdd(aAtuGrp,{	.f.,;      				// Evento principal .T. = Sim
											TRBBD7->R_E_C_N_O_,; 	// Recno BD7
											aRetGrp[nNumGrp][3]})   // B66_PERPRI - Percentual a ser aplicado
						
						endIf
					Else
	
						aAdd(aAtuGrp,{	.f.,;					// Evento principal .F. = Nao
										TRBBD7->R_E_C_N_O_,;	// Recno BD7
										aRetGrp[nNumGrp][3]}) 	// B66_PERSUB - Percentual a ser aplicado
	
					endIf
	
				endIf
		
				TRBBD7->(dbSkip())
		
			endDo
			
			TRBBD7->(dbGoTop()) 
		
		next
		
		TRBBD7->(dbGoTop()) 

	next
	TRBBD7->(dbCloseArea())	
endIf

If ltpApli
	
	If !lMudFas
		//redu็ใo de coparticipa็ใo de intercโmbio... sim.. isso mesmo...
		aAtuCOP := PlRedCopar(cRdaDe, cRdaAte, cDtPrDe, cDtPrAte, cCodGrp, cCodInt)
		//atualiza os flags
		If Len(aAtuCOP) > 0
			PlMrkCopar(aAtuCOP)
			nEND := 0
		EndIf
	else
		aDatas := PlDataProc(cCodInt, BCI->BCI_CODLDP, aInfRed[6,1], aInfRed[7,1])
		//redu็ใo de coparticipa็ใo de intercโmbio... sim.. isso mesmo...
		aAtuCOP := PlRedCopar(BCI->BCI_CODRDA, BCI->BCI_CODRDA, aDatas[1,1], aDatas[1,2], cCodGrp, cCodInt, .T.)
		//atualiza os flags
		If Len(aAtuCOP) > 0
			PlMrkCopar(aAtuCOP)
			nEND := 0
		EndIf
	endIf
endIf

if nEND > 0
	If nEND == 1
		msgInfo(STR0003)
		return .f.
	elseIf nEND == 2
		msgInfo(STR0004) //"Nenhuma movimenta็ใo encontrada para ser processada."
		return .f.
	elseIf nEND == 3
		return .F.
	EndIf
EndIf

if len(aAtuGrp) > 0

	Pl250Atu(aAtuGrp)
	
	if !lMudFas
	
		cMsg := STR0012 + CHR(13)+CHR(10) +; //"Fator redutor de custo aplicado as movimenta็๕es de acordo com os parโmetros: "
				STR0013 + cRdaDe   + CHR(13)   + CHR(10) +; //"Rede Atend. de: "
				STR0014 + cRdaAte  + CHR(13)   + CHR(10) +; //"Rede Atend. at้: "
			 	STR0015 + DTOC(STOD(cDtPrDe))  + CHR(13) + CHR(10) +; //"Data movto. de: "
			 	STR0016 + DTOC(STOD(cDtPrAte)) + CHR(13) + CHR(10) +; //"Data movto. at้: "
			 	STR0017 + cCodGrp + CHR(13) + CHR(10) + CHR(13) + CHR(10) +; //"Grupo redutor: "
			 	STR0018 //"Processamento finalizado!"
	else
	
		cMsg := STR0009 + CRLF //Grupo(s) Redutor(es) aplicado(s) com sucesso!
		cMsg += STR0010 + SUBSTR(cGrupMF, 1, (Len(cGrupMF)-1) ) //"Grupos encontrados: "
		
	endIf
	
else
	cMsg := STR0019 //"Nenhuma movimenta็ใo para ser atualizada."
endIf
		 
if !lMudFas
	
	MsgInfo(cMsg)
	
elseIf (lMudFas .AND. (Len(aAtuGrp) > 0 .OR. len(aAtuCOP) > 0) .AND. lExbMsg )
	
	MsgInfo(cMsg)
		
endIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGrupRedut บAutor  ณMicrosiga           บ Data ณ  02/07/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao criada para retornar os percentuais e procedimentos  บฑฑ
ฑฑบ          ณdo grupo redutor passado como parametro                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณaRetGrp[1] - .T.  	  - Foi encontrado o grupo redutor    บฑฑ
ฑฑบ          ณaRetGrp[2] - B65_PERPRI - Percentual para o evento principalบฑฑ
ฑฑบ          ณaRetGrp[3] - B65_PERSUB - Percentual p/ eventos subsequentesบฑฑ
ฑฑบ          ณaRetGrp[4] - B65_CODIGO - Codigo do grupo redutor           บฑฑ
ฑฑบ          ณaRetGrp[5] - .T.		  - Grupo redutor principal			  บฑฑ
ฑฑบ          ณaRetGrp[6] - 0 		  - M้dia do grupo redutor principal  บฑฑ
ฑฑบ          ณaRetGrp[7,1] - B66_CODTAB - Tipo de Tabela                  บฑฑ
ฑฑบ          ณaRetGrp[7,2] - B66_CODPSA - Codigo do procedimento          บฑฑ
ฑฑบ          ณaRetGrp[7,3] - B66_LISUNM	- Unidades de medida              บฑฑ
ฑฑบ          ณaRetGrp[7,4] - B65_CODIGO - Codigo do grupo redutor         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPLS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GrupRedut(cCodGrp,cCodInt,cDtPrDe,cDtPrAte,lMudFas, aArDad)
Local aRetGrp := {.F.}
Local cSqlGrp := ""
Local cStmGrp := ""
Local cTabB65 := RetSqlName("B65")
Local cTabB66 := RetSqlName("B66")

Local aGruRed := {.F.,0,0,0,.T.,0}
Local cCodGru := ""
Default aArDad:= {}

cSqlGrp := " SELECT B65_CODIGO, B65_PERPRI, B65_PERSUB, B66_CODTAB, B66_CODPSA, B66_LISUNM"
cSqlGrp += "   FROM " + cTabB65 + ", " + cTabB66
cSqlGrp += "  WHERE B65_FILIAL = '" + xFilial("B65") + "' "
cSqlGrp += "    AND B66_FILIAL = '" + xFilial("B66") + "' "
cSqlGrp += "    AND B65_CODINT = '" + cCodInt + "' "
If ltpApli
	cSqlGrp += "    AND B65_TPAPLI <> '1' "
endIf
cSqlGrp += "    AND " + cTabB65 + ".D_E_L_E_T_ = ' ' "
cSqlGrp += "    AND " + cTabB66 + ".D_E_L_E_T_ = ' ' "

if !lMudFas
	
	cSqlGrp += " AND B65_CODIGO = B66_CODIGO "
	cSqlGrp += " AND B65_CODIGO IN ('" + strTran(cCodGrp,",","','") + "') "
	cSqlGrp += " AND ( B66_VIGDE  >= '" + cDtPrDe + "' AND B66_VIGATE <= '" + cDtPrAte + "'  OR "
	cSqlGrp += "      B66_VIGDE  <= '" + cDtPrDe + "' AND B66_VIGATE = ' ') "
	
	if (len(aArDad) > 0)
		cSqlGrp += " AND  B65_CODIGO IN ("  + aArDad[1] + ") " 
		cSqlGrp += " AND  B66_CODTAB IN ("  + aArDad[2] + ") " 
		cSqlGrp += " AND  B66_CODPSA IN ("  + aArDad[3] + ") " 	
	endIf
	
//Se na mudan็a de fase, verificar quais nใo tem vig๊ncia fechada e que estใo sinalizados para serem usados na MF
else  
	
	cSqlGrp += " AND B65_CODIGO = B66_CODIGO "
	cSqlGrp += " AND B66_VIGATE = '' "
	cSqlGrp += " AND B65_AUTOMA = '1' "
	cSqlGrp += " AND B65_CODIGO IN ("  + aArDad[1] + ") " 
	cSqlGrp += " AND B66_CODTAB IN ("  + aArDad[2] + ") " 
	cSqlGrp += " AND B66_CODPSA IN ("  + aArDad[3] + ") "
	 	
endIf	

cSqlGrp += " ORDER BY  B65_CODIGO, B66_CODPSA, B65_PERPRI, B65_PERSUB, B66_CODTAB, B66_LISUNM "

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cSqlGrp)),"TRBGRP",.F.,.T.)

cCodGru := TRBGRP->B65_CODIGO

while !TRBGRP->(eof())

	if !aRetGrp[1]
		aRetGrp[1] := .t.
	endIf
	
	if !aGruRed[1]
		aGruRed[1] := .t.
		aGruRed[2] := TRBGRP->B65_PERPRI
		aGruRed[3] := TRBGRP->B65_PERSUB
		aGruRed[4] := TRBGRP->B65_CODIGO
		aGruRed[5] := .t.
		aGruRed[6] := TRBGRP->B65_PERPRI
	endIf	
	
	aadd(aGruRed,{TRBGRP->B66_CODTAB,TRBGRP->B66_CODPSA,TRBGRP->B66_LISUNM,TRBGRP->B65_CODIGO,.F.,0})

	TRBGRP->(dbSkip())
	
	if TRBGRP->(eof()) .OR. cCodGru <> TRBGRP->B65_CODIGO
	
		aadd(aRetGrp,aGruRed)
		if !TRBGRP->(eof())
			aGruRed := {.f.,0,0,0,.t.,0}
			cCodGru := TRBGRP->B65_CODIGO
		endIf
	
	endIf
	
endDo

TRBGRP->(dbCloseArea())

return aRetGrp

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |CargaBD7  บAutor  ณMicrosiga           บ Data ณ  02/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para carregar todos os BD7 que serao processados paraบฑฑ
ฑฑบ          ณ aplicacao do fator redutor                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPLS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CargaBD7(cRdaDe,cRdaAte,cDtPrDe,cDtPrAte, lMudFas, cMatric)
Local cPriGrp := getNewPar("MV_PLPRGRR","1") // Indica como deve ser escolhido o evento principal: 1=Maior Valor;2=Maior Porte;3=Sequencial dentro da Guia
Local cSqlBD7 := ""
Local cStmBD7 := ""
Local lRet	  := .F.
Local cRetTde := ''
Local lPL250A := ExistBlock("PLRCTABA") // ponto de entrada EVIDA
Local lPL250B := ExistBlock("PLRCTABB") // ponto de entrada EVIDA

if cPriGrp == '1'

	cSqlBD7 := " SELECT " + RetSqlName("BD7") + ".R_E_C_N_O_, BD7_OPEUSR, BD7_CODEMP, BD7_MATRIC, BD7_TIPREG, BD7_CODOPE, BD7_CODUNM, BD7_DATPRO, BD7_CODRDA, BD7_VLRPAG,BD7_CODPAD, "
	cSqlBD7 += " BD7_COEFUT, BD7_CODPEG, BD7_NUMERO, BD7_CODPRO, BD7_CODLDP, BD7_ORIMOV, BD7_SEQUEN, B65_CODIGO"
	cSqlBD7 += " FROM " +  RetSqlName("BD7")
	cSqlBD7 += " INNER JOIN " + RetSqlName("B66")
	cSqlBD7 += " ON BD7_CODPAD = B66_CODTAB AND BD7_CODPRO = B66_CODPSA "
	cSqlBD7 += " INNER JOIN " + RetSqlName("B65")
	cSqlBD7 += " ON B66_CODIGO = B65_CODIGO "
	
	// ponto de entrada EVIDA
	If lPL250A
		cSqlBD7 += ExecBlock("PLRCTABA",.F.,.F.,{ })	
	End If	
	
	cSqlBD7 += " WHERE BD7_FILIAL = '" + xFilial("BD7") + "' "
	cSqlBD7 += " AND  " + RetSqlName("BD7") + ".D_E_L_E_T_ <> '*' AND BD7_REDCUS <> '1' AND BD7_VLRPAG > 0 AND  BD7_CODUNM ='UCO' "
	cSqlBD7 += " AND BD7_CODRDA >= '" + cRdaDe + "' AND BD7_CODRDA <= '" + cRdaAte + "' "
	cSqlBD7 += " AND BD7_DATPRO >= '" + cDtPrDe + "' AND BD7_DATPRO <= '" + cDtPrAte + "' "
	cSqlBD7 += " AND BD7_FASE = '3' AND BD7_SITUAC = '1'" // Pronta e Ativa
	cSqlBD7 += " AND BD7_LIBERA <> '1' AND BD7_BLOPAG <> '1'" // Autorizacao e bloqueia pagto = NAO
	cSqlBD7 += " AND B66_FILIAL = '" + xFilial("B66") + "' AND " + RetSqlName("B66") + ".D_E_L_E_T_ = '' "
	cSqlBD7 += " AND B65_FILIAL = '" + xFilial("B65") + "' AND " + RetSqlName("B65") + ".D_E_L_E_T_ = '' "
	cSqlBD7 += " ORDER BY BD7_OPEUSR, BD7_CODEMP, BD7_MATRIC, BD7_TIPREG, BD7_DATPRO, BD7_CODRDA, BD7_VLRPAG DESC "
	
else

	cSqlBD7 := " SELECT DISTINCT " + RetSqlName("BD7") +".R_E_C_N_O_, BD7_OPEUSR, BD7_CODEMP, BD7_MATRIC, BD7_TIPREG, BD7_CODOPE, BD7_CODUNM, BD7_DATPRO, BD7_CODRDA, BD7_VLRPAG,BD7_CODPAD, " 
	cSqlBD7 += " BD7_COEFUT, BD7_CODPEG, BD7_NUMERO, BD7_CODPRO, BD7_CODLDP, BD7_ORIMOV, BD7_SEQUEN, PORTE, BD7_VLRBPR / BD6_QTDPRO VLRBPR, BD6_VLRAPR, B65_CODIGO "
	cSqlBD7 += " FROM " + retSqlName("BD7")
	cSqlBD7 += " INNER JOIN ( "
	
		cSqlBD7 += " SELECT BD7_CODOPE CODOPE, BD7_CODLDP CODLDP, BD7_CODPEG CODPEG, BD7_NUMERO NUMERO, BD7_SEQUEN SEQUEN, BD7_CODUNM CODUNM, BD7_COEFUT PORTE, BD7_VLRBPR VALOR_CONTRATADO "
		cSqlBD7 += " FROM " + RetSqlName("BD7") + " PPM "
		cSqlBD7 += " WHERE "
			cSqlBD7 += " PPM.D_E_L_E_T_ = ' ' "
			cSqlBD7 += " AND PPM.BD7_FILIAL = '" + xFilial("BD7") + "' "
			cSqlBD7 += " AND PPM.BD7_CODRDA >= '" + cRdaDe + "' AND PPM.BD7_CODRDA <= '" + cRdaAte + "' " 
			cSqlBD7 += " AND PPM.BD7_DATPRO >= '" + cDtPrDe + "' AND PPM.BD7_DATPRO <= '" + cDtPrAte + "' "
			cSqlBD7 += " AND PPM.BD7_FASE = '3' AND PPM.BD7_SITUAC = '1' " // Pronta e Ativa
			cSqlBD7 += " AND PPM.BD7_LIBERA <> '1' AND PPM.BD7_BLOPAG <> '1' " // Autorizacao e bloqueia pagto = NAO
			cSqlBD7 += " AND PPM.BD7_REDCUS <> '1' AND PPM.BD7_VLRPAG > 0 AND BD7_CODUNM = 'PPM' "
	
	cSqlBD7 += " ) PPM "
	cSqlBD7 += " ON CODOPE = BD7_CODOPE AND CODLDP = BD7_CODLDP AND CODPEG = BD7_CODPEG AND NUMERO = BD7_NUMERO AND SEQUEN = BD7_SEQUEN AND CODUNM = 'PPM' "
		
	//Inner join
	cSqlBD7+= " INNER JOIN " + RetSqlName("B66")
	cSqlBD7+= " ON BD7_CODPAD = B66_CODTAB AND BD7_CODPRO = B66_CODPSA "
	cSqlBD7+= " INNER JOIN " + RetSqlName("B65")
	cSqlBD7+= " ON B66_CODIGO = B65_CODIGO "
	
	//Inner Join	
	cSqlBD7 += " INNER JOIN " + RetSqlName("BD6")
	cSqlBD7 += " ON BD6_CODPEG = BD7_CODPEG AND BD6_NUMERO = BD7_NUMERO AND BD6_SEQUEN = BD7_SEQUEN AND BD6_CODLDP = BD7_CODLDP AND BD6_CODOPE = BD7_CODOPE "
	
	// ponto de entrada EVIDA
	If lPL250B
		cSqlBD7 += ExecBlock("PLRCTABB",.F.,.F.,{ })	
	End If	
	
	cSqlBD7 += " WHERE "
	cSqlBD7 += " " + RetSqlName("BD7") + ".D_E_L_E_T_ = ' ' "
	cSqlBD7 += " AND BD7_FILIAL = '" + xFilial("BD7") + "' "
	cSqlBD7 += " AND BD7_CODRDA >= '" + cRdaDe + "' AND BD7_CODRDA <= '" + cRdaAte + "' " 
	cSqlBD7 += " AND BD7_DATPRO >= '" + cDtPrDe + "' AND BD7_DATPRO <= '" + cDtPrAte + "' " 
	cSqlBD7 += " AND BD7_FASE = '3' AND BD7_SITUAC = '1' " // Pronta e Ativa
	cSqlBD7 += " AND BD7_LIBERA <> '1' AND BD7_BLOPAG <> '1' " // Autorizacao e bloqueia pagto = NAO
	cSqlBD7 += " AND BD7_REDCUS <> '1' AND BD7_VLRPAG > 0 AND  BD7_CODUNM = 'UCO' "
	cSqlBD7 += " AND B66_FILIAL = '" + xFilial("B66") + "' AND " + RetSqlName("B66") + ".D_E_L_E_T_ = '' "
	cSqlBD7 += " AND B65_FILIAL = '" + xFilial("B65") + "' AND " + RetSqlName("B65") + ".D_E_L_E_T_ = '' "	 
	cSqlBD7 += " ORDER BY BD7_OPEUSR, BD7_CODEMP, BD7_MATRIC, BD7_TIPREG, BD7_DATPRO, BD7_CODRDA, "
	cSqlBD7 += iIf(cPriGrp == '2',"PORTE DESC, VLRBPR DESC, BD6_VLRAPR DESC, BD7_SEQUEN","BD7_SEQUEN")

EndIf

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cSqlBD7)),"TRBBD7",.F.,.T.)

If TRBBD7->(Eof())
	TRBBD7->(dbCloseArea())
	lRet := .f.
Else
	lRet := .t.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |IniChvGrp บAutor  ณMicrosiga           บ Data ณ  02/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInicializa chave do grupo redutor, mesmo usuario, mesmo RDA บฑฑ
ฑฑบ          ณno mesmo dia                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPLS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function IniChvGrp(cMatric,cRda,cData,cProPrin)
cMatric := TRBBD7->(BD7_OPEUSR+BD7_CODEMP+BD7_MATRIC+BD7_TIPREG)
cRda 	:= TRBBD7->BD7_CODRDA
cData 	:= TRBBD7->BD7_DATPRO

If cProPrin != Nil
	cProPrin := TRBBD7->(BD7_CODPAD+BD7_CODPRO)
EndIf

Return

/*/{Protheus.doc} Pl250Atu
Lanca uma glosa para o item ( BD7 ) e aplica o fator redutor
@type function
@author PLS TEAM
@since 02/08/11
@version 1.0
/*/
static function Pl250Atu(aAtuGrp)
local aArea			:= getArea()
local nGrupo 		:= 0
local nPerGru		:= 0
local nRecBD7		:= 0
local nVlrGlo		:= 0
local nVlrAGlo		:= 0
local nPercDifa		:= getNewPar("MV_PLSDIFA", 0.00)
local aDadUsr   	:= PLSGETUSR()
local lCopPag 		:= iIf( len(aDadUsr) >= 72 , aDadUsr[72] == "1",.f.) 

PLSPOSGLO(PLSINTPAD(),__aCdCri231[1],__aCdCri231[2],"1")

BD6->( dbSetOrder(1))//BD6_FILIAL + BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO + BD6_ORIMOV + BD6_SEQUEN + BD6_CODPAD + BD6_CODPRO

for nGrupo := 1 to len(aAtuGrp)

	nRecBD7 := aAtuGrp[nGrupo,2]
	nPerGru := (100 - aAtuGrp[nGrupo,3])
	
	if nPerGru == 0
		loop
	endIf
					
	// atualizo o BD7 aplicando o fator redutor do grupo
	BD7->(dbGoto(nRecBD7))
	
	if BD6->( msSeek( xFilial("BD6") + BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN+BD7_CODPAD+BD7_CODPRO) ) )
		
		nVlrGlo	:= Round(( (BD7->BD7_VLRBPR * nPerGru) / 100 ),2)
		
		if BD6->BD6_VLRMAN > round( ( BD6->BD6_VLRBPR - nVlrGlo ), 2)  
			
			nVlrAGlo := BD6->BD6_VLRMAN - ( BD6->BD6_VLRBPR - nVlrGlo )
			nPerGru	 := ( nVlrAGlo / BD7->BD7_VLRMAN ) * 100
			
			if nVlrAGlo > nPercDifa
				plGloUND(__aCdCri231[1], PLSBCTDESC(), "PLSM250 - Redu็ใo de custo", lCopPag, nPerGru, .t., .t.)
			endIf	
			
		endIf
		
	endIf		

next	

restArea(aArea)

return

/*/{Protheus.doc} PLSGrpRed
F3 da listagem dos grupos redutores
@author Microsiga
@since 10/02/2011
@version P12
/*/
Function PLSGrpRed(cDado,lTela)

	Static objCENFUNLGP := CENFUNLGP():New()

Local cTitulo := STR0005
Local cSQL	  := ""
Local cStm	  := ""
Local nInd	  := 0
Local nPos	  := 0
Local nQtd	  := 0
Local bChk	  := {|| nQtd := PlsCntLst(aLista) }
Local aLista  := {}
Local aGrupos := {}
Local nOpca   := 0
Local bOK     := { || nOpca := K_OK, oDlg:End() }
Local bCancel := { || oDlg:End() }
Local oDlg
Local oGrupo
Local lRet := .F.
Default lTela 	:= .T.

//coloca virgula no comeco (caso tenha inicializador padrao)
cDado := AllTrim(cDado)
If Subs(cDado,Len(cDado),1) != "," .And. cDado != ""
	cDado += ","
EndIf

cSql := " SELECT B65_CODIGO,B65_DESCRI "
cSql += "   FROM "+ RetSQLName("B65")
cSql += "  WHERE B65_FILIAL = '" + xFilial("B65") + "' "
cSql += "  	 AND D_E_L_E_T_ <> '*' ORDER BY B65_CODIGO"

cStm := ChangeQuery(cSql)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cStm),"TRB",.F.,.T.)

While !TRB->( Eof() )
	aAdd( aGrupos , { TRB->B65_CODIGO,TRB->B65_DESCRI } )
	TRB->( DbSkip() )
EndDo
TRB->( DbCloseArea() )

For nInd := 1 To Len(aGrupos)
	aAdd( aLista , { aGrupos[nInd,1],aGrupos[nInd,2],If(aGrupos[nInd,1] $ cDado,.T.,.F.) } )
Next

If lTela
	DEFINE MSDIALOG oDlg TITLE cTitulo FROM ndLinIni,ndColIni TO ndLinFin,ndColFin OF GetWndDefault()	//"Grupos Reduores"
	@ 020,012 SAY oSay PROMPT STR0006 SIZE 300,010 OF oDlg PIXEL COLOR CLR_HBLUE //"Selecione o(s) grupo(s) que deseja processar"
	
	oGrupo := TcBrowse():New( 035, 012, 330, 150,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
	oGrupo:AddColumn(TcColumn():New(" "		,{ || IF(aLista[oGrupo:nAt,3],LoadBitmap( GetResources(), "LBOK" ),LoadBitmap( GetResources(), "LBNO" )) },"@c",nil,nil,nil,015,.T.,.T.,nil,nil,nil,.T.,nil))
	oGrupo:AddColumn(TcColumn():New(STR0007	,{ || OemToAnsi(aLista[oGrupo:nAt,1]) },"@!",nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil)) //"Codigo"
	oGrupo:AddColumn(TcColumn():New(STR0008	,{ || OemToAnsi(aLista[oGrupo:nAt,2]) },"@C",nil,nil,nil,200,.F.,.F.,nil,nil,nil,.F.,nil))	//Descricao"
	
	//-------------------------------------------------------------------
	//  LGPD
	//-------------------------------------------------------------------
	if objCENFUNLGP:isLGPDAt()
		aCampos := {.F.,"B65_CODIGO","B65_DESCRI"}
		aBls := objCENFUNLGP:getTcBrw(aCampos)

		oGrupo:aObfuscatedCols := aBls
	endif

	oGrupo:SetArray(aLista)
	oGrupo:bLDblClick := { || Eval(bChk) , Iif( nQtd<=20 .Or. aLista[oGrupo:nAt,3] , aLista[oGrupo:nAt,3] := IF(aLista[oGrupo:nAt,3],.F.,.T.) , .F. ) }
	
	ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar( oDlg,bOK,bCancel,.F.,{} )
Else
	nOpca := K_OK
EndIf

lRet := !empty(cDado)

If nOpca == K_OK
	cDado := ""
	For nInd := 1 To Len(aLista)
		If aLista[nInd,3]
			cDado += aLista[nInd,1]+","
		EndIf
	Next
EndIf

If Subs(cDado,Len(cDado),1) == ","
	cDado := Subs(cDado,1,Len(cDado)-1)
EndIf
MV_PAR05 := Alltrim(cDado) 

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณ PlVlGrRd   ณ Autor ณMicrosiga          ณ Data ณ 20/10/2011 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Valida o cadastro de procedimento no grupo redutor         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ SIGAPLS                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function PlVlGrRd()

If !PlsCkInd("B662",STR0020 + Chr(10) + STR0021,"SIGAPLS")  //"Rotina desatualizada. อndice B662 nใo encontrado." - "Execute o compatibilizador UPDPLS0F."
	Return .F.
EndIf

B66->(dbSetOrder(2))
If B66->(dbSeek(xFilial("B66")+M->B66_CODTAB+M->B66_CODPSA))
	MsgInfo(STR0022 + B66->B66_CODIGO) //"Procedimento jแ cadastrado no grupo redutor "
	Return .F.
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณ PertGrp    ณ Autor ณMicrosiga          ณ Data ณ 09/08/2012 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Verifica se o procedimento posicionado pertence ao grupo   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function PertGrp(cProc,aGrp)
Local lRet := .F.
Local nFor := 0

For nFor := 7 To Len(aGrp)
	If cProc == aGrp[nFor,1]+aGrp[nFor,2]
		lRet := .T.
		Exit
	EndIf
Next nFor

Return lRet

/*/{Protheus.doc} PercPrinc
Ajusta o Percentual Principal quando a quantidade do procedimento na tabela BD6 for maior que 1. 
@author Microsiga
@since 09/08/2012
@version P12
/*/
Static Function PercPrinc(cChave,aRetGrp)
Local aArea		:= getArea()
Local aAreaBD6 	:= BD6->( getArea() )
Local aRet 		:= {.t.,aRetGrp[2]} // [1]-Se houve alteracao -- [2]-Qual o novo valor
Local nQuant	:= 0
Local nPercPrin	:= aRetGrp[2]
Local nPercSub	:= aRetGrp[3]

dbSelectArea("BD6")
BD6->(dbSetOrder(1))//BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN+BD6_CODPAD+BD6_CODPRO
If BD6->(dbSeek( xFilial("BD6") + cChave ))
	
	nQuant := BD6->(BD6_QTDPRO)
	
	//Perc=[100%:70%] e Qtd=4 --> Perc=(100+70+70+70)/4 = [77,5]
	If nQuant > 1
		nPercPrin := (nPercPrin + ( (nQuant - 1) * nPercSub )) / nQuant
		aRet	  := {.F., nPercPrin}
	EndIf
	
EndIf
	
BD6->(RestArea(aAreaBD6))

RestArea( aArea )

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSRCAUTMF
Fun็ใo para realizar o cแlculo de Redu็ใo de Custo de forma automแtica, quando realizada a mudan็a de fase (Guia ou PEG).
@author Renan Martins	
@since 09/2016
@version P12
/*/
//-------------------------------------------------------------------
Function PLSRCAUTMF(cOrigem, cAlias, aInfRed)
local lNLocDig := iIf( (cAlias)->&( cAlias + "_CODLDP" ) $ PLSRETLDP(4) .or. (cAlias)->&( cAlias + "_CODLDP" ) $ iIf( PLSOBRPRDA( (cAlias)->&( cAlias + "_CODRDA" ) ),PLSRETLDP(9),PLSRETLDP(5) ), .t., .f.) 
Local aInfMF   := {}

if (!lNLocDig .and. len(aInfRed) > 0)
	PLSM250Pro("PLSM250   ", .T., cOrigem, aInfRed)
endIf

Return

/*/{Protheus.doc} PlsBD7Red
Query para verificar BD7 itens que tem como unidade o UCO. Inner join com as tabelas de redutores, para economizar tempo e recursos.
@author Renan Martins	
@since 09/2016
@version P12
/*/
static function PlsBD7Red(cOrigem, cCodRda, cCodOpe, cCodEmp, cMatric, cTipReg, cCodPeg, cCodNum, dDatPro, cGrupos, cCodLdp)
Local cPriGrp 	:= GetNewPar("MV_PLPRGRR","1") // Indica como deve ser escolhido o evento principal: 1=Maior Valor;2=Maior Porte;3=Sequencial dentro da Guia
Local cSqlBD7 	:= ""
Local cStmBD7 	:= ""
Local lNumGuiR	:= .F.
Local lRet	  	:= .F.
Local aMaMeDt	:= iIf( cOrigem == "2", PlsBsDBd7(cCodOpe,cCodLdp,cCodPeg), {}) //Maior - Menor data
Local lPL250C := ExistBlock("PLRCTABC") // ponto de entrada EVIDA
Local lPL250D := ExistBlock("PLRCTABD") // ponto de entrada EVIDA

Default cGrupos := "" //cGrupos ้ quando tenho outras guias na mesma PEG, mas com nบ diferentes e preciso revalorar

if ( cOrigem == "2" .AND. ( ! len(aMaMeDt) > 0) )
	return lRet
endIf	

If cPriGrp == '1'

	cSqlBD7 := " SELECT BD7.R_E_C_N_O_,BD7_OPEUSR,BD7_CODEMP,BD7_MATRIC,BD7_TIPREG,BD7_CODOPE,BD7_CODUNM,BD7_DATPRO,BD7_CODRDA, "
	cSqlBD7 += "        BD7_VLRPAG,BD7_CODPAD,BD7_COEFUT,BD7_CODPEG,BD7_NUMERO,BD7_CODPRO,BD7_CODLDP,BD7_ORIMOV,BD7_SEQUEN, B65_CODIGO 
	
	cSqlBD7 += "   FROM " + retSqlName("BD7") + " BD7 "
	
	cSqlBD7 += " INNER JOIN " + retSqlName("B66") + " B66 "
	cSqlBD7 += "         ON B66_FILIAL = '" + xFilial("B66") + "' " 
	cSqlBD7 += "        AND B66_CODTAB = BD7_CODPAD "
	cSqlBD7 += "        AND B66_CODPSA = BD7_CODPRO "
	cSqlBD7 += "   		AND B66.D_E_L_E_T_ = ' ' "
	
	cSqlBD7 += " INNER JOIN " + retSqlName("B65") + " B65 "
	cSqlBD7 += "         ON B65_FILIAL     = '" + xFilial("B65") + "' " 
	cSqlBD7 += "        AND B65_CODIGO     = B66_CODIGO "
	cSqlBD7 += "        AND B65_AUTOMA     = '1' "     
	If ltpApli
		cSqlBD7 += "         AND B65_TPAPLI <> '1' "
	EndIf
	cSqlBD7 += "   		AND B65.D_E_L_E_T_ = ' ' "

	// ponto de entrada EVIDA
	If lPL250C
		cSqlBD7 += ExecBlock("PLRCTABC",.F.,.F.,{ })	
	End If

	cSqlBD7 += " WHERE BD7_FILIAL = '" + xFilial("BD7") + "' " 
	
	//Por Guia - Nใo usado neste momento.
	if cOrigem == "1" 
	
		cSqlBD7 += " AND BD7_OPEUSR = '" + cCodOpe + "' "
		cSqlBD7 += " AND BD7_CODEMP = '" + cCodEmp + "' "  
		cSqlBD7 += " AND BD7_MATRIC = '" + cMatric + "' "
		cSqlBD7 += " AND BD7_TIPREG = '" + cTipReg + "' "
		  
		cSqlBD7 += " AND BD7_CODRDA = '" + cCodRDA + "' " 

		cSqlBD7 += " AND BD7_CODOPE = '" + cCodOpe + "' " 
		cSqlBD7 += " AND BD7_CODLDP = '" + cCodLdp + "' " 
		cSqlBD7 += " AND BD7_CODPEG = '" + cCodPeg + "' "

		if empty(cGrupos)
			cSqlBD7 += " AND BD7_NUMERO = '" + cCodNum + "' " 
		else
			cSqlBD7 += " AND BD7_NUMERO = '" + cGrupos + "' " 
		endIf	

		cSqlBD7 += " AND BD7_DATPRO = '" + dtos(dDatPro) + "' "
	
	//Por PEG	
	else  
	
		cSqlBD7 += " AND BD7_CODOPE = '" + cCodOpe + "' " 
		cSqlBD7 += " AND BD7_CODLDP = '" + cCodLdp + "' " 
		cSqlBD7 += " AND BD7_CODPEG = '" + cCodPeg + "' "
		
		cSqlBD7 += " AND BD7_CODRDA = '" + cCodRDA + "' " 
		
		cSqlBD7 += " AND BD7_DATPRO >= '" + aMaMeDt[2] + "' AND BD7_DATPRO <= '" + aMaMeDt[1] + "' "
		
	endIf	
	
	cSqlBD7 += " AND BD7_FASE   = '3' "	
	cSqlBD7 += " AND BD7_SITUAC = '1' "
	cSqlBD7 += " AND BD7_CODUNM = 'UCO' "
	cSqlBD7 += " AND BD7_VLRPAG > 0 "
	cSqlBD7 += " AND BD7_REDCUS <> '1' "
	cSqlBD7 += " AND BD7_LIBERA <> '1' "
	cSqlBD7 += " AND BD7_BLOPAG <> '1' "
	cSqlBD7 += " AND BD7.D_E_L_E_T_ = ' ' "
	
	cSqlBD7 += " ORDER BY BD7_OPEUSR, BD7_CODEMP, BD7_MATRIC, BD7_TIPREG, BD7_DATPRO, BD7_CODRDA, BD7_VLRPAG DESC "

Else

	cSqlBD7 := " SELECT DISTINCT BD7.R_E_C_N_O_, BD7_OPEUSR, BD7_CODEMP, BD7_MATRIC, BD7_TIPREG, BD7_CODOPE, BD7_CODUNM, BD7_DATPRO, BD7_CODRDA, BD7_VLRPAG,BD7_CODPAD, " 
	cSqlBD7 += "                 BD7_COEFUT, BD7_CODPEG, BD7_NUMERO, BD7_CODPRO, BD7_CODLDP, BD7_ORIMOV, BD7_SEQUEN, PORTE, BD7_VLRBPR / BD6_QTDPRO VLRBPR, BD6_VLRAPR, B65_CODIGO "
	cSqlBD7 += "   FROM " + retSqlName("BD7") + " BD7 "
	
	cSqlBD7 += " INNER JOIN ( "

		cSqlBD7 += " SELECT BD7_CODOPE CODOPE, BD7_CODLDP CODLDP, BD7_CODPEG CODPEG, BD7_NUMERO NUMERO, BD7_SEQUEN SEQUEN, BD7_CODUNM CODUNM, BD7_COEFUT PORTE, BD7_VLRBPR VALOR_CONTRATADO "
		cSqlBD7 += "   FROM " + retSqlName("BD7") + " PPM "
		
		cSqlBD7 += "  WHERE PPM.BD7_FILIAL = '" + xFilial("BD7") + "' "
		cSqlBD7 += "    AND PPM.BD7_CODRDA = '" + cCodRDA + "' " 
			
			//Por Guia
			if cOrigem == "1" 
				
				cSqlBD7 += " AND PPM.BD7_OPEUSR = '" + cCodOpe + "' "
				cSqlBD7 += " AND PPM.BD7_CODEMP = '" + cCodEmp + "' " 
				cSqlBD7 += " AND PPM.BD7_MATRIC = '" + cMatric + "' "
				cSqlBD7 += " AND PPM.BD7_TIPREG = '" + cTipReg + "' " 

				cSqlBD7 += " AND PPM.BD7_CODOPE = '" + cCodOpe + "' " 
				cSqlBD7 += " AND PPM.BD7_CODLDP = '" + cCodLdp + "' " 
				cSqlBD7 += " AND PPM.BD7_CODPEG = '" + cCodPeg + "' " 
				cSqlBD7 += " AND PPM.BD7_NUMERO = '" + cCodNum + "' " 

				cSqlBD7 += " AND PPM.BD7_DATPRO = '" + dtos(dDatPro) + "' "
				
			//Por PEG
			else  
			
				cSqlBD7 += " AND PPM.BD7_CODOPE = '" + cCodOpe + "' " 
				cSqlBD7 += " AND PPM.BD7_CODLDP = '" + cCodLdp + "' " 
				cSqlBD7 += " AND PPM.BD7_CODPEG = '" + cCodPeg + "' "	
				
				cSqlBD7 += " AND PPM.BD7_DATPRO >= '" + aMaMeDt[2] + "' AND PPM.BD7_DATPRO <= '" + aMaMeDt[1] + "' "
				
			endIf	
			
			cSqlBD7 += " AND PPM.BD7_FASE   = '3' "
			cSqlBD7 += " AND PPM.BD7_SITUAC = '1' " 
			cSqlBD7 += " AND PPM.BD7_LIBERA <> '1' "
			cSqlBD7 += " AND PPM.BD7_BLOPAG <> '1' " 
			cSqlBD7 += " AND PPM.BD7_REDCUS <> '1' "
			cSqlBD7 += " AND PPM.BD7_VLRPAG > 0 "
			cSqlBD7 += " AND PPM.BD7_CODUNM = 'PPM' "
			cSqlBD7 += " AND PPM.D_E_L_E_T_ = ' ' "
			
	cSqlBD7 += " ) PPM "
	cSqlBD7 += "  ON CODOPE = BD7_CODOPE "
	cSqlBD7 += " AND CODLDP = BD7_CODLDP "
	cSqlBD7 += " AND CODPEG = BD7_CODPEG "
	cSqlBD7 += " AND NUMERO = BD7_NUMERO "
	cSqlBD7 += " AND SEQUEN = BD7_SEQUEN "
	cSqlBD7 += " AND CODUNM = 'PPM' "
	
	//Join com B65 e B65 - Grupos e itens redutores
	cSqlBD7 += " INNER JOIN " + retSqlName("B66") + " B66 "
	cSqlBD7 += "        ON B66_FILIAL = '" + xFilial("B66") + "' "
	cSqlBD7 += "       AND B66_CODTAB = BD7_CODPAD "
	cSqlBD7 += "       AND B66_CODPSA = BD7_CODPRO "
	cSqlBD7 += "       AND B66.D_E_L_E_T_ = ' ' "
	
	cSqlBD7 += " INNER JOIN " + RetSqlName("B65") + " B65 "
	cSqlBD7 += "         ON B65_FILIAL = '" + xFilial("B65") + "' "
	cSqlBD7 += "        AND B65_CODIGO = B66_CODIGO "
	cSqlBD7 += "        AND B65_AUTOMA = '1' "
	If ltpApli
		cSqlBD7 += "         AND B65_TPAPLI <> '1' "	 
	EndIf
	cSqlBD7 += "        AND B65.D_E_L_E_T_ = ' ' "
	
	//Fim do Join
	cSqlBD7 += " INNER JOIN " + retSqlName("BD6") + " BD6 "
	cSqlBD7 += "         ON BD6_FILIAL = '" + xFilial("BD6") + "' "
	cSqlBD7 += "        AND BD6_CODOPE = BD7_CODOPE "
	cSqlBD7 += "        AND BD6_CODLDP = BD7_CODLDP "
	cSqlBD7 += "        AND BD6_CODPEG = BD7_CODPEG "
	cSqlBD7 += "        AND BD6_NUMERO = BD7_NUMERO "
	cSqlBD7 += "        AND BD6_SEQUEN = BD7_SEQUEN "
	cSqlBD7 += "        AND BD6.D_E_L_E_T_ = ' ' "
	
	// ponto de entrada EVIDA
	If lPL250D
		cSqlBD7 += ExecBlock("PLRCTABD",.F.,.F.,{ })	
	End If	
		
	cSqlBD7 += " WHERE BD7_FILIAL = '" + xFilial("BD7") + "' "
	cSqlBD7 += "   AND BD7_CODRDA = '" + cCodRDA + "' " 
		
		//Por Guia
		if cOrigem == "1" 
			
			cSqlBD7 += " AND BD7_OPEUSR = '" + cCodOpe + "' "
			cSqlBD7 += " AND BD7_CODEMP = '" + cCodEmp + "' " 
			cSqlBD7 += " AND BD7_MATRIC = '" + cMatric + "' "
			cSqlBD7 += " AND BD7_TIPREG = '" + cTipReg + "' " 
			
			cSqlBD7 += " AND BD7_CODOPE = '" + cCodOpe + "' " 
			cSqlBD7 += " AND BD7_CODLDP = '" + cCodLdp + "' " 
			cSqlBD7 += " AND BD7_CODPEG = '" + cCodPeg + "' " 
			cSqlBD7 += " AND BD7_NUMERO = '" + cCodNum + "' " 
			
			cSqlBD7 += " AND BD7_DATPRO = '" + dtos(dDatPro) + "'
			
		//Por PEG
		else  
			cSqlBD7 += " AND BD7_CODOPE = '" + cCodOpe + "' " 
			cSqlBD7 += " AND BD7_CODLDP = '" + cCodLdp + "' " 
			cSqlBD7 += " AND BD7_CODPEG = '" + cCodPeg + "' "
			
			cSqlBD7 += " AND BD7_DATPRO >= '" + aMaMeDt[2] + "' AND BD7_DATPRO <= '" + aMaMeDt[1] + "' "	
			
		endIf	
		
		cSqlBD7 += " AND BD7_FASE   = '3' "
		cSqlBD7 += " AND BD7_SITUAC = '1' " 
		cSqlBD7 += " AND BD7_LIBERA <> '1' "
		cSqlBD7 += " AND BD7_BLOPAG <> '1' "
		cSqlBD7 += " AND BD7_REDCUS <> '1' "
		cSqlBD7 += " AND BD7_VLRPAG > 0 "
		cSqlBD7 += " AND BD7_CODUNM = 'UCO' "
		cSqlBD7 += " AND BD7.D_E_L_E_T_ = ' ' "
		
	cSqlBD7 += " ORDER BY BD7_OPEUSR, BD7_CODEMP, BD7_MATRIC, BD7_TIPREG, BD7_DATPRO, BD7_CODRDA, "

	cSqlBD7 += iIf(cPriGrp == '2',"PORTE DESC, VLRBPR DESC, BD6_VLRAPR DESC, BD7_SEQUEN","BD7_SEQUEN")

endIf

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSqlBD7),"TRBBD7",.F.,.T.)

if TRBBD7->(eof())

	TRBBD7->(dbCloseArea())
	lRet := .f.

else

	lRet := .t.
	
	//Chamada para fun็ใo para verificar na BD7 se nใo existe outro atendimento para a mesma RDA, na mesma data e bene-
	//ficiแrio, pois se sim, devemos alertar o usuแrio, indicando a guia, para retornar a fase e calcular de maneira correta
	//Somente quando for chamada do Digita็ใo de Contas, MF por guia
	if IsInCallStack('PLSA500FAS')  
		
		lNumGuiR := PlsVrGRCA(cCodRDA, cCodPeg, DtoS(dDatPro), cCodOpe, cCodEmp, cMatric, cTipReg, cCodNum, cPriGrp )
		
		//Se verdadeiro, impedimos o processamento da redu็ใo de custo
		iIf(lNumGuiR, lRet := .f., "")
		  
	endIf
	
endIf

return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PlsMntGRed
Fun็ใo que monta os c๓digos da tabela BD7 achada para informar no grupo redutor, trazendo apenas os dados existentes.
@author Renan Martins	
@since 09/2016
@version P12
/*/
//-------------------------------------------------------------------
Static Function PlsMntGRed ()
Local cRet := ""
Local cCodPrs := ""
Local cCodPds := ""

While !TRBBD7->(Eof())
	IIF (TRBBD7->B65_CODIGO $ cRet	  	, "", cRet 	+= "'" + TRBBD7->B65_CODIGO + "',") //Evitar repeti็ใo de um mesmo c๓digo
	IIF (TRBBD7->BD7_CODPAD $ cCodPds	, "", cCodPds += "'" + TRBBD7->BD7_CODPAD + "',") //Evitar repeti็ใo de uma mesma tabela
	IIF (TRBBD7->BD7_CODPRO $ cCodPrs 	, "", cCodPrs += "'" + TRBBD7->BD7_CODPRO + "',") //Evitar repeti็ใo de um mesmo procedimento
	TRBBD7->(dbSkip())
ENDDO
TRBBD7->(dbGoTop())

cRet 	:= Substr(cRet,1, (Len(cRet)-1))
cCodPds := Substr(cCodPds,1, (Len(cCodPds)-1))
cCodPrs	:= Substr(cCodPrs,1, (Len(cCodPrs)-1))
Return	{cRet,cCodPds,cCodPrs}


//-------------------------------------------------------------------
/*/{Protheus.doc} PlsBsDBd7
Fun็ใo para buscar maior e menor data de guias num intervalo de PEG
@author Renan Martins	
@since 09/2016
@version P12
/*/
//-------------------------------------------------------------------
static function plsBsDBd7(cCodOpe,cCodLdp,cCodPeg)
local cSql := ""
local aVal := {}

cSql := " SELECT MAX(BD7_DATPRO) MAIOR, MIN(BD7_DATPRO) MENOR "
cSql += "   FROM " + retSqlname("BD7")
cSql += "  WHERE BD7_FILIAL = '" + xFilial("BD7") + "' "
cSql += "    AND BD7_CODOPE = '" + cCodOpe + "' "
cSql += "    AND BD7_CODLDP = '" + cCodLdp + "' "
cSql += "    AND BD7_CODPEG = '" + cCodPeg + "' "
cSql += "    AND D_E_L_E_T_ = ' ' "

cSql := changeQuery(cSql)

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRMMBD7",.F.,.T.)

if !TRMMBD7->(Eof())
	aVal := {TRMMBD7->MAIOR, TRMMBD7->MENOR}
endIf

TRMMBD7->(dbCloseArea())

return(aVal)


//-------------------------------------------------------------------
/*/{Protheus.doc} PlsVrGRCA
Fun็ใo para verificar se existe guia com custo jแ reduzido de menor porte/valor que a guia atual, para alertar usuแrio
@author Renan Martins	
@since 09/2016
@version P12
/*/
//-------------------------------------------------------------------
Function PlsVrGRCA( cCodRDA, cCodPeg, cDatPro, cCodOpe, cCodEmp, cMatric, cTipReg, cCodNum, cTipGrupo )
Local aGetBD7 	:= BD7->(GetArea())
Local cDatPro 	:= IIF (ValType(cDatPro) == "D", DtoS(cDatPro), cDatPro)
Local cChave 	:= (xFilial("BD7") + cCodOpe + cCodRDA + cCodOpe + cCodEmp + cMatric + cTipReg + cDatPro)
Local cCodGuias	:= ""
Local cRet		:= ""
Local cMsg		:= ""
Local lRet		:= .F.

While !TRBBD7->(Eof())
	IIF(TRBBD7->B65_CODIGO $ cRet, "", cRet 	+= TRBBD7->B65_CODIGO + ",") //Evitar repeti็ใo de um mesmo c๓digo
	TRBBD7->(dbSkip())
ENDDO
TRBBD7->(dbGoTop())

BD7->(dbSetOrder(14))  // filial + cCodOpe + RDA + Opeusr +codEmp + matric + tipreg +datapro
BD7->(DbSeek(xFilial("BD7") + cCodOpe + cCodRDA + cCodOpe + cCodEmp + cMatric + cTipReg + cDatPro) )

While (!BD7->(EOF()) .AND. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODRDA+BD7_OPEUSR+BD7_CODEMP+BD7_MATRIC+BD7_TIPREG)+DtoS(BD7->(BD7_DATPRO)) == cChave )

	IF BD7->BD7_NUMERO <> cCodNum  //Se for o mesmo n๚mero nใo preciso analisar
		B66->(DbSetOrder(2))
		IF B66->( DbSeek(xFilial("B66") + BD7->(BD7_CODPAD + BD7_CODPRO)) )	//Verifico se encontro o procedimento em algum grupo redutor
		  
			//Caso a BD7 encontrada contenha um procedimento de grupo redutor jแ existente em outra guia e satisfa็a os crit้rios abaixo, depois ้ avaliado
			//se houve redu็ใo. Se nใo houve, significa que a guia nใo foi reduzida e serแ considerada. Se jแ foi reduzida, precisamos alertar o analista
			//que essa guia deve ter a fase retornada, para que realize e MF e considetre al้m desta, a guia atual. 
			IF (B66->B66_CODIGO $ cRet .AND. cTipGrupo == "1" .AND. TRBBD7->BD7_VLRPAG > BD7->BD7_VLRPAG ;
			              .AND. BD7->BD7_FASE = '3' .AND. BD7->BD7_SITUAC = '1' .AND. BD7->BD7_LIBERA <> '1' ;
			              .AND. BD7->BD7_BLOPAG <> '1' ) 
				IIF (BD7->BD7_REDCUS == "1", cCodGuias += BD7->BD7_NUMERO + ", ", "") //Adicionar apenas as que tiveram redu็ใo de custo
			
			ELSEIF (TRBBD7->B65_CODIGO == B66->B66_CODIGO .AND. cTipGrupo == "2" .AND. TRBBD7->PORTE > BD7->BD7_COEFUT ;
			              .AND. BD7->BD7_FASE = '3' .AND. BD7->BD7_SITUAC = '1' .AND. BD7->BD7_LIBERA <> '1' ;
			              .AND. BD7->BD7_BLOPAG <> '1' ) 
				IIF (BD7->BD7_REDCUS == "1", cCodGuias += BD7->BD7_NUMERO + ", " , "")  //Adicionar apenas as que tiveram redu็ใo de custo	
			ENDIF
			
		ENDIF
	ENDIF
BD7->(DBSkip())	
ENDDO	

if len(cCodguias) > 0 //caiu em alguns dos casos	
	lRet := .T.
	cMsg += STR0023 + SUBSTR(cCodGuias, 1, (Len(cCodguias)-2)) + CRLF  //"A guia de n๚mero: "
	cMsg += STR0024 + CRLF //"possue atendimento para o mesmo Prestador, na mesma data e beneficiแrio, com procedimentos onde o foram calculados os devidos Grupos Redutores"
	cMsg += STR0025 + CRLF //"Serแ necessแrio que retorne a fase desta guia e mude novamente, pois a guia atual tem procedimentos de maior porte/valor"
	cMsg += STR0026 + CRLF //" para os mesmos grupos jแ aplicados, sendo necessแrio uma revaloriza็ใo dessa redu็ใo." 
	cMsg += STR0027 + CRLF //"O sistema irแ interromper agora o processamento de redu็ใo, para que seja feitos os procedimentos descritos"

	MsgInfo(cMsg,STR0028)  //Aten็ใo
	TRBBD7->(dbCloseArea())
endIf 

Return	(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} PlRedCopar
redutor de cobran็a no intercโmbio
@author 	
@since 
@version P12
/*/
//-------------------------------------------------------------------
function PlRedCopar(cRdaDe, cRdaAte, cDtPrDe, cDtPrAte, cCodGrp, cCodInt, lMudFas)

Local cSql := ""
Local aRedCop := {}
Local cChave := ""
Local nScan := 0
Local nI	:= 1
Local aAreaBD6 := BD6->(getArea())
Local aAreaBD7 := BD7->(getArea())
Local nValant	:= 0
Local nValAtu	:= 0
Local lMultQtd := .F.
Local aGuiaalt := {}

Default lMudFas := .F.

If GetNewPar("MV_PLSUNI", "0") == "1"
	cSql += " SELECT "
	cSql += " BD7.R_E_C_N_O_ RECCOB, BD7_VLRPAG, (BD7_VLRPAG / BD6_QTDPRO) VLPAGUNI, BD7_OPEUSR, BD7_CODEMP, BD7_MATRIC, BD7_TIPREG, BD7_DATPRO, BD7_CODRDA, BD7_CODPAD, BD7_CODPRO, BD7_CODUNM, B65_PERPRI, B65_PERSUB, B65_PERTER, B65_CODIGO, BD6_QTDPRO "
	cSql += " FROM " + RetSqlName("BD7") + " BD7 "
	cSql += " INNER JOIN " + RetSqlName("B66") + " B66 "
	cSql += " ON "
	cSql += " B66_FILIAL = '" + xFilial("B66") + "' AND " 
	cSql += " BD7_CODPAD = B66_CODTAB AND "
	cSql += " BD7_CODPRO = B66_CODPSA  AND "
	cSql += "  ( B66_VIGDE  >= '" + cDtPrDe + "' AND B66_VIGATE <= '" + cDtPrAte + "'  OR "
	cSql += "       B66_VIGDE  <= '" + cDtPrDe + "' AND B66_VIGATE = ' ') "	
	cSql += " AND B66.D_E_L_E_T_ = ' ' "
	cSql += " INNER JOIN " + RetSqlName("B65") + " B65 "
	cSql += " ON "
	cSql += " B65_FILIAL = '" + xFilial("B65") + "' AND "
	cSql += " B65_CODINT = '" + cCodInt + "' AND "
	cSql += " B66_CODIGO = B65_CODIGO  AND "
	cSql += " B65_TPAPLI = '1' AND "
	If lMudFas
		cSql += " B65_AUTOMA = '1' AND "
	endIf
	cSql += " B65.D_E_L_E_T_ = ' ' "
	cSql += " Inner Join " + RetSqlName("BD6") + " BD6 "
	cSql += " On " 
	cSql += " BD6_FILIAL =  '" + xFilial("BD6") +  "' AND "
	cSql += " BD6_CODOPE = '" + cCodInt + "' AND "
	cSql += " BD6_CODLDP = BD7_CODLDP AND "
	cSql += " BD6_CODPEG = BD7_CODPEG AND "
	cSql += " BD6_NUMERO = BD7_NUMERO  AND "
	cSql += " BD6_SEQUEN = BD7_SEQUEN AND "
	cSql += " BD6.D_E_L_E_T_ = ' ' "
	cSql += " WHERE "
	cSql += " BD7_FILIAL = '" + xFilial("BD7") + "'  AND "  
	cSql += " BD7_CODOPE = '" + cCodInt + "' AND "
	cSql += " BD7_CODRDA >= '" + cRdaDe + "' AND  " 
	cSql += " BD7_CODRDA <= '" + cRdaAte + "'  AND "
	cSql += " BD7_DATPRO >= '" + cDtPrDe + "' AND  " 
	cSql += " BD7_DATPRO <= '" + cDtPrAte + "'  AND " 
	cSql += " BD7_FASE = '3' AND "
	cSql += " BD7_SITUAC = '1' AND " 
//	cSql += " BD7_VLRPAG > 0 AND  "
	cSql += " BD7_LIBERA <> '1' AND " 
	cSql += " BD7_BLOPAG <> '1' AND "
	cSql += " BD7_CODUNM <> 'FIL'  AND " 
	cSql += " BD7_REDCUS <> '1' AND "
	cSql += " BD7_CODEMP = '" + getNewPar("MV_PLSGEIN","0050") + "' AND " //Confirmar esse crit้rio
	cSql += " BD7.D_E_L_E_T_ = ' ' "
	cSql += " ORDER BY "
	cSql += " VLPAGUNI DESC, BD7_CODUNM, BD7_OPEUSR, BD7_CODEMP, BD7_MATRIC, BD7_TIPREG, BD7_DATPRO, BD7_CODRDA DESC "
	
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cSql)),"TRBREDCOP",.F.,.T.)
	
	While !(TRBREDCOP->(EoF()))

		cChave := TRBREDCOP->(BD7_OPEUSR+BD7_CODEMP+BD7_MATRIC+BD7_TIPREG+BD7_DATPRO+BD7_CODRDA+ B65_CODIGO +BD7_CODUNM)
		nScan := Ascan(aRedCop, { |x| x[1] == cChave})
	
		If nScan == 0
			If TRBREDCOP->(BD6_QTDPRO) == 1
				aadd(aRedCop, {cChave, TRBREDCOP->(RECCOB),  TRBREDCOP->(B65_PERPRI), "P"})
			elseIf TRBREDCOP->(BD6_QTDPRO) == 2
				lMultQtd := .T.
				aadd(aRedCop, {cChave, TRBREDCOP->(RECCOB),  (TRBREDCOP->(B65_PERPRI) + TRBREDCOP->(B65_PERSUB)) / 2, "P"})
			elseif TRBREDCOP->(BD6_QTDPRO) > 2
				lMultQtd := .T.
				aadd(aRedCop, {cChave, TRBREDCOP->(RECCOB),  (TRBREDCOP->(B65_PERPRI) + TRBREDCOP->(B65_PERSUB) + ( TRBREDCOP->(B65_PERTER) * (TRBREDCOP->(BD6_QTDPRO) - 2) )) / TRBREDCOP->(BD6_QTDPRO), "P"})
			EndIf
		elseIf nScan > 0
			If !lMultQtd .AND. Ascan(aRedCop, { |x| x[1] == cChave .AND. x[4] == "S"}) == 0
				If TRBREDCOP->(BD6_QTDPRO) == 1
					aadd(aRedCop, {cChave, TRBREDCOP->(RECCOB),  TRBREDCOP->(B65_PERSUB), "S"})
				elseif TRBREDCOP->(BD6_QTDPRO) > 1
					aadd(aRedCop, {cChave, TRBREDCOP->(RECCOB),  (TRBREDCOP->(B65_PERSUB) + ( TRBREDCOP->(B65_PERTER) * (TRBREDCOP->(BD6_QTDPRO) - 1) )) / TRBREDCOP->(BD6_QTDPRO), "S"})
				EndIf
			else
				aadd(aRedCop, {cChave, TRBREDCOP->(RECCOB),  TRBREDCOP->(B65_PERTER), "T"})
			EndIf
		EndIF
		TRBREDCOP->(DbSkip())
	EndDo
	
	TRBREDCOP->(dbclosearea())
	
	BD6->(DbSetOrder(1))
	
	If !(empTy(aRedCop))
		BEGIN Transaction
			for nI := 1 To Len(aRedCop)
				BD7->(dbgoTo(aRedCop[nI][2]))
				nValant := BD7->BD7_VLRTPF
				nValAtu := round(BD7->BD7_VLRTPF * aRedCop[nI][3] / 100, 2)
				BD7->(recLock("BD7", .F.))
					BD7->BD7_VLRTPF := nValAtu
				BD7->(MsUnLock())
				If BD6->(MsSeek(xFilial("BD6") + BD7->(BD7_CODOPE + BD7_CODLDP + BD7_CODPEG + BD7_NUMERO + BD7_ORIMOV + BD7_SEQUEN)))
					BD6->(RecLock("BD6", .f.))
						BD6->BD6_VLRPF  := BD6->BD6_VLRPF - nValant + nValAtu
						BD6->BD6_VLRTPF := BD6->BD6_VLRTPF - nValant + nValAtu
					BD6->(MsUnLock())
					If aScan(aGuiaalt, {|x| x[2] == BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)}) == 0
						aadd(aGuiaalt, {IIF(BD6->BD6_TIPGUI == "05", "BE4", "BD5"), BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV)})
					endIf
				EndIf	
			Next
			
			for nI := 1 to Len(aGuiaalt)
				PLGUITOT(aGuiaalt[nI][1], aGuiaalt[nI][2])
			Next
		END Transaction
	endIf
	
	BD6->(RestArea(aAreaBD6))
	BD7->(restArea(aAreaBD7))
EndIf

return aRedCop


//-------------------------------------------------------------------
/*/{Protheus.doc} PlMrkCopar
Marca็ใo da redu็ใo de custo por redutor de cobran็a no intercโmbio
@author 	
@since 
@version P12
/*/
//-------------------------------------------------------------------
function PlMrkCopar(aRedCop)

Local nI := 1


For nI := 1 To Len(aRedCop)
	
	BD7->(dbgoTo(aRedCop[nI][2]))

	BD7->(recLock("BD7", .F.))
		BD7->BD7_REDCUS := "1"
	BD7->(MsUnLock())
	
Next

return


//-------------------------------------------------------------------
/*/{Protheus.doc} PlDataProc
Retorna array com Datas (BD6_DATPRO) "De:" e "Ate:"

@author 	
@since 
@version P12
/*/
//-------------------------------------------------------------------
function PlDataProc(cCodInt, cCodLdp, cCodPeg, cNumero)
Local cSql := ""
Local aDatasProc := {}

	cSql += "SELECT MIN(BD6_DATPRO) AS MENOR, MAX(BD6_DATPRO) AS MAIOR   "
	cSql += " FROM " + RetSqlName("BD6") + "                "
	cSql += "WHERE BD6_FILIAL = '" + xFilial("BD6") + "'    "
	cSql += "      AND BD6_CODOPE = '" + cCodInt + "'       "
	cSql += "      AND BD6_CODLDP = '" + cCodLdp + "' "
	cSql += "      AND BD6_CODPEG = '" + cCodPeg + "'       "
	cSql += "      AND BD6_NUMERO = '" + cNumero + "'       "
	cSql += "      AND BD6_DATPRO <> ' '                    "
	cSql += "  	   AND D_E_L_E_T_ = ' '                     "

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBDATPRO",.F.,.T.)

	While !(TRBDATPRO->(EoF()))
		aadd(aDatasProc, {TRBDATPRO->(MENOR),  TRBDATPRO->(MAIOR)})
		TRBDATPRO->(DbSkip())
	EndDo
	TRBDATPRO->(dbclosearea())
return aDatasProc
