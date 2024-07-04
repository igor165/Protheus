#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FATA530E.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} FATA530E

Exporta projeto (simulacao) para Excel 

@sample	FATA530E

@param 		cSimulacao 	- Numero da simulacao (projeto)
			cVersao 		- Versao da simulacao

@return	Nenhum

@author	Eduardo Gomes Junior
@since		23/04/15
@version	12.1.5
/*/
//------------------------------------------------------------------------------
Function FATA530E(cSimulacao,cVersao)

Local aArea			:= GetArea()
Local aAreaAF2		:= AF2->(GetArea())
Local aAreaAF5		:= AF5->(GetArea())
Local aEscopoPrj 	:= {}
Local aPrepHeade	:= {}
Local aPrepAcols	:= {}
Local nLeA			:= 1
Local cQtdCalc
local aExcel 		:= {}

aEscopoPrj := Ft530Ordem(cSimulacao,cVersao)

If	Len(aEscopoPrj) > 1

	aPrepHeade := {STR0001,STR0002,STR0003}	//"EDT/TAREFA"###"Descricao"###"Quantidade"

	For nLeA=1 To Len(aEscopoPrj)

		If	aEscopoPrj[nLeA,6] <> "001"	
			cQtdCalc := Ft530CalcQtd( aEscopoPrj[nLeA,4], aEscopoPrj[nLeA,10], aEscopoPrj )		
			Aadd(aPrepAcols,{aEscopoPrj[nLeA,4],aEscopoPrj[nLeA,7],cQtdCalc:=StrTran(cQtdCalc,".",",") })
			
		Endif 
					
	Next 

	AAdD(aExcel , {"ARRAY",, aPrepHeade, aPrepAcols} )

	If Len(aExcel) > 0

		DlgToExcel(aExcel)
	
		While ApMsgNoYes(STR0005,STR0004)	//"Deseja exportar projeto novamente?"###"Atenção"
			DlgToExcel(aExcel)
		EndDo
				
	Else
		ApMsgStop(STR0006,STR0004)	//"Não há dados!"###"Atenção"
	EndIf
	
Else

	MsgAlert(STR0007,STR0004)	//"Não existe nenhum projeto criado!"###"Atenção"

Endif 	

RestArea(aArea)
RestArea(aAreaAF2)
RestArea(aAreaAF5)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} Ft530Ordem

Cria ARRAY ordenado do projeto (simulador de horas) esse ARRAY sera usado na 
impressao da proposta, relatorio e exportacao para Excel.

@sample	Ft530Ordem

@param 		cSimulacao 	- Numero da simulacao (projeto)
			cVersao 		- Versao da simulacao
			cNivelPesq		- Nivel 

@return	aTreeOrdem		- Array ordenado do projeto

@author	Eduardo Gomes Junior
@since		23/04/15
@version	12.1.5
/*/
//------------------------------------------------------------------------------
Function Ft530Ordem(cSimulacao,cVersao,cNivelPesq)

Local aAreaAF2		:= AF2->( GetArea())
Local aAreaAF5		:= AF5->( GetArea())
Local aTreeOrdem    := {} 
Local cVsrSimul		:= "001"
Local nTTarefa		:= TamSx3("AF2_TAREFA")[1] 
Local cFilAF5		:= xFilial("AF5")

Default	cVersao		:= cVsrSimul
Default cNivelPesq	:= cVsrSimul

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³--------------------------------------------------------------³
//³Composicao do ARRAY:                                          ³
//³--------------------------------------------------------------³
//³ Posicao  - Descricao 			- Observacao              	 ³
//³  01      - Alias 				- AF5 ou AF2               	 ³
//³	 02 	 - Numero da Simulacao	                         	 ³
//³  03 	 - Ordem                                             ³
//³  04 	 - EDT					- AF5 = _EDT / AF2 = _TAREFA ³
//³  05 	 - EDTPAI                                            ³
//³  06 	 - Nivel                                             ³
//³  07 	 - Descricao                                         ³
//³  08 	 - Codigo MEMO (SYP)                                 ³
//³  09 	 - Status do Item                                    ³
//³  10 	 - Quantidade 		                                 ³
//³  11		 - Recno                                             ³
//³  12		 - EDT ORIGINAL										 ³
//³  13		 - Modelo ORIGINAL									 ³
//³  14		 - Versao da simulacao								 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea("AF5")
dbSetOrder(7) //AF5_FILIAL+AF5_ORCAME+AF5_VERSAO+AF5_NIVEL                                                                                                                      
If	dbSeek(xFilial("AF5")+cSimulacao+cVersao+cNivelPesq)

	While 	AF5_FILIAL == cFilAF5 .And. AF5_ORCAME == cSimulacao .And. AF5_VERSAO == cVersao .And.;
			AF5_NIVEL == cNivelPesq .and. !Eof()
	
		aTreeOrdem := Ft530MtTreeOr(cSimulacao,cVersao+SPACE(nTTarefa)) 

		dbSkip()
		
	End	
	
Endif 

RestArea(aAreaAF2)
RestArea(aAreaAF5)

Return(aTreeOrdem)

//------------------------------------------------------------------------------
/*/{Protheus.doc} Ft530MtTreeO

Cria ARRAY aTreeOrde  

@sample	Ft530MtTreeO

@param 		cSimulEDT 		- Numero da simulacao (projeto)
			cSimVersao 	- Versao da simulacao
			cNivelPesq		- Nivel 

@return	aTreeOrde		- Array ordenado do projeto

@author	Eduardo Gomes Junior
@since		23/04/15
@version	12.1.5
/*/
//------------------------------------------------------------------------------
Static Function Ft530MtTreeOr(cSimulEDT,cSimVersao)

Local cOrcPesq  := Alltrim(cSimulEDT)
Local aTreeOrde	:= {}

dbSelectArea("AF5")
dbSetOrder(6)
If !Empty(cSimulEDT)
	If	dbSeek(xFilial("AF5")+cSimulEDT+cSimVersao)

		While !EOF() .AND. AF5_FILIAL+AF5_ORCAME+AF5_VERSAO+AF5_EDTPAI == xFilial("AF5")+cSimulEDT+cSimVersao
	
			If	aScan(aTreeOrde,{|x| x[2]+x[14]+x[4]+x[5] == AF5_ORCAME+AF5_VERSAO+AF5_EDT+AF5_EDTPAI }) == 0

				aAdd(aTreeOrde, {	"AF5", ; 								//01
							AF5_ORCAME,;								//02
							If(Empty(AF5_ORDEM), "000", AF5_ORDEM),;	//03
							AF5_EDT,;									//04
							AF5_EDTPAI,;								//05
							AF5_NIVEL,;									//06
							AF5_DESCRI,;								//07
							AF5_CODMEM,;								//08
							AF5_STATUS,;								//09
							AF5_QUANT,;									//10
							AF5->(Recno()),;							//11
							AF5_EDTORI,;								//12
							AF5_MODORI,;								//13
							AF5_VERSAO})								//14
							
				Ft53_IF2(AF5_ORCAME,AF5_VERSAO,AF5_EDT,@aTreeOrde)	
				Ft53_IF5(AF5_ORCAME,AF5_VERSAO,AF5_EDT,@aTreeOrde)	
		
			Endif 		

			dbSelectArea("AF5")
			dbSkip()
		
			If	AF5_ORCAME <> cOrcPesq
				Exit 
			Endif 
		
			cSimulEDT := AF5_ORCAME+AF5_EDTPAI
	
		Enddo
	
	Endif
Endif 	

Return(aTreeOrde)

//------------------------------------------------------------------------------
/*/{Protheus.doc} Ft53_IF5

Adiciona EDTs no ARRAY aTreeOrde

@sample	Ft530MtTreeO

@param 		cSimulacao 	- Numero da simulacao (projeto)
			cVersao	 	- Versao da simulacao
			cEDTPos		- Codigo da EDT 
			aTreeOrde		- Array usado para adicionar EDT e TAREFAS

@return	Nenhum

@author	Eduardo Gomes Junior
@since		23/04/15
@version	12.1.5
/*/
//------------------------------------------------------------------------------
Static Function Ft53_IF5(cSimulacao,cVersao,cEDTPos,aTreeOrde)

Local aAreaAF2	:= AF2->( GetArea())
Local aAreaAF5	:= AF5->( GetArea())

dbSelectArea("AF5")
dbSetOrder(6)
If	dbSeek(xFilial("AF5")+cSimulacao+cVersao+cEDTPos)

	While !EOF() .AND. AF5_ORCAME == cSimulacao .AND. AF5_VERSAO == cVersao .AND. AF5_EDTPAI == cEDTPos
	
	aAdd(aTreeOrde, {	"AF5", ; 													//01
						AF5_ORCAME,;												//02
						If(Empty(AF5_ORDEM), "000", AF5_ORDEM),;					//03
						AF5_EDT,;													//04
						AF5_EDTPAI,;												//05
						AF5_NIVEL,;													//06
						AF5_DESCRI,;												//07
						AF5_CODMEM,;												//08
						AF5_STATUS,;												//09						
						AF5_QUANT,;													//10						
						AF5->(Recno()),;											//11
						AF5_EDTORI,;	 											//12
						AF5_MODORI,;												//13
						AF5_VERSAO})												//14

						Ft53_IF2(AF5_ORCAME,AF5_VERSAO,AF5_EDT,aTreeOrde)						
						Ft53_IF5(AF5_ORCAME,AF5_VERSAO,AF5_EDT,aTreeOrde)

	dbSelectArea("AF5")
	dbSkip()
	
	Enddo 						
		
Endif	

RestArea(aAreaAF2)
RestArea(aAreaAF5)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} Ft53_IF2

Adiciona Tarefas no ARRAY aTreeOrde

@sample	Ft530MtTreeO

@param 		cSimulacao 	- Numero da simulacao (projeto)
			cVersao	 	- Versao da simulacao
			cEDTPos		- Codigo da EDT 
			aTreeOrde		- Array usado para adicionar EDT e TAREFAS

@return	Nenhum

@author	Eduardo Gomes Junior
@since		23/04/15
@version	12.1.5
/*/
//------------------------------------------------------------------------------
Static Function Ft53_IF2(cSimulacao,cVersao,cEDTPos,aTreeOrde)

Local aAreaAF2	:= AF2->( GetArea())
Local aAreaAF5	:= AF5->( GetArea())

dbSelectArea("AF2")
dbSetOrder(6)
If	dbSeek(xFilial("AF2")+cSimulacao+cVersao+cEDTPos)

	While !EOF() .AND. AF2_ORCAME == cSimulacao .AND. AF2_VERSAO == cVersao .and. AF2_EDTPAI == cEDTPos
	
	aAdd(aTreeOrde, {	"AF2", ; 													//01
						AF2_ORCAME,;												//02
						If(Empty(AF2_ORDEM), "000", AF2_ORDEM),;					//03
						AF2_TAREFA,;												//04
						AF2_EDTPAI,;												//05
						AF2_NIVEL,;													//06
						AF2_DESCRI,;												//07
						AF2_CODMEM,;												//08
						AF2_STATUS,;												//09
						AF2_QUANT,;													//10						
						AF2->(Recno()),;											//11
						AF2_EDTORI,;	 											//12
						AF2_MODORI,;												//13
						AF2_VERSAO})												//14
						
						Ft53_IF2(AF2_ORCAME,AF2_VERSAO,AF2_TAREFA,aTreeOrde)

	dbSelectArea("AF2") 
	dbSkip()
	
	Enddo 						
		
Endif	

RestArea(aAreaAF2)
RestArea(aAreaAF5)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} Ft530CalcQtd

Soma EDT (quantidade de horas de cada tarefa informada no projeto) 

@sample	Ft530CalcQtd

@param 		cEDTPos 		- Codigo da EDT 
			nQtdPos 		- Quantidade
			aEscopoPrj		- Array que contem o projeto

@return	nQuant			- Total da EDT  

@author	Eduardo Gomes Junior
@since		23/04/15
@version	12.1.5
/*/
//------------------------------------------------------------------------------
Function Ft530CalcQtd(cEDTPos, nQtdPos, aEscopoPrj)

Local aArea 	:= GetArea()
Local nLe		:= 1
Local nLeProx	:= 1
Local nQuant	:= nQtdPos

If	Len( AllTrim(cEDTPos) ) = 2

	nQuant	:= 0	
	nLeProx += 1	

	For nLe:=nLeProx To Len(aEscopoPrj)

		If	Len( AllTrim(aEscopoPrj[nLe,4] ) ) > 2 

			If 	Len(AllTrim( aEscopoPrj[nLe,4] ) ) = 5 .AND. AllTrim( aEscopoPrj[nLe,5] ) == Alltrim( cEDTPos )
				nQuant += aEscopoPrj[nLe,10]
			Endif
			
		Endif 			
	
	Next nLe

EndIf

RestArea(aArea)

Return cValToChar( nQuant )