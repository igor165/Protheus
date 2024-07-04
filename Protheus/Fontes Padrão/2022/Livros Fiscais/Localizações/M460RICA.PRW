#INCLUDE "PROTHEUS.CH"
#include "SIGAWIN.CH"        // incluido pelo assistente de conversao do AP5 IDE em 09/09/99
#DEFINE _NOMEIMP   01
#DEFINE _ALIQUOTA  02
#DEFINE _BASECALC  03
#DEFINE _IMPUESTO  04
#DEFINE _VLRTOTAL  3
#DEFINE _FLETE     4
#DEFINE _GASTOS    5
//Posicoes  do terceiro array recebido nos impostos a traves da matxfis...
#DEFINE X_IMPOSTO    01 //Nome do imposto
#DEFINE X_NUMIMP     02 //Sufixo do imposto

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M460RICA ³ Autor ³ Rodrigo M. Pontes     ³ Data ³09/12/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retenção do imposto de ICA			    			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M460RICA                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alterações³ Foi alterado o criterio da busca da aliquota de calculo do ³±±
±±³			 ³ ICA, quando a empresa emitir uma nota de compra e o codigo ³±±
±±³			 ³ A2_CODICA estiver vazio, o sistema usa a base de calculo da³±±
±±³			 ³ SFB, caso esteja preenchido, busca a aliquota na SFF, de   ³±±
±±³			 ³ acordo com o agrupamento do codigo do CIIU.    			  ³±±
±±³			 ³ A base de calculo não soma outros gastos como Frete, seguro³±±
±±³			 ³ e despesas.												  ³±±
±±³R.Berti   ³20/10/13³THYBRQ³P/ ICA, deve haver SA2->A2_CODICA ou		  ³±±
±±³		     ³        ³      ³SA1->A1_ATIVIDA preenchido. Obtem aliq. SFF:³±±
±±³		     ³        ³      ³Munic.+CIIU. Aliq.SFB tem como padrao 0%	  ³±±
±±³Veronica F³19/06/18³DMINA-³Se realizo la modificación para que tomara  ³±±
±±³		     ³        ³  6843³la actividad economica de la NCP            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Retenção de ICA                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function M460RICA(cCalculo,nItem,aInfo)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nDesconto	:= 0,lXFis,xRet,cImp
Local nAliqPad	:= 0
Local nImporte	:= 0
Local cCodMun   := ""
Local cCatCliFor:= ""
Local cCodIca	:= ""
Local cPessoa	:= ""
Local lCodMun   := .F.       
Local aImpRef	:= {}
Local aImpVal	:= {}
Local nI:=1
Local nMoeda    := 1
Local nTaxaMoed := 1	
Local nMoedSFF  := 1

SetPrvt("CALIASROT,CORDEMROT,AITEMINFO,xRet,_CPROCNAME,_CZONCLSIGA")
SetPrvt("_LAGENTE,_LEXENTO,AFISCAL,_LCALCULAR,_LESLEGAL,_NALICUOTA,NALIQ")
SetPrvt("_NVALORMIN,_NREDUCIR,CTIPOEMPR,CTIPOCLI,CTIPOFORN,CZONFIS,CCFO,LRET")
SetPrvt("CRETICA,CMVAGENTE,NBASE,LRETCF")

lXfis:=(MaFisFound() .And. ProcName(1)<>"EXECBLOCK")
lRet := .F.
lRetCF := .T.

cAliasRot  := Alias()
cOrdemRot  := IndexOrd()

If !LXFis
	aItemINFO  := ParamIxb[1]
	xRet   := ParamIxb[2]
	cImp:=xRet[1]
	// Busca o CFO do Tes Correspondente - SF4
	dbSelectArea("SF4")
	cCFO := SF4->F4_CF
	cTes := SF4->F4_CODIGO 
	If SC5->(FieldPos('C5_CODMUN')) > 0 
		cCodMun   := SC5->C5_CODMUN
	ElseIf FieldPos('F2_CODMUN') > 0
		cCodMun   := SF2->F2_CODMUN
	EndIf
	If SC5->(FieldPos('C5_TPACTIV')) > 0 
		cCodICA   := SC5->C5_TPACTIV
	ElseIf FieldPos('F2_TPACTIV') > 0
		cCodICA   := SF2->F2_TPACTIV
	EndIf
Else
	xRet:=0
	cCFO:= MaFisRet(nItem,"IT_CF")
	cTes:= MaFisRet(nItem,"IT_TES")
	cImp:= aInfo[X_IMPOSTO]
	cCodMun   := MAFISRET(,'NF_CODMUN')
	cCodICA   := MAFISRET(,'NF_TPACTIV')
Endif

If cModulo == 'FAT'
	cTipoCliFor:= SA1->A1_TPESSOA
	cPessoa	   := SA1->A1_PESSOA
	cRetICA    := SA1->A1_RETICA
	cZonfis    := SM0->M0_ESTENT

	If Empty(cCodICA)	
		cCodICA := M->F2_TPACTIV
	EndIf		
	cCatCliFor := SA1->A1_TIPO
	Iif((SA1->A1_RETICA == "S"), lRet := .T., lRet := .F.)
Else
	cTipoCliFor:= SA2->A2_TPESSOA
	cRetICA    := UPPER(SubStr(GETNEWPAR("MV_AGENTE",""),2,1))
	cPessoa	   := If(SA2->(FieldPos("A2_PESSOA")) > 0,SA2->A2_PESSOA," ")
	cZonFis    := SA2->A2_EST
	cCatCliFor := SA2->A2_TIPO
	If FunName() $ "MATA466N"
		cCodICA := M->F2_TPACTIV
	Else
		cCodICA := SA2->A2_CODICA
	Endif
	Iif((SA2->A2_RETICA == "S"), lRet := .T., lRet := .F.)	
Endif

//Verifica na SFF se existe ZonFis correspondente para:
// * Calculo de Imposto;
// * Obtencao de Aliquota;
// * Faixa de Imposto De/Ate.


If lRet
	dbSelectArea("SFB")
	dbSetOrder(1)
	If dbSeek(xFilial("SFB")+cImp)
		If If(!lXFis,.T.,cCalculo$"AB")
			nAliqPad   := SFB->FB_ALIQ // Aliquota padrão
		EndIf
	EndIf
Endif

If lRet
		If Empty(cCodIca)
			nAliq   := nAliqPad  // Aliquota padrão
			lRet    := .T.
		Else

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄFF
			//³Método novo de busca pelo índice "I" da SFF: ³
			//³FF_FILIAL+FF_IMPOSTO+FF_CODMUN+FF_CFO_V       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄFF
			If ExistInd()
				dbSelectArea("SFF")
				dbSetOrder(18)					
				If dbseek(xFilial("SFF")+cImp+cCodMun)  // +cCFO
					While !Eof()
						If SFF->FF_COD_TAB == cCodICA .And.;
							SFF->(FF_IMPOSTO+FF_CODMUN) == cImp+cCodMun //+FF_CFO_V  +cCFO
							If FF_FLAG != "1"
								RecLock("SFF",.F.)
								Replace FF_FLAG With "1"
							Endif
							nAliq   := SFF->FF_ALIQ  // Alicuota de Zona Fiscal
							nImporte:= SFF->FF_IMPORTE
							nMoedSFF := SFF->FF_MOEDA
							lCodMun := .T.
							lRet 	:= .T.
							Exit
						Else
							lRet := .F.
						EndIf
						dbSkip()
					EndDo
				Endif
			Endif
			If !lCodMun											
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Metodo antigo de busca , pela zona fiscal (departamento) foi DESATIVADA 						³
				//³caso não tenha aliq. por cod.município, obtera' da SFB, que na Colombia devera' estar ZERADA.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nAliq   := nAliqPad // Aliquota padrão
				lRet    := .T.
			EndIf	
			If !lRet
				nAliq   := nAliqPad // Aliquota padrão
				lRet    := .T.
			EndIf			
		Endif

		If lRet
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Efetua o calculo de ICA, taxa sera' calculada por mil (1000)  				 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lXFis
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Calcula o imposto somente se o valor da base for maior ou igual a base minima    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//Tira os descontos se for pelo liquido .Bruno
				If Subs(xRet[5],4,1) == "S"  .And. Len(xRet) == 18 .And. ValType(xRet[18])=="N"
					nDesconto	:=	xRet[18]
				Else
					nDesconto	:=	0
				Endif
				
				xRet[02]  := nAliq // Alicuota de Zona Fiscal
				xRet[03]  := (aItemINFO[3] - nDesconto) 

				
				xRet[04]  := round(xRet[03] * ( xRet[02]/1000) ,2)
				
				nMoedaOri:= IIf(Type("lPedidos") <> "U" .And. lPedidos , SC5->C5_MOEDA ,Max(SF2->F2_MOEDA,1))
				If xMoeda(xRet[03],nMoedaOri ,1) > xMoeda(nImporte,nMoedSFF,1)
					xRet[04]  := xRet[04] 
				Else
					xRet[04]  := 0
				EndIf
			Else
				Do Case
					Case cCalculo=="B"
						nOrdSFC:=(SFC->(IndexOrd()))
						nRegSFC:=(SFC->(Recno()))
				
						SFC->(DbSetOrder(2))
						If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[X_IMPOSTO])))
							//Tira os descontos se for pelo liquido
							cImpIncid:=Alltrim(SFC->FC_INCIMP)
							If SFC->FC_LIQUIDO=="S"
								xRet-=If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
							Endif
						Endif
						//+---------------------------------------------------------------+
						//¦ Soma a Base de Cálculo os Impostos Incidentes                 ¦
						//+---------------------------------------------------------------+
						If !Empty(cImpIncid)
							aImpRef:=MaFisRet(nItem,"IT_DESCIV")
							aImpVal:=MaFisRet(nItem,"IT_VALIMP")
							For nI:=1 to Len(aImpRef)
								If !Empty(aImpRef[nI])
									IF Trim(aImpRef[nI][1])$cImpIncid
										xRet+=aImpVal[nI]
									Endif
								Endif
							Next
						Else
							xRet += MaFisRet(nItem,"IT_VALMERC")
						Endif
						SFC->(DbSetOrder(nOrdSFC))
						SFC->(DbGoto(nRegSFC))

					Case cCalculo=="A"
						xRet:=nAliq

					Case cCalculo=="V"         
					
						nOrdSFC:=(SFC->(IndexOrd()))
						nRegSFC:=(SFC->(Recno()))
						SFC->(DbSetOrder(2))
						nVal	:= 0
						If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[X_IMPOSTO])))
							nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])
							nVal:=0					
							If SFC->FC_CALCULO=="T"
								
								nBase:=MaFisRet(,"NF_BASEIV"+aInfo[X_NUMIMP])+MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])
								nVal:=MaRetBasT(aInfo[2],nItem,MaFisRet(nItem,'IT_ALIQIV'+aInfo[2]),.T.)
							Else
								nBase:= MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])
								nVal :=	MaFisRet(nItem,'IT_BASEIV'+aInfo[2])
							Endif
						Endif
						
						SFC->(DbSetOrder(nOrdSFC))
						SFC->(DbGoto(nRegSFC))
						
						If Type("M->F1_MOEDA")<>"U" 			   	
						    nMoeda := M->F1_MOEDA
						    nTaxaMoed := M->F1_TXMOEDA
						ElseIf Type("M->C7_MOEDA")<>"U"
							nMoeda := M->C7_MOEDA
						    nTaxaMoed := M->C7_TXMOEDA				
				        ElseIf Type("M->F2_MOEDA")<>"U"
				        	nMoeda := M->F2_MOEDA
						    nTaxaMoed := M->F2_TXMOEDA				
						ElseIf Type("M->C5_MOEDA")<>"U" 
							nMoeda := M->C5_MOEDA
						    nTaxaMoed := M->C5_TXMOEDA				
				        EndIf	        
						
												
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Calcula o imposto somente se o valor da base for maior ou igual a base minima    ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If xMoeda(nBase,nMoeda,1,Nil,Nil,nTaxaMoed) >= xMoeda(nImporte,nMoedSFF,1)
							xRet:=nBase * ( nAliq/1000)
						Else
							xRet:= 0
						EndIf
				EndCase
			Endif
		EndIf
	EndIf
	dbSelectArea( cAliasRot )
	dbSetOrder( cOrdemRot )
Return( xRet )   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ExistInd  ºAutor  ³Camila Januário     º Data ³  09/11/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³  Vefifica existência da ordem do índice                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function ExistInd()
Local lRet := .F.                      

SIX->(DbSetOrder(1))
If SIX->(DbSeek("SFF"+"H")) .And. SIX->(DbSeek("SFF"+"I"))
	lRet := .T.
Endif

Return lRet
