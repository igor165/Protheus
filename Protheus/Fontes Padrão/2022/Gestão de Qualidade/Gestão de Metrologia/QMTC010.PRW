#INCLUDE "TOTVS.CH"
#INCLUDE "QMTC010.CH"   
#include "PROTHEUS.CH"
#define TENDENCIA    "3"  // MV_PAR01  == "1"                                                                      

#define ESTABILIDADE "4"  // MV_PAR01  == "3"
#define LINEARIDADE  "5"  // MV_PAR01  == "2" 
#define NORMAL  	  "1"  // MV_PAR01  == "2" 
#define LINEARIDADE3E"11"  // MV_PAR01  == "2" 
#define TENDENCIA4E  "13"  // MV_PAR01  == "2" 
#define LINEARIDADE4E "14"  // MV_PAR01  == "2" 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³QMTC010   ³ Autor ³ "Eduardo Riera"       ³ Data ³13.07.98  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Graficos do MSA                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³10/04/02  ³Denis Martins  ³Considerar parametros Referencia Inicial e  ³±±
±±³          ³               ³Referencia Final na montagem dos graficos de³±±
±±³          ³               ³Tendencia - Linearidade - Estabilidade.     ³±±
±±³10/04/02  ³Denis Martins  ³Qdo o parametro referencia final for "ZZZZZ"³±±
±±³          ³               ³considerar como "9999" para q a funcao Super³±±
±±³          ³               ³Val funcione corretamente.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

Local aRotina := { { STR0001   ,"AxPesqui"    , 0 , 1},;  //"Pesquisar"
					{ STR0002   ,"AxVisual"    , 0 , 2},;  //"Visual"
					{ STR0003   ,"c010Grafico" , 0 , 6}}   //"Grafico"

Return aRotina

Function QMTC010()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := OemtoAnsi(STR0004)      //"Cadastro de Instrumentos"
Private aPos   := {  15,  1, 70, 315 }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aRotina := MenuDef()
Private lExistChart := FindFunction("QIEMGRAFIC") .AND. GetBuild() >= "7.00.170117A" //controle se executa o grafico modelo novo ou por DLL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QM2")
dbSetOrder(1)
dbSeek(xFilial())
mBrowse( 6, 1,22,75,"QM2")

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³c010Grafic³ Autor ³ Fernando Godoy        ³ Data ³ 14.01.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grafico MSA                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Verdadeiro ou Falso                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function c010Grafico(cAlias,nReg,nOpc)

Local cTitulo
Local lRet 	:= .T.
Private nLinearA   := 0
Private nLinearB   := 0
Private nLinearR2  := 0
Private nLinearVp  := 0
Private nLinear    := 0
Private nLinearP   := 0
Private aTab       := Array(20,21)
Private aTbv	   := Array(20,21)

Qm010MSA()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Perguntas:                                                              ³
//³                                                                        ³
//³ MV_PAR01: Tipo                                                         ³
//³ MV_PAR02: Data Inicial                                                 ³
//³ MV_PAR03: Data Final                                                   ³
//³ MV_PAR04: Referencia Inicial                                           ³
//³ MV_PAR05: Referencia Final                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (!Pergunte("QMC010",.T.))
	lRet := .F.
EndIf 

If lRet
	Do Case
		Case MV_PAR01 == 1
			cTitulo := OemToAnsi(STR0005) //"Tendencia"
		Case MV_PAR01 == 2
			cTitulo := OemToAnsi(STR0006) //"Linearidade"
		Case MV_PAR01 == 3
			cTitulo := OemToAnsi(STR0007) //"Estabilidade"
	EndCase
	cTitulo += " - "+QM2->QM2_INSTR+"/"+QM2->QM2_REVINS
	Graphini(Nil,Nil,cTitulo,.f.)

Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GraphIni  ³ Autor ³ Eduardo Riera         ³ Data ³ 14.07.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inicializa os Graficos MSA                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oVbx      : Objeto VBx Chart2FX                            ³±±
±±³          ³ oDlg      : Objeto da Dialog                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GraphIni(lCalib,cInstrumento,cTitulo,lImprm,cDQM2In,cRvInt,cDM2Dec)
Local cString    := ""
Local nCntFor    := 0
Local nCount     := 0
Local aTendencia := {}
Local aLinear    := {}
Local nGraph     := 0
Local nSomaX     := 0
Local nSomaY     := 0
Local nSomaXY    := 0
Local nSomaX2    := 0
Local nSomaY2    := 0
Local nSomaY2a	 := 0
Local nX         := 0
Local nY         := 0
Local nDec		:= 0
Local cDir		:= GetMv("MV_QDIRGRA")  
Local nAcum		:= 0
Local nSoma		:= 0
Local aEstab	:= {} 
Local dData		:= ctod('  /  /  ','DDMMYY')
Local nVarPro	:= 0
Local nTende	:= 0 	       
Local aArea		:= {}
Local lTolPro	:= .t.		
Local dDataTRB	
Local cRevInsTRB
Local cSeqTRB	
Local nToler	:= 0
Local nd		:= 0
Local ni		:= 0
Local nPosA := 0
Local oQual
Local cVar
Local aRegQM6	:= {}
Local nPoTol	:= 0
Local nOpc		:= 1
Local cIndexQM7 := ""
Local cChaveQM7	:= ""
Local cQuery	:= ""
Local cKey		:= ""   
Local lContinua := .T.

Local aLinAux	 := {}	
Local nGAx 		 := 0
Local nMaior	 
Local nMenor	 
Local nNrMe   := 0
Local nSomMed := 0
Local nSomAmp := 0
Local nTend   := 0
Local nVlD2	  := 0
Local nUltD2  := 0 
Local nSigR   := 0 
Local nSigB   := 0
Local nTInv   := 0
Local nTenLSE := 0
Local nTenLIE := 0
Local nConst  := 0
Local cAnaLin1:= ""
Local cAnaLin2:= ""
Local nNreAu  := 0					
Local nNroAu  := 0
Local nAmpli  := 0
Local aMs3	  := {}	
Local nVRfer  := 0
Local lReCal  := .F.
Local nErmos  := 0
Local nSomExp := 0     
Local nSomYs  := 0
Local nSomXs  := 0
Local nSomPtos:= 0
Local nSomXYs := 0
Local nSomYAs := 0			 
Local nSxQuads:= 0
Local nSSQd   := 0
Local nCalcA  := 0
Local nCalcB  := 0
Local nCalcS  := 0
Local nCaxMed := 0
Local nTa     := 0  
Local nTb     := 0 
Local nTCritA := 0
Local nDeslo  := 0
Local nBx0    := 0
Local nDMaBx0 := 0
Local nDMiBx0 := 0          
Local nNroAmo := 0        
Local nNreMed := 0
Local nMedia  := 0
Local nMedias := 0
Local nNroTot := 0
Local nNroPec := 0
Local cRefer  := "" 
Local nVll	  := 0
Local aFinal  := {} 
Local aVlr	  := {} 
Local aNov	  := {}
Local nSubG   := 0
Local lConts  := .T.
Local cUltVlr := ""
Local nSomLSE := 0
Local nSomLIE := 0
Local nRefer  := 0
Local nTendLSE:= 0
Local nTendLIE:= 0
Local cReTen  := ""
Local lPrmi	    := .T.	                  
Local lInterpol := GetMV("MV_QMTINTP",.T.,"N") == "S"   
Local lBiCaudal := .T.
Local cInsQuer  := ""
Local cRevQuer  := ""  
Local nInv      := 0      
Local aRetasL   := {}
Local aLinearFim := {}
Local nSomasMed := 0
Local nSaAmpli  := 0
Local aXbr 		:= {}
Local nNominal  := 0
Local nFtMul    := 0
Local nMltAmp   := 0		
Local nGr       := 0
Local dDatQMU   
Local nsGrupo   := 0
Local nNre      := 0
Local cSenhas	:= "1"
Local nJ		:= 0
Local nK		:= 0
Local aQtdeMedDia := {}
Local cDataAtu	 := ""
Local nPve		 :=0
Local cVarTot   :=0    
Local lMsa4Ed         
Local aLimites  :={} 
Local lQMC010CO := ExistBlock("QMC010CO")
Local nTamVlr	 := 0

Local aDatas      := {}
Local aMed64      := {}
Local aMedAux     := {}
Local aMedic      := {}
Local aMedicoe    := {}
Local cDataMed    := ""
Local lExistChart := FindFunction("QIEMGRAFIC") .AND. GetBuild() >= "7.00.170117A" //controle se executa o grafico modelo novo ou por DLL
Local nPosDoisPt  := 0

Private oSay1     
Private oSay2     
Private lMsg    := .F.
Private lConEst := .T.
Private lMedNoc := GetMV("MV_QMEDNOC",.T.,"2") == "1"   
Default lCalib	:= .F.
Default cInstrumento := QM2->QM2_INSTR+QM2->QM2_REVINS
Default lImprm	:= .T.
Default cDM2Dec := QM2->QM2_DESCR        
Default lMsa4Ed := .F.
// Verifica se o diretorio do grafico e um  diretorio Local
If !QA_VerQDir(cDir) 
	Return
EndIf  

//Verifica se existe algum arquivo no diretorio e os deleta...
If File(cDir+"TENDE.BMP")
	FErase (cDir+"TENDE.BMP") 			
Endif

If File(cDir+"LEG1.BMP")
	FErase (cDir+"LEG1.BMP") 	
Endif

If File(cDir+"LINEA.BMP")
	FErase (cDir+"LINEA.BMP") 		
Endif

If File(cDir+"QACHART.SPC")
	FErase (cDir+"QACHART.SPC") 		
Endif

If Upper(SubStr(Alltrim(MV_PAR05),1,1)) == "Z" .or. !IsDigit(SubStr(Alltrim(MV_PAR05),1,1))
	MV_PAR05 := "9999999999"
Endif	

If !lCalib
	aArea := GetArea()
	dbSelectArea("QMU")
	dbSetOrder(1)
	Do Case
		Case MV_PAR01 == 1
			nNrMe   := 0
			nSomMed := 0
			nTend   := 0
			nVlD2	:= 0
			nUltD2  := 0 
			nSigR   := 0 
			nSigB   := 0
			nTInv   := 0
			nTenLSE := 0
			nTenLIE := 0
			lMsa3Ed := .F.
			nVRfer  := 0
			aMs3	:= {}	
			aTendencia:= {}
			aQmuGraf  := {}
			aMed64    := {}
			dbSeek(xFilial("QMU")+cInstrumento+Dtos(MV_PAR02)+MV_PAR04,.T.)
			nsGrupo := 0
			While ( !Eof() .And. QMU->QMU_FILIAL == xFilial("QMU") .And.;
										QMU->QMU_INSTR+QMU->QMU_REVINS == cInstrumento .And.;
										QMU->QMU_DATA   <= MV_PAR03 )
										
				If Val(QMU->QMU_TPMSA) <> mv_par06
					QMU->(dbSkip())
					Loop
				EndIf
				If Alltrim(QMU->QMU_ITEM) == "01"//(DtoS(QMU->QMU_DATA) <> DtoS(dDatQMU)) .or.	QMU->QMU_REFER <> cQMURef
					nsGrupo++	
				Endif
										
				If lQMC010CO
					lConEst := ExecBlock("QMC010CO",.F.,.F.,{MV_PAR01})
				Endif
            
				If lConEst			
					If Len(aTendencia) == 0
					    If FunName() == "QMTA140"
							If mv_par07 == SuperVal(QMU->QMU_TPMSA)
								lReCal := .T.
							Else
								lReCal := .F.	 
								MsgInfo(STR0040) 
								Exit
							Endif
					 		If QMU->QMU_TPMSA $ "1| "
								lMsa3Ed := .F.					
							ElseIf QMU->QMU_TPMSA $ "2|3" //3 Edição ou Superior
								cVarTot:= QMU->QMU_VARTOT 
								lMsa3Ed := .T.	       
							Else
								lMsa3Ed := .F.														
							Endif
						Else
							If mv_par06 == SuperVal(QMU->QMU_TPMSA)
								lReCal := .t.
							Else
								lReCal := .f.	 			
							Endif
					 		If QMU->QMU_TPMSA $ "1| "
								lMsa3Ed := .F.					
							ElseIf QMU->QMU_TPMSA  == "2" //3 Edição
								lMsa3Ed := .T.
							ElseIf QMU->QMU_TPMSA  == "3" //4 Edição	
								cVarTot:= QMU->QMU_VARTOT 
								lMsa3Ed := .T.
								lMsa4Ed := .T.	       
							Else
								lMsa3Ed := .F.														
							Endif
			            Endif
			    	EndIf
					
					If lMsa4Ed
						cString := "QACHART.DLL - TENDENCIA 4ºEDICAO"
					Else
						cString := "QACHART.DLL - TENDENCIA"
					EndIf
					If lReCal
						//Caso os dois parametros sejam vazios
						If Empty(MV_PAR04) .and. Empty(MV_PAR05)
							MV_PAR04 := "0"
							MV_PAR05 := "9999999999"
						Else
							If Empty(MV_PAR04)
								MV_PAR04 := Alltrim(StrTran(Str(SuperVal(MV_PAR04),Len(MV_PAR04),1),".",","))
							ElseIf Empty(MV_PAR05)
							    MV_PAR05 := Alltrim(StrTran(Str(SuperVal(MV_PAR05),Len(MV_PAR05),1),".",","))
							Endif									
						Endif	
			
						nErmos := SuperVal(QMU->QMU_ERRMSA) 
						nGr     := 0
						If (SuperVal(QMU->QMU_REFER)  >= SuperVal(MV_PAR04)) .And. (SuperVal(QMU->QMU_REFER)  <= SuperVal(MV_PAR05)) 
							nGraph := aScan(aTendencia,{|x| x == "[REFERENCIA]"})
							If ( nGraph == 0 )
								aadd(aTendencia, cString )
								aadd(aTendencia, "[TITLE]" )  
								aadd(aTendencia,"Instr.: "+cInstrumento)

								AADD(aMed64, "Instr.: "+cInstrumento ) //Titulo

								Aadd(aTendencia,"[LANGUAGE]")
								Aadd(aTendencia,Upper(__Language) )

								aadd(aTendencia, "[REFERENCIA]" )
								aadd(aTendencia, QMU->QMU_REFER )
								nDec := Qa_NumDec(QMU->QMU_REFER)
								aadd(aTendencia, "[DECIMAIS]" )
								aadd(aTendencia, Str(nDec,1) )
								aadd(aTendencia, "[LSL]" )
								If cPaisLoc == "BRA"
									aadd(aTendencia, StrTran(Str(SuperVal(QMU->QMU_REFER) - SuperVal(QMU->QMU_TOLER),10,nDec),".",","))
								else
									aadd(aTendencia, StrTran(Str(SuperVal(QMU->QMU_REFER) - SuperVal(QMU->QMU_TOLER),10,nDec),",","."))
								EndiF											
								aadd(aTendencia, "[USL]" )
								If cPaisLoc == "BRA"
									aadd(aTendencia, StrTran(Str(SuperVal(QMU->QMU_REFER) + SuperVal(QMU->QMU_TOLER),10,nDec),".",","))
								else
									aadd(aTendencia, StrTran(Str(SuperVal(QMU->QMU_REFER) + SuperVal(QMU->QMU_TOLER),10,nDec),",","."))
								Endif									
								aadd(aTendencia, "[INICIO DE DADOS]" )
								aadd(aTendencia, AllTrim(iif(cPaisLoc == "BRA",StrTran(QMU->QMU_CICLOS,".",","),StrTran(QMU->QMU_CICLOS,",",".")))) 
							Else
								aadd(aTendencia, AllTrim(iif(cPaisLoc == "BRA",StrTran(QMU->QMU_CICLOS,".",","),StrTran(QMU->QMU_CICLOS,",",".")))) 
							EndIf
							nVRfer := SuperVal(QMU->QMU_REFER) 
							nNrMe++
							nSomMed := nSomMed + SuperVal(QMU->QMU_CICLOS)								
							aadd(aMs3,SuperVal(QMU->QMU_CICLOS))
							aadd(aMed64, Str(aMS3[LEN(aMS3)]))
							aadd(aMedAux, STRZERO(DAY(QMU->QMU_DATA),2,0)+"/"+STRZERO(MONTH(QMU->QMU_DATA),2,0)+"/"+STRZERO(YEAR(QMU->QMU_DATA),4,0)+"00:00"+ AllTrim(iif(cPaisLoc == "BRA",StrTran(QMU->QMU_CICLOS,".",","),StrTran(QMU->QMU_CICLOS,",","."))))
							
							nGr := aScan(aQmuGraf,{|x| Alltrim(x[1])+DtoS(x[3]) == Alltrim(QMU->QMU_REFER)+DtoS(QMU->QMU_DATA)}) 
							If nGr == 0
								Aadd(aQmuGraf,{QMU->QMU_REFER,SuperVal(QMU->QMU_CICLOS),QMU->QMU_DATA,QMU->QMU_CICLOS,QMU->QMU_CICLOS,1})
							Else
								aQmuGraf[nGr][2] += SuperVal(QMU->QMU_CICLOS)								
								
								//Maximo
								If SuperVal(QMU->QMU_CICLOS) > SuperVal(aQmuGraf[nGr][4])
									aQmuGraf[nGr][4] := SuperVal(QMU->QMU_CICLOS)								
								Endif
								
								//Minimo
								If SuperVal(QMU->QMU_CICLOS) < SuperVal(aQmuGraf[nGr][5])
									aQmuGraf[nGr][5] := SuperVal(QMU->QMU_CICLOS)
								Endif

								aQmuGraf[nGr][6]++
								
							Endif	
						Endif
					Endif
				Endif
				dbSelectArea("QMU")
				dbSkip()
			EndDo                         

			// Verifica se o pergunte esta ativo para poder imprimir o grafico de media / amplitude
			If mv_par08 == 1 .and. lMSA3Ed
				nSomasMed := 0
				nSaAmpli  := 0
				For nx := 1 To Len(aQmuGraf)
					aQmuGraf[nx][2] := aQmuGraf[nx][2]/Len(aQmuGraf)				
					aQmuGraf[nx][4] := Abs(SuperVal(aQmuGraf[nx][4]) - SuperVal(aQmuGraf[nx][5]))
					nSomasMed += SuperVal(aQmuGraf[nx][2])
					nSaAmpli  += SuperVal(aQmuGraf[nx][4])
				Next nx
				
				nNominal := nSomasMed/Len(aQmuGraf)	      
				nFtMul := 0
				nMltAmp := 0		
				aXbr := {}
				If Len(aQMUGraf) > 0
					If aQMUGraf[1,6] == 2
						nFtMul := 1.88 
						nMltAmp := 3.27
					ElseIf aQMUGraf[1,6] == 3
						nFtMul := 1.02 
						nMltAmp := 2.57
					ElseIf aQMUGraf[1,6] == 4	 
						nFtMul := 0.73
						nMltAmp := 2.28
					Else
						nFtMul := 0.58
						nMltAmp := 2.211
					Endif			
				Endif            
	
				nSLEv := nNominal + (nFtMul*(nSaAmpli/Len(aQMUGraf)))
				nLIEv := nNominal - (nFtMul*(nSaAmpli/Len(aQMUGraf)))
	            
	
				//Calculo da media da amplitude para o grafico - Tendencia XBR
				nMAmplt := nSaAmpli/Len(aQMUGraf)
	
				nLCSAmp := nMAmplt*nMltAmp
				nDec    := 2	
				//Grafico de xBr 
				aAdd(aXbr,"QACHART.DLL - NORMAL")
				
				aAdd(aXbr,"[USL]")
				If cPaisLoc == "BRA"
					Aadd(aXbr,StrTran(Str(nSLEv,8,nDec),".",","))
				else
					Aadd(aXbr,StrTran(Str(nSLEv,8,nDec),",","."))
				EndIf	
				
				aAdd(aXbr,"[LSL]") 
				if cPaisLoc == "BRA"
					Aadd(aXbr,StrTran(Str(nLIEv,8,nDec),".",","))			
				Else
					Aadd(aXbr,StrTran(Str(nLIEv,8,nDec),",","."))			
				endIf			
				aAdd(aXbr,"[TARGET]")
				If cPaisLoc == "BRA"
					Aadd(aXbr,StrTran(Str(nNominal,8,nDec),".",","))						
				Else
					Aadd(aXbr,StrTran(Str(nNominal,8,nDec),",","."))						
				EndIf				
				aAdd(aXbr,"[TITLE]")
				aAdd(aXbr,	AllTrim(QM2->QM2_INSTR)+" "+QM2->QM2_REVINS)

				Aadd(aXbr,"[LANGUAGE]")
				Aadd(aXbr,Upper(__Language) )
				
				aAdd(aXbr,"[FOOT]")
				aAdd(aXbr,	AllTrim(QM2->QM2_INSTR)+" "+QM2->QM2_REVINS+" "+;
								AllTrim("Carta XBR - Estudo de Tendencia")) 
								
				aAdd(aXbr,"[INICIO DE DADOS]")
				
				cMedi := 	StrZero(Day(dDataBase),2)+"/"+;
							StrZero(Month(dDataBase),2)+"/"+Str(Year(dDataBase),4)+;
							"00:00"
				nItem := 0
				
				For nx := 1 To Len(aMs3)
					nItem++
					aAdd(aXbr,cMedi+AllTrim(Str(aMS3[nx])))
					aadd(aMed64, Str(aMS3[nx]))
				Next nx
					
				aAdd(aXbr,"[FIM DE DADOS]")
				
				aAdd(aXbr,"[SUBGRUPO]")
				If mv_par09 == 0
					mv_par09 := nsGrupo	
				Endif	
				Aadd(aXbr,Str(mv_par09)) //Criar campo para subgrupo.
            Endif
            

			If lMsa3Ed
				If nNrMe > 0
					//Calculo da Media...
					nMeMed := nSomMed/nNrMe					
					//Calculo da Tendencia...
					nTend  := nMeMed-SuperVal(nVRfer)					
					aSort(aMs3,,,{|x,y| x < y })					
					//Calculo da Amplitude...
					nAmpli := aMs3[Len(aMs3)] - aMs3[1]
					//Calculo SigmaR
					//Carrega o array...
					QTC010D2()	
					//Retorna o D2 posicionado...
					If nNrMe > 20
					   nNrMe := 20
					Endif
					nVlD2:= aTbv[nNrMe,1]     
					//Calcula variaveis do calculo da tendencia...
					//cTbrAm := Alltrim(StrTran(Str((aTab[nNrMe,1]/100)/2),".",","))
					cTbrAm := Alltrim(StrTran(Str((nErmos/100)/2),".",","))									
					//Retorna o ultimo D2...
					nUltD2 := aTab[nNrMe,21]
					nSigR  := nAmpli/nVlD2
					nSigaB := aTbv[nNrMe,21]
					
					//Calculo Repetibilidade %EV usado MSA 4 Edição
					If lMsa4Ed
						If !Empty(cVarTot)		
							nPve := 100*(nSigR/SuperVal(cVarTot))
						Else
							nPve := 100*(nSigR/(ABS((SuperVal(aTendencia[11]) - SuperVal(aTendencia[13])))/6))  //Quando não for informado o campo QMU_VARTOT será realizado o calculo utilizando o 6 Sigma e a faixa de tolerancia. 
						EndIf
					EndIf
					
					//Calculo de SigmaB
					nSigB  := nSigR/(nNrMe^0.5)
					//Calculo da invertida...
					If Int(SuperVal(nErmos)) <= 0
						lMsg := .T.					
					Else
						lMsg := .F.	  
						If lInterpol
							lBiCaudal := !(abs(SuperVal(aTab[nNrMe,1])) - abs(round(SuperVal(aTab[nNrMe,1]),0))==0)   
						Else
							lBiCaudal := .F.
						EndIf
						If lBiCaudal                                                                    
							//Calculo do Valor Significativo t (bi-caudal) a partir dos graus de liberdade nErmos
							nTInv  := QM010IntL(SuperVal(aTab[nNrMe,1]),nErmos,Qa_NumDec(cTbrAm))
						Else
							If !lExistChart
								nTInv  := CallDll32("STUDENTINV",cTbrAm+";"+Alltrim(Str(Int(aTab[nNrMe,1]))))
							Else
								nTInv  := QLDSTDINV(SuperVal(cTbrAm), Int(aTab[nNrMe,1]))
							EndIf
						EndIf
					Endif

					nTInv  := SuperVal(nTInv) 
					If lBiCaudal
						nTenLSE:= nTend + ( nSigB * nTInv)
						nTenLIE:= nTend - ( nSigB * nTInv)
					Else			   
					   	nTenLSE:= nTend + ((nSigB*(nSigaB/nVlD2))*nTInv)
						nTenLIE:= nTend - ((nSigB*(nSigaB/nVlD2))*nTInv)
					EndIf
					If nTenLSE < 0 
						cReTen := OemToAnsi(STR0033) //"O sistema de medicao nao e adequado quanto a tendencia"													
					ElseIf nTenLIE > 0 
						cReTen := OemToAnsi(STR0033) //"O sistema de medicao nao e adequado quanto a tendencia"								
					Else
						cReTen := OemToAnsi(STR0034) //"O sistema de medicao e adequado quanto a tendencia"				
					Endif
					aadd(aTendencia, "[FIM DE DADOS]" )	
					aadd(aTendencia, "[MEDIA]" )
					aadd(aTendencia, Alltrim(Str(nMeMed)))
					If lMedNoc
						nGraph := aScan(aTendencia,{|x| x == "[REFERENCIA]"})
						aTendencia[nGraph+1]:= StrTran(Alltrim(Str(nMeMed)),".",",")
					Endif    
                    If lInterpol 
						aadd(aTendencia, "[POLAR]" )
					Endif
	
					If lMsa3Ed
						aadd(aTendencia, "[TEND]" )
					Else
						aadd(aTendencia, "[TENDENCIA]" )
					Endif
	
					aadd(aTendencia, Alltrim(Str(nTend)))
					aadd(aTendencia, "[AMPLT]" )
					aadd(aTendencia, Alltrim(Str(nAmpli)))
					aadd(aTendencia, "[SIGR]" )
					aadd(aTendencia, Alltrim(Str(nSigR)))
					aadd(aTendencia, "[SIGB]" )
					aadd(aTendencia, Alltrim(Str(nSigB)))
					aadd(aTendencia, "[TLIE]" )
					aadd(aTendencia, Alltrim(Str(nTenLIE)))
					aadd(aTendencia, "[TLSE]" )
					aadd(aTendencia, Alltrim(Str(nTenLSE)))
					aadd(aTendencia, "[MSGE]" )
					aadd(aTendencia, Alltrim(cReTen))
					If lMsa4Ed
						aadd(aTendencia, "[PVE]" )
						aadd(aTendencia, Alltrim(Str(nPve)))
					EndIf
				Endif
			Else
				mv_par07 := 2
				aadd(aTendencia, "[FIM DE DADOS]" )		
			Endif	

		Case MV_PAR01 == 2
			aLinear := {}
			aLinearFim := {}
			nNrPec  := 0
			nVRfer  := 0 
			nSomX	:= 0
			nNreMed := 0
			nMedia	:= 0
			nNroTot := 0
			nNroPec := 0
			lMsa3Ed := .F.		
			nMedias := 0
			aMed64  := {}
			dbSeek(xFilial("QMU")+cInstrumento+Dtos(MV_PAR02)+MV_PAR04,.T.)                                           
			cRefer := QMU->QMU_REFER
			While ( !Eof() .And. QMU->QMU_FILIAL == xFilial("QMU") .And.;
										QMU->QMU_INSTR+QMU->QMU_REVINS == cInstrumento .And.;
										QMU->QMU_DATA   <= MV_PAR03)
	
				If lQMC010CO
					lConEst := ExecBlock("QMC010CO",.F.,.F.,{MV_PAR01})
				Endif
            
				If lConEst			
				    If FunName() == "QMTA140"
				    	If mv_par07 == SuperVal(QMU->QMU_TPMSA)
							lReCal := .T.
						Else
							lReCal := .F.	 
							MsgInfo(STR0040) 
							Exit
						Endif
						If QMU->QMU_TPMSA $ "1| "
							lMsa3Ed := .F.					
						ElseIf QMU->QMU_TPMSA  == "2" //3 Edição
							lMsa3Ed := .T.
						ElseIf QMU->QMU_TPMSA  == "3" //4 Edição	
							cVarTot:= QMU->QMU_VARTOT 
							lMsa3Ed := .T.
							lMsa4Ed := .T.       
						Else
							lMsa3Ed := .F.														
						Endif
					Else
						If mv_par06 == SuperVal(QMU->QMU_TPMSA)
							lReCal := .T.
						Else
							lReCal := .F.	 			
						Endif
						If QMU->QMU_TPMSA $ "1| "
							lMsa3Ed := .F.					
						ElseIf QMU->QMU_TPMSA  == "2" //3 Edição
							lMsa3Ed := .T.
						ElseIf QMU->QMU_TPMSA  == "3" //4 Edição	
							cVarTot:= QMU->QMU_VARTOT 
							lMsa3Ed := .T.
							lMsa4Ed := .T.       
						Else
							lMsa3Ed := .F.														
						Endif
					EndIf
                                   
					If lMsa4Ed
						cString := "QACHART.DLL - LINEARIDADE 4ºEDICAO"
					Elseif lMsa3Ed
						cString := "QACHART.DLL - LINEARIDADE 3ºEDICAO"
					Else
						cString := "QACHART.DLL - LINEARIDADE"
					EndIf
					If lReCal
					
						//Caso os dois parametros sejam vazios
						If Empty(MV_PAR04) .and. Empty(MV_PAR05)
							MV_PAR04 := "0"
							MV_PAR05 := "9999999999"
						Else
							If Empty(MV_PAR04)
								MV_PAR04 := Alltrim(StrTran(Str(SuperVal(MV_PAR04),Len(MV_PAR04),1),".",","))
							ElseIf Empty(MV_PAR05)
							    MV_PAR05 := Alltrim(StrTran(Str(SuperVal(MV_PAR05),Len(MV_PAR05),1),".",","))
							Endif									
						Endif	
			
						If (SuperVal(QMU->QMU_REFER)  >= SuperVal(MV_PAR04) .and. SuperVal(QMU->QMU_REFER) <= SuperVal(MV_PAR05))
			              nNroTot++
							nErmos := SuperVal(QMU->QMU_ERRMSA) 
							If QMU->QMU_FILIAL+QMU->QMU_INSTR+QMU->QMU_REVINS+QMU->QMU_REFER == xFilial("QMU")+cInstrumento+cRefer
								nNreMed++				
							Endif			
			
							nGraph := aScan(aLinear,{|x| x[1] == QMU->QMU_REFER}) 
							If ( nGraph == 0 )
								nMedias := nMedias + SuperVal(QMU->QMU_REFER)
								nNroPec++
								If lMsa3Ed
									aadd(aLinear,{ QMU->QMU_REFER , 1 , SuperVal(QMU->QMU_CICLOS),;
												SuperVal(QMU->QMU_CICLOS),((-1*SuperVal(QMU->QMU_REFER))+SuperVal(QMU->QMU_CICLOS))})
								Else
									aadd(aLinear,{ QMU->QMU_REFER , 1 , SuperVal(QMU->QMU_CICLOS),;
												SuperVal(QMU->QMU_CICLOS)})
								Endif				
								nVarPro := SuperVal(QMU->QMU_TOLER)
								
								aAdd(aLimites,SuperVal(QMU->QMU_REFER)+ SuperVal(QMU->QMU_TOLER)) //Limite Superior
	 							aAdd(aLimites,SuperVal(QMU->QMU_REFER)- SuperVal(QMU->QMU_TOLER)) //Limite Inferior
							Else
								aLinear[nGraph,2] ++
								aLinear[nGraph,3] += SuperVal(QMU->QMU_CICLOS)
								aLinear[nGraph,4] := aLinear[nGraph,3]/aLinear[nGraph,2] 
								If lMsa3Ed
									Aadd(aLinear[nGraph],((-1*SuperVal(QMU->QMU_REFER))+SuperVal(QMU->QMU_CICLOS)))
								Endif	
							EndIf
						Endif
					Endif
				Endif
				dbSelectArea("QMU")
				dbSkip()
			EndDo
		
			//Utilziado para instrumentos que possuem MSA 2 e 3 edição
			If !lMsa3Ed .and. mv_par07==1
				If !Empty(nErmos)
					lMsa3Ed := .T.
					lRecal  := .T.
				EndIf
			EndIf		
					
			If !lMsa3Ed 
				mv_par07 := 2																				
			Endif	
			If lReCal
	
				aLinear := aSort(aLinear,,,{|x,y| SuperVal(x[1])<SuperVal(y[1])})
		
				For nCntFor := 1 To Len(aLinear)
					nX      := SuperVal(aLinear[nCntFor,1])
					nY      := aLinear[ncntFor,4]-SuperVal(aLinear[nCntFor,1])
					nSomaX  += nX
					nSomaY  += nY
					nSomaXY += nX*nY
					nSomaX2 += nX**2
					nSomaY2 += nY**2 
					if lMsa4Ed 
						For nCount := 5 to nNreMed + 4
							nSomaY2a += alinear[nCntFor,ncount]**2
						Next nCount					
					EndiF
				Next nCntFor
				nLinearA := (nSomaXY-(nSomax*nSomaY/Len(aLinear)))/;
								((nSomaX2)-((nSomaX**2)/Len(aLinear)))
				nLinearA := Round(nLinearA,4)
				nLinearB := (nSomaY-(nLinearA*nSomaX))/Len(aLinear)
				nLinearB := Round(nLinearB,4)
				if !lMsa4Ed
					nLinearR2:= ((nSomaXY-(nSomaX*nSomaY/Len(aLinear)))**2)/;
									((nSomaX2-((nSomaX**2)/Len(aLinear)))*(nSomaY2-((nSomaY**2)/Len(aLinear))))
					nLinearR2:= Round(nLinearR2,4)				
				else
					nLinearR2:= ((nSomaXY*nNreMed)-(((nSomaX*nNreMed) * (nSomaY*nNreMed))/(Len(aLinear) * nNreMed)))**2 / ((nSomaY2a - (((nSomaY*nNreMed)**2) / ;
								 (Len(aLinear) * nNreMed))) * ((nSomaX2 * nNreMed) - (((nSomaX*nNreMed)**2) / (Len(aLinear) * nNreMed)))) 
					nLinearR2:= Round(nLinearR2,4)*100
				EndIf
				nLinearVp:= Round(nVarPro,4)
				nLinear  := Round(Abs(nLinearA)*nLinearVp,4)
				nLinearP := Round(100*nLinear/nLinearVp,4)
		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Cria arquivo texto para geracao do grafico                    ³
				//³ ATENCAO: NAO ALTERAR A SEQUENCIA DAS VARIAVEIS DO BLOCO ABAIXO³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (nSomaY/Len(aLinear)) < 0
					nTende := (nSomaY/Len(aLinear)) * -1 //Inverter sinal
				Else
					nTende := (nSomaY/Len(aLinear)) 
				Endif
				
				aadd(aLinearFim, cString )
				aadd(aLinearFim, "[TITLE]" )  
				aadd(aLinearFim,"Instr.: "+cInstrumento)

				AADD(aMed64, "Instr.: "+cInstrumento ) //Titulo

				Aadd(aLinearFim,"[LANGUAGE]")
				Aadd(aLinearFim,Upper(__Language) )

				If !lMsa3Ed
				    if cPaisLoc == "BRA"
						aadd(aLinearFim, "[LINEAR%]" )
						aadd(aLinearFim, AllTrim( StrTran( Str( nLinearP ), ".","," ) ) )
						aadd(aLinearFim, "[GRAU]" )
						aadd(aLinearFim, AllTrim( StrTran( Str( nLinearR2 ),".","," ) )+ '%' )
						aadd(aLinearFim, "[LINEAR]" )
						aadd(aLinearFim, AllTrim( StrTran( Str( nLinear ), ".","," ) ) )
						aadd(aLinearFim, "[TENDENCIA]" )
						aadd(aLinearFim, AllTrim( StrTran( Str( nTende ),".",",") ) )
   	                Else
						aadd(aLinearFim, "[LINEAR%]" )
						aadd(aLinearFim, AllTrim( StrTran( Str( nLinearP ), ",","." ) ) )
						aadd(aLinearFim, "[GRAU]" )
						aadd(aLinearFim, AllTrim( StrTran( Str( nLinearR2 ),",","." ) )+ '%' )
						aadd(aLinearFim, "[LINEAR]" )
						aadd(aLinearFim, AllTrim( StrTran( Str( nLinear ), ",","." ) ) )
						aadd(aLinearFim, "[TENDENCIA]" )
						aadd(aLinearFim, AllTrim( StrTran( Str( nTende ),",",".") ) )
					EndIf						
				Else
					If cPaisLoc == "BRA"
						aadd(aLinearFim, "[GRAU]" )
						aadd(aLinearFim, AllTrim( StrTran( Str( nLinearR2 ),".","," ) ) + '%' )					
						aadd(aLinearFim, "[TENDENCIA]" )
						If nLinearA < 0
							aadd(aLinearFim, "y = " +AllTrim( StrTran( Str( nLinearB )+"-"+AllTrim(Str( nLinearA * -1 ))+"x",".",",") ) ) //Inverter sinal
						Else
							aadd(aLinearFim, "y = " +AllTrim( StrTran( Str( nLinearB )+"+"+AllTrim(Str( nLinearA ))+"x",".",",") ) ) 
						Endif
					Else
						aadd(aLinearFim, "[GRAU]" )
						aadd(aLinearFim, AllTrim( StrTran( Str( nLinearR2 ),",","." ) ) + '%' )					
						aadd(aLinearFim, "[TENDENCIA]" )
						If nLinearA < 0
							aadd(aLinearFim, "y = " +AllTrim( StrTran( Str( nLinearB )+"-"+AllTrim(Str( nLinearA * -1 ))+"x",",",".") ) ) //Inverter sinal
						Else
							aadd(aLinearFim, "y = " +AllTrim( StrTran( Str( nLinearB )+"+"+AllTrim(Str( nLinearA ))+"x",",",".") ) ) 
						Endif
					EndIF	
				Endif
				aadd(aMed64, aLinearFim[07]) //Grau de Ajuste(R2)
				aadd(aMed64, aLinearFim[09]) //Têndencia
				aadd(aMed64, {}) 
				aadd(aMed64, {}) 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Monta pontos da reta                                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aadd(aLinearFim, "[RETA]" )
				aRetaMed64 := {}
				For nCntFor := 1 to len(aLinear)
					 aadd(aLinearFim,aLinear[nCntFor,1]+";"+;
						  AllTrim(StrTran(Str(nLinearB + nLinearA * SuperVal(aLinear[nCntFor,1])),".",",")))
					aadd(aRetaMed64, aLinearFim[Len(aLinearFim)])
				Next nCntFor
				aadd(aLinearFim, "[FIM RETA]" )
				aadd(aMed64, aRetaMed64) //Regressão     

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Monta pontos de tendencia                                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aadd(aLinearFim, "[MEDIA]" )
				aMedTena64 := {}
				For nCntFor := 1 to len(aLinear)
					aadd(aLinearFim,aLinear[nCntFor,1]+";"+;
							AllTrim(StrTran(Str(aLinear[nCntFor,4]-;
							SuperVal(aLinear[nCntFor,1])),".",",")))
					aadd(aMedTena64, aLinearFim[Len(aLinearFim)])
				Next nCntFor
				aadd(aLinearFim, "[FIM MEDIA]" )
				aadd(aMed64, aMedTena64) //Médias das Têndencias

		        If lMsa3Ed 
					nVll	:= 0
					nSomExp	:= 0     
					nSomYs	:= 0
					nSomXs	:= 0
					nSomPtos := 0
					nSomXYs	:= 0
					nSomYAs	:= 0			 
					nSxQuads := 0
					nMedias  := nMedias / nNroPec 
					For nx := 1 To Len(aLinear)
						nSomXs	:= nSomXs + SuperVal(aLinear[nx][1])
						nSxQuads := nSxQuads + SuperVal(aLinear[nx][1])^2
						For ny := 5 To Len(aLinear[nx])
							nGAx := aScan(aLinAux,{|x| x[1] == aLinear[nx][1]}) 
							nSomExp := nSomExp + (aLinear[nx][ny]^2)
							If nGAx == 0
								Aadd(aLinAux,{aLinear[nx][1],(aLinear[nx][ny]^2)})
							Else
								Aadd(aLinAux[nGAx],(aLinear[nx][ny]^2))
							Endif
							nSomPtos := nSomPtos + (aLinear[nx][ny]^2)
							nSomYAs := nSomYAs + aLinear[nx][ny]
							nSomYs := nSomYs + aLinear[nx][ny]
						Next ny
						Aadd(aLinear[nx],nSomYAs*SuperVal(aLinear[nx][1]))
						nSomYAs := 0
					Next nx
					nSomXs	:= nSomXs * nNreMed	
					nSxQuads := nSxQuads * nNreMed	
		            aFinal := aClone(aLinear)
		            //aLinear := {}
		            //Estrutura do aLinear..
		            //1		Ponto
		            //2		Soma Y...
		            //3		Soma X...	
		            //4		Soma XY
		            //5		Soma X quadrado
		            //6		Valor A
		            //7		Valor B
		            //8		Calculo do S
		            //9		Somatoria X - X Media
		            //10	Calculo do Ta Modulo
		            //11	Calculo do Ta Critico
		            //12	Calculo do Tb Modulo
		            //13	Calculo do Tb Critico	
					nSSQd := 0
		            For nx := 1 To Len(aFinal)
						nSomXYs	:= nSomXYs + aFinal[nx,Len(aFinal[nx])]				             
						nSSQd	:= nSSQd + ((SuperVal(aFinal[nx][1]) - nMedias)^2)
		            Next nx
		
					nCalcA := ((nSomXYs-(nSomYs*nSomXs/nNroPec/nNreMed))/(nSxQuads-(nSomXs^2)/nNroPec/nNreMed))
					
					nCalcB := (nSomYs/nNroPec/nNreMed)-nCalcA*nMedias 
					
					nCalcS := ((nSomExp-nCalcB*nSomYs-nCalcA*nSomXYs)/(nNroPec*nNreMed-2))^0.5
					
					//Calculo Repetibilidade %VE usado MSA 4 Edição
					If lMsa4Ed
						If !Empty(cVarTot)		
							nPve := 100*(nCalcS/SuperVal(cVarTot))
						Else
							nPve := nPve := 100*(nCalcS/(ABS(aLimites[1] - aLimites[2])/6))   //Quando não for informado o campo QMU_VARTOT será realizado o calculo utilizando o 6 Sigma e a faixa de tolerancia. 
						EndIf
					EndIf
					
					//Calculo da Somatoria X - X Media
					nCaxMed := nNreMed * nSSQd
					
					//Calculo de Hipotese A
					//nTa := Abs(nCalcA)/(nCalcS/(nCaxMed^0.5))    
					nTa := nCalcA/(nCalcS/(nCaxMed^0.5))   
					aadd(aLinearFim, "[NTA]" )	
					aadd(aLinearFim, Alltrim(Str(nTa)))	
					//Calculo de Hipotese B
					nTb := Abs(nCalcB)/(nCalcS*(((1/nNroPec/nNreMed)+(nMedias^2/nCaxMed))^0.5))
					aadd(aLinearFim, "[NTB]" )	
					aadd(aLinearFim, Alltrim(Str(nTb)))	
										
					nErmos := ((nErmos/100)/2)
					
					nErmos := StrTran(Alltrim(Str(nErmos)),".",",")

					IF !lExistChart
						nTCritA := CallDll32("STUDENTINV",nErmos+";"+Alltrim(Str(nNroTot-2)))
					ELSE
						nTCritA := QLDSTDINV(SUPERVAL(nErmos), nNroTot-2)
					ENDIF
	
					aadd(aLinearFim, "[TCRITA]" )	
					aadd(aLinearFim, iif (cPaisLoc == "BRA",StrTran(Alltrim(Str(superval(nTCritA))),".",","),StrTran(Alltrim(Str(superval(nTCritA))),",",".")))
					
					aadd(aLinearFim, "[TCRITB]" )	
					aadd(aLinearFim, iif (cPaisLoc == "BRA",StrTran(Alltrim(Str(superval(nTCritA))),".",","),StrTran(Alltrim(Str(superval(nTCritA))),",",".")))
		
					aadd(aLinearFim, "[PONTOS]" )
					aPtsaMed64 := {}
					For nCntFor := 1 to len(aLinear)
						For nX:=5 to Len(aLinear[nCntFor])-1 
						    if cPaisLoc == "BRA"
								AADD(aLinearFim,aLinear[nCntFor,1]+";"+AllTrim(StrTran(Str(SuperVal(aLinear[nCntFor,nX])),".",",")))
						    Else
								AADD(aLinearFim,aLinear[nCntFor,1]+";"+AllTrim(StrTran(Str(SuperVal(aLinear[nCntFor,nX])),".",",")))								
						    EndIf
							aadd(aPtsaMed64, aLinearFim[Len(aLinearFim)])
						Next nX  
					Next nCntFor          
					aadd(aLinearFim, "[FIM PONTOS]" )     
					aadd(aMed64, aPtsaMed64) //Resultados Intermediários 

					aLinear := {}

					//Analises
					If nTa > SuperVal(nTCritA)
						cAnaLin1 := OemToAnsi(STR0035) //"A tendencia nao e igual ao longo da faixa de medicao"
					Else
						cAnaLin1 := OemToAnsi(STR0036) //"A tendencia e igual ao longo da faixa de medicao"
					Endif          
					
					If SuperVal(nTb) > SuperVal(nTCritA)
						cAnaLin2 := OemToAnsi(STR0037) //"A tendencia nao e igual a zero"
					Else
						cAnaLin2 := OemToAnsi(STR0038) //"A tendencia e igual a zero"
					Endif          
	
					aadd(aLinearFim, "[MSGA]" )	
					aadd(aLinearFim, Alltrim(cAnaLin1))	
		
					aadd(aLinearFim, "[MSGB]" )	
					aadd(aLinearFim, Alltrim(cAnaLin2))	
	
					For nx := 1 To Len(aLinAux)
						//Deslocamento
						IF !lExistChart
							nInv := SuperVal(CallDll32("STUDENTINV",nErmos+";"+Alltrim(Str(Int(nNroPec*nNreMed-2)))))
 						ELSE
							nInv := QLDSTDINV(SUPERVAL(nErmos), Int(nNroPec*nNreMed-2))
						ENDIF
						nDeslo := nCalcS*SuperVal(nInv)*((((1/nNroPec/nNreMed)+((SuperVal(aLinAux[nx][1])-nMedias)^2)/nCaxMed))^0.5)
						//Reta
						nBx0 := nCalcB+nCalcA*SuperVal(aLinAux[nx][1])
						//Deslocamento + Reta
						nDMaBx0 := nBx0+nDeslo
						//Deslocamento - Reta
						nDMiBx0 := nBx0-nDeslo				
						AADD(aRetasL,{nDMaBx0,nDMiBx0})
					Next nx
				
					//Linhas de Confiança
					aadd(aLinearFim, "[RETA SUPERIOR]" )
					aRetSupa64 := {}
					For nX:=1 to Len(aRetasL)
						 if cPaisLoc == "BRA"
							 aadd(aLinearFim,aLinAux[nx][1]+";"+;
			    			 AllTrim(StrTran(Str(aRetasL[nX,1]),".",",")))
						 Else
							 aadd(aLinearFim,aLinAux[nx][1]+";"+;
			    			 AllTrim(StrTran(Str(aRetasL[nX,1]),",",".")))						 
						 EndIf
						 aadd(aRetSupa64, aLinearFim[Len(aLinearFim)])
					Next nX
					aadd(aLinearFim, "[FIM RETA SUPERIOR]" )
					aadd(aMed64, aRetSupa64) //Intervalo de Confiança Superior     
					
					aadd(aLinearFim, "[RETA INFERIOR]" )
					aRetInfa64 := {}
					For nX := 1 to len(aRetasL)
						 if cPaisLoc == "BRA"
	  						 aadd(aLinearFim,aLinAux[nX][1]+";"+;
			    			 AllTrim(StrTran(Str(aRetasL[nX,2]),".",",")))
						 Else
	  						 aadd(aLinearFim,aLinAux[nX][1]+";"+;
						 	 AllTrim(StrTran(Str(aRetasL[nX,2]),",",".")))
						 EndIf
						 aadd(aRetInfa64, aLinearFim[Len(aLinearFim)])						 	 
					Next nX
					aadd(aLinearFim, "[FIM RETA INFERIOR]" )
					aadd(aMed64, aRetInfa64) //Intervalo de Confiança Superior     
				Endif
				If lMsa4Ed
					aadd(aLinearFim, "[PVE]" )
					aadd(aLinearFim, Alltrim(Str(nPve)))
				EndIf
	        Endif
		Case MV_PAR01 == 3
			aEstab := {}
			nNroAmo := 0        
			nNreMed := 0
			aVlr	:= {} 
			aNov	:= {}		
			cString := "QACHART.DLL - ESTABILIDADE"		
			lMsa3Ed := .F.
			nRefer  := 0
			nSubG   := 0
			lConts	:= .T.
			dbSeek(xFilial("QMU")+cInstrumento+Dtos(MV_PAR02)+MV_PAR04,.T.)
			nMaior := SuperVal(QMU->QMU_CICLOS)
			nMenor := SuperVal(QMU->QMU_CICLOS)
			nNre   := 0
			nVlD2  := 0	
			nsGrupo := 0
			aMedic := {}
			While ( !Eof() .And. QMU->QMU_FILIAL == xFilial("QMU") .And.;
										QMU->QMU_INSTR+QMU->QMU_REVINS == cInstrumento .And.;
										QMU->QMU_DATA   <= MV_PAR03 )
				nNre++
				If lQMC010CO
					lConEst := ExecBlock("QMC010CO",.F.,.F.,{MV_PAR01})
				Endif
            
				If lConEst			

					If Len(aEstab) == 0
				    	If FunName() == "QMTA140"
							If mv_par07 == SuperVal(QMU->QMU_TPMSA)
								lReCal := .t.
							Else
								lReCal := .f. 
								MsgInfo(STR0040) 
								Exit										 			
							Endif
							If QMU->QMU_TPMSA $ "1| "
								lMsa3Ed := .F.					
							ElseIf QMU->QMU_TPMSA  $ "2|3 "//MSA 3ª Edição ou Superior.
								lMsa3Ed := .T.    
							Else
								lMsa3Ed := .F.														
							Endif
						Else
							If mv_par06 == SuperVal(QMU->QMU_TPMSA)
								lReCal := .t.
							Else
								lReCal := .f.	 			
							Endif
							If QMU->QMU_TPMSA $ "1| "
								lMsa3Ed := .F.					
							ElseIf QMU->QMU_TPMSA  $ "2|3 "//MSA 3ª Edição ou Superior.
								lMsa3Ed := .T.     
							Else
								lMsa3Ed := .F.														
							Endif
						EndIf
			    	Endif
					If lReCal
						//Caso os dois parametros sejam vazios
						If Empty(MV_PAR04) .and. Empty(MV_PAR05)
							MV_PAR04 := "0"
							MV_PAR05 := "9999999999"
						Else
							If Empty(MV_PAR04)
								MV_PAR04 := Alltrim(StrTran(Str(SuperVal(MV_PAR04),Len(MV_PAR04),1),".",","))
							ElseIf Empty(MV_PAR05)
							    MV_PAR05 := Alltrim(StrTran(Str(SuperVal(MV_PAR05),Len(MV_PAR05),1),".",","))
							Endif									
						Endif	
						
						If (SuperVal(QMU->QMU_REFER)  >= SuperVal(MV_PAR04) .And. SuperVal(QMU->QMU_REFER)  <= SuperVal(MV_PAR05))
							
							nErmos := SuperVal(QMU->QMU_ERRMSA) 
							nGraph := aScan(aEstab,{|x| x == "[REFERENCIA]"})
			
							If ( nGraph == 0 )
								nRefer := SuperVal(QMU->QMU_REFER)
								If lConts 
									nSubG++
								Endif	
								aadd(aEstab, cString )
								aadd(aEstab, "[TITLE]" )  
								aadd(aEstab,"Instr.: "+cInstrumento)

								Aadd(aEstab,"[LANGUAGE]")
								Aadd(aEstab,Upper(__Language) )

								aadd(aEstab, "[REFERENCIA]" )
								aadd(aEstab, QMU->QMU_REFER )
								nDec := Qa_NumDec(QMU->QMU_REFER)
								aadd(aEstab, "[DECIMAIS]" )
								aadd(aEstab, Str(nDec,1) )
								aadd(aEstab, "[INICIO DE DADOS]" )
								If (mv_par06 == SuperVal(QMU->QMU_TPMSA))
									aadd(aVlr, STRZERO(DAY(QMU->QMU_DATA),2,0)+"/"+STRZERO(MONTH(QMU->QMU_DATA),2,0)+"/"+STRZERO(YEAR(QMU->QMU_DATA),4,0)+"00:00"+ AllTrim(iif(cPaisLoc == "BRA",StrTran(QMU->QMU_CICLOS,".",","),StrTran(QMU->QMU_CICLOS,",",".")))) 
									aadd(aMed64, AllTrim(iif(cPaisLoc == "BRA",StrTran(QMU->QMU_CICLOS,".",","),StrTran(QMU->QMU_CICLOS,",","."))))
								Endif
								dData := QMU->QMU_DATA
								nSoma := SuperVal(QMU->QMU_CICLOS)
								nMaior:= SuperVal(QMU->QMU_CICLOS)
								nMenor:= SuperVal(QMU->QMU_CICLOS)
								nAcum := 1        
								nNroAmo++
								nNreMed++
							Else
								If dData == QMU->QMU_DATA
									nNreMed++
									If lConts
										nSubG++
									Endif	
									nSoma += SuperVal(QMU->QMU_CICLOS)
									nAcum += 1
									If SuperVal(QMU->QMU_CICLOS) > nMaior
										nMaior := SuperVal(QMU->QMU_CICLOS)
									Endif
			                        cUltVlr := QMU->QMU_CICLOS
									If SuperVal(QMU->QMU_CICLOS) < nMenor
										nMenor := SuperVal(QMU->QMU_CICLOS)
									Endif                          
									If (mv_par06 == SuperVal(QMU->QMU_TPMSA))                          
										aadd(aVlr, STRZERO(DAY(QMU->QMU_DATA),2,0)+"/"+STRZERO(MONTH(QMU->QMU_DATA),2,0)+"/"+STRZERO(YEAR(QMU->QMU_DATA),4,0)+"00:00"+AllTrim(iif(cPaisLoc == "BRA",StrTran(QMU->QMU_CICLOS,".",","),StrTran(QMU->QMU_CICLOS,",",".")))) 
										aadd(aMed64, AllTrim(iif(cPaisLoc == "BRA",StrTran(QMU->QMU_CICLOS,".",","),StrTran(QMU->QMU_CICLOS,",","."))))
									Endif
								Else
									lConts := .F.
									If lMsa3Ed
										nRefer := SuperVal(QMU->QMU_REFER)
										nSomAmp := nSomAmp + (nMaior - nMenor)
									Endif	
									aadd(aEstab, STRZERO(DAY(dData),2,0)+"/"+STRZERO(MONTH(dData),2,0)+"/"+STRZERO(YEAR(dData),4,0)+AllTrim(StrTran(Str(nSoma/nAcum,10,nDec),".",",")))
									nSomMed := nSomMed + (nSoma/nAcum)
									If !Eof() .and. QMU->QMU_FILIAL == xFilial("QMU") .And.;
										QMU->QMU_INSTR+QMU->QMU_REVINS == cInstrumento .And.;
										QMU->QMU_DATA <= MV_PAR03
										If (SuperVal(QMU->QMU_REFER)  >= SuperVal(MV_PAR04) .and. SuperVal(QMU->QMU_REFER)  <= SuperVal(MV_PAR05)) 
											nSoma := SuperVal(QMU->QMU_CICLOS)
											nAcum := 1
											dData := QMU->QMU_DATA
											nMaior := SuperVal(QMU->QMU_CICLOS)
											nMenor := SuperVal(QMU->QMU_CICLOS)
											nNroAmo++
											nNreMed :=0 
											If (mv_par06 == SuperVal(QMU->QMU_TPMSA)) 
												aadd(aVlr, STRZERO(DAY(QMU->QMU_DATA),2,0)+"/"+STRZERO(MONTH(QMU->QMU_DATA),2,0)+"/"+STRZERO(YEAR(QMU->QMU_DATA),4,0)+"00:00"+AllTrim(iif(cPaisLoc == "BRA",StrTran(QMU->QMU_CICLOS,".",","),StrTran(QMU->QMU_CICLOS,",",".")))) 
												aadd(aMed64, AllTrim(iif(cPaisLoc == "BRA",StrTran(QMU->QMU_CICLOS,".",","),StrTran(QMU->QMU_CICLOS,",","."))))
											Endif
										Endif
									EndIf
								EndIf
							EndIf
						Endif
					Endif
				Endif
				dbSelectArea("QMU")
				dbSkip()
			EndDo
			
			If mv_par01 == 3 .AND. (mv_par06 == 2 .or. mv_par06 == 3) // Validacao de qtde. de medicoes coletadas p/ dia no intervalo para Grafico de Estabilidade MSA 3 Edicao
				nTamVlr := Len(aVlr)
				If nTamVlr > 0 
					cDataAtu := Substr(aVlr[1],1,10)
				EndIf
				Aadd(aQtdeMedDia,0)
				For nK:=1 To Len(aVlr)
					If Alltrim(cDataAtu) == Alltrim(Substr(aVlr[nk],1,10))
						aQtdeMedDia[Len(aQtdeMedDia)]++
					Else
					    cDataAtu := Substr(aVlr[nk],1,10)
						Aadd(aQtdeMedDia,1)
					Endif
				Next nK				
				nsGrupo := aQtdeMedDia[1]
	
				For nK:=1 To Len(aQtdeMedDia) // Validacao para verificar se no periodo ha numero igual de medicoes por dia
					For nJ:=2 To Len(aQtdeMedDia)
						If aQtdeMedDia[nK] <> aQtdeMedDia[nJ]
							HELP(" ",1,"QMC10QTMED")
							Return(NIL)
						Endif
					Next nJ
				Next nK
	
			Endif
			
			// Ultima linha
			aadd(aEstab, STRZERO(DAY(dData),2,0)+"/"+STRZERO(MONTH(dData),2,0)+"/"+STRZERO(YEAR(dData),4,0)+AllTrim(StrTran(Str(nSoma/nAcum,10,nDec),".",",")))
			If !lMsa3Ed .AND. Len(aEstab) <=  9 // Um aEstab com 9 linhas   tem  somente uma  data
				MsgInfo(STR0041)	
				aEstab := {} // Zero o Array
			EndIf
			If lMsa3Ed .and. lReCal
				Aadd(aNov,"QACHART.DLL - NORMAL") 
	
				aadd(aNov, "[TITLE]" )
				aadd(aNov, OemToAnsi(STR0039)+Alltrim(cInstrumento)) //Instrumento:			 

				Aadd(aNov,"[LANGUAGE]")
				Aadd(aNov,Upper(__Language) )

				aadd(aNov, "[INICIO DE DADOS]" )
				For ny := 1 To Len(aVlr)
					aadd(aNov,aVlr[ny]) 			
				Next ny
				aadd(aNov, "[FIM DE DADOS]")  
				nNreMed := nNre 
				nSomMed := (nSomMed + (nSoma/nAcum))/(nNroAmo)
				nSomAmp := (nSomAmp + (nMaior - nMenor))/nNroAmo
				
				If nNreMed == 2
					nConst := 1.88
				Else
					If nNreMed == 3
						nConst := 1.02
					Else
						IF nNreMed == 4
							nConst := 0.73
						Else
							nConst := 0.58
				        Endif
					Endif
				Endif				        
	
				nSomLSE := nSomMed + nSomAmp*nConst
				nSomLIE := nSomMed - nSomAmp*nConst			             
	
				If nNreMed == 2
					nConst := 3.27
				Else
					If nNreMed == 3
						nConst := 2.57
					Else
						If nNreMed == 4
							nConst := 2.28
						Else
							nConst := 2.211
						Endif
					Endif
				Endif	
	
				//Calculo para serem mostrados no relatorio MSA 3 Edicao
				
				nTend := nSomMed - nRefer
	
	            //Carrega a tabela D2
				QTC010D2()
				If nNreMed > 20
					nNreAu := 20					
				Else
					nNreAu := nNreMed
				Endif
				
				nVlD2:= aTbv[nNreAu,1]     
				If nNroAmo >  21
					nNroAu := 21
				Else
					nNroAu := nNroAmo
				Endif

				nSigR  := nSomAmp/nVlD2

				//nSigR := nSomAmp/aTbv[nNreAu,nNroAu]
				
				nSigB  := nSigR/(nNreAu^0.5)

				//nSigB := nSigR/((nNreAu*nNroAu)^0.5)
				
				nErmos := Alltrim(StrTran(Str((nErmos/100)/2),".",","))		

				If !lExistChart
					nTInv := SuperVal(CallDll32("STUDENTINV",nErmos+";"+Alltrim(Str(Int(aTab[nNreAu,nNroAu])))))
				Else
					nTInv := SUPERVAL(QLDSTDINV(SUPERVAL(nErmos), Int(aTab[nNreAu,nNroAu])))
				EndIf

				nTendLSE := nTend + ((nSigB * (aTbv[nNreAu,21]/aTbv[nNreAu,nNroAu]))*nTInv)
				
				nTendLIE := nTend - ((nSigB * (aTbv[nNreAu,21]/aTbv[nNreAu,nNroAu]))*nTInv)		
	
				If nRefer ==0
					cReten := ""
				Else
					If nRefer < 0
						cReTen := OemToAnsi(STR0033)		//"O sistema nao e adequado quanto a tendencia"
					Else
						If nTendLIE > 0
							cReTen := OemToAnsi(STR0033)	//"O sistema nao e adequado quanto a tendencia"
						Else
							cReTen := OemToAnsi(STR0034)	//"O sistema de medicao e adequado quanto a tendencia"
						Endif	
					Endif
				Endif				
			Endif	
	
			If lMsa3Ed .and. lReCal
				aadd(aNov, "[SUBGRUPO]")			
				aadd(aNov, Alltrim(Str(IIF(MV_PAR09 == 0, nsGrupo, MV_PAR09))))	
				aadd(aNov, "[MSGE]")					
				aadd(aNov, Alltrim(cReTen))								
				aadd(aNov, "[TEND]")					
				aadd(aNov, Alltrim(Str(nTend)))								
				aadd(aNov, "[SIGR]")					
				aadd(aNov, Alltrim(Str(nSigR)))								
				aadd(aNov, "[SIGB]")					
				aadd(aNov, Alltrim(Str(nSigB)))								
				aadd(aNov, "[TLSE]")					
				aadd(aNov, Alltrim(Str(nTendLSE)))								
				aadd(aNov, "[TLIE]")					
				aadd(aNov, Alltrim(Str(nTendLIE)))								
			Else
				aadd(aEstab, "[FIM DE DADOS]" )
			Endif

		EndCase	
Else //lCalib
	aArea := GetArea()

	If Empty(MV_PAR04) .and. Empty(MV_PAR05)
		MV_PAR04 := "0"
		MV_PAR05 := "9999999999"
	Else
		If Empty(MV_PAR04)
			MV_PAR04 := Alltrim(StrTran(Str(SuperVal(MV_PAR04),Len(MV_PAR04),1),".",","))
		ElseIf Empty(MV_PAR05)
			MV_PAR05 := Alltrim(StrTran(Str(SuperVal(MV_PAR05),Len(MV_PAR05),1),".",","))
		Endif
	Endif

cInsQuer  := SubStr(cInstrumento,1,TamSx3("QM2_INSTR")[1])
cRevQuer  := SubStr(cInstrumento,17,TamSx3("QM2_REVINS")[1])

dbSelectArea("QM7")
dbSetOrder(1)
cKey   := "QM7_FILIAL+QM7_INSTR+QM7_REVINS+QM7_DATA"
   	cQuery := "SELECT QM7.QM7_FILIAL,QM7.QM7_INSTR,QM7.QM7_REVINS,QM7.QM7_DATA,QM7.QM7_CSEQ,QM7.QM7_ESCALA,"
   	cQuery += "QM7.QM7_REVESC,QM7.QM7_PONTO,QM7.QM7_REVPAD,QM7.QM7_ESPEC "
cQuery += "FROM " + RetSqlName("QM7")+" QM7 "
cQuery += "WHERE QM7.QM7_FILIAL='"+xFilial("QM7")+"' AND "
cQuery += "QM7.QM7_INSTR='"+cInsQuer+"' AND "
cQuery += "QM7.QM7_REVINS ='"+ cRevQuer +"'  AND "			
cQuery += "QM7.QM7_DATA >='"+ DtoS(MV_PAR02)  +"'  AND "
cQuery += "QM7.QM7_DATA <='"+ DtoS(MV_PAR03)  +"'  AND "
cQuery += "QM7.QM7_ESPEC <>'"+ Space(10) +"'  AND "
cQuery += "QM7.D_E_L_E_T_<>'*' "
    
    If Upper(TcGetDb()) $ "ORACLE.INFORMIX"
	cQuery += " ORDER BY 1,2,3,4"
Else
	cQuery += " ORDER BY " + SqlOrder(cKey)
Endif

cQuery := ChangeQuery(cQuery)			

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"TRB", .F., .T.)

TcSetField("TRB","QM7_DATA","D",8,0)

nVll	 := 0
nSomExp	 := 0     
nSomYs	 := 0
nSomXs	 := 0
nSomPtos := 0
nSomXYs	 := 0
nSomYAs	 := 0			 
nSxQuads := 0
nMedias  := 0


dbGoTop()

While !Eof()
	TRB_ERMAS := ""
	TRB_FILIAL	:= TRB->QM7_FILIAL
	TRB_INSTR	:= TRB->QM7_INSTR
	TRB_REVINS	:= TRB->QM7_REVINS
	TRB_DATA	:= TRB->QM7_DATA    	
	TRB_REFER	:= TRB->QM7_ESPEC
	TRB_ESCALA	:= TRB->QM7_ESCALA	    	   
	TRB_REVESC	:= TRB->QM7_REVESC	    	   			
	TRB_PONTO	:= TRB->QM7_PONTO
	TRB_REVPAD	:= TRB->QM7_REVPAD
	TRB_CSEQ	:= TRB->QM7_CSEQ
	
	//Busca a tolerancia do processo         			
	dbSelectArea("QMR")
	QMR->( DbSetOrder(1) )
	DbSeek(xFilial('QMR')+cInstrumento+TRB_ESCALA)
	If Empty(QMR->QMR_TOLPRO)
		lTolPro := .F.		
	EndIf
	cEscallas 	:= ""
	If TRB_DATA <> dDataTRB .or. TRB_REVINS <> cRevInsTRB .or. TRB_CSEQ <> cSeqTRB .or. TRB_ESCALA <> cEscallas
		If MV_PAR06 == 2 .or. !lTolPro
			If lMsa3Ed
				Aadd(aRegQM6,{TRB_DATA,TRB_ESCALA,TRB_PONTO,TRB_REFER,CriaVar("QM7_INCERT",.T.),CriaVar("QM7_INCERT",.T.),TRB_CSEQ,DtoS(TRB_DATA)})
			Else
				Aadd(aRegQM6,{TRB_DATA,TRB_ESCALA,TRB_PONTO,TRB_REFER,CriaVar("QM7_INCERT",.T.),TRB_CSEQ,DtoS(TRB_DATA)})
			Endif	

			cEscallas 	:= TRB_ESCALA
			lFecha		:= .F.
			dDataTRB	:= TRB_DATA
			cRevInsTRB	:= TRB_REVINS
			cSeqTRB		:= TRB_CSEQ
			nToler		:= 0
		Endif	
	Endif
	dbSelectArea("TRB")
	dbSkip()
Enddo	

If Len(aRegQM6) > 0
	
	If lMsa3Ed
    	cTits := OemToAnsi(STR0034)//"Digite a(s) Tolerancia(s)/Erro(s) Amostral(is)"
	Else
    	cTits := OemToAnsi(STR0027)
	Endif

	DEFINE MSDIALOG oDlgTol FROM  111,90 TO 304,600 TITLE cTits COLOR CLR_HRED PIXEL //"Digite a(s) Tolerancia(s)"
	If lMsa3Ed
		@ 1,1 LISTBOX oQual VAR cVar Fields HEADER STR0028,STR0029,STR0030,STR0031,STR0032,STR0035 SIZE 250,64 OF oDlgTol //"Data","Escala","Ponto","Espec.","Tolerancia"
	Else
		@ 1,1 LISTBOX oQual VAR cVar Fields HEADER STR0028,STR0029,STR0030,STR0031,STR0032 SIZE 250,64 OF oDlgTol //"Data","Escala","Ponto","Espec.","Tolerancia"
	Endif
	@ 3,11 SAY oSay1 PROMPT STR0025+aRegQM6[oQual:nAT,2]	OF oDlgTol COLOR CLR_BLUE PIXEL SIZE 80,10 //Escala
	@ 3,108 SAY oSay2 PROMPT STR0026+aRegQM6[oQual:nAT,3]	OF oDlgTol COLOR CLR_BLUE PIXEL SIZE 80,10 //Ponto

	oQual:SetArray(aRegQM6)
	If lMsa3Ed
		oQual:bLine := { || {aRegQM6[oQual:nAT,1],aRegQM6[oQual:nAT,2],aRegQM6[oQual:nAT,3],aRegQM6[oQual:nAT,4],aRegQM6[oQual:nAT,5],aRegQM6[oQual:nAT,6]}}
	Else
		oQual:bLine := { || {aRegQM6[oQual:nAT,1],aRegQM6[oQual:nAT,2],aRegQM6[oQual:nAT,3],aRegQM6[oQual:nAT,4],aRegQM6[oQual:nAT,5]}}
	Endif	
	oQual:bDrawSelect:= {||Qmc010Lin(oQual,oDlgTol,aRegQM6)}
	oQual:bLDblClick := {|| Qmc010DCLkTol(@aRegQM6,oQual)}
	DEFINE SBUTTON FROM 83,120	TYPE 1 ENABLE OF oDlgTol ACTION (lFecha := .T.,nOpc := 1,nRegQM6 := oQual:nAT ,oDlgTol:End()) 
	DEFINE SBUTTON FROM 83,155	TYPE 2 ACTION (lFecha := .T.,nOpc := 0,oDlgTol:End()) ENABLE OF oDlgTol
	ACTIVATE MSDIALOG oDlgTol CENTERED VALID lFecha
Endif

If nOpc == 1
	aQmuGraf := {}
	//Caso os dois parametros sejam vazios
	If Empty(MV_PAR04) .and. Empty(MV_PAR05)
		MV_PAR04 := "0"
		MV_PAR05 := "9999999999"
	Else
		If Empty(MV_PAR04)
			MV_PAR04 := Alltrim(StrTran(Str(SuperVal(MV_PAR04),Len(MV_PAR04),1),".",","))
		ElseIf Empty(MV_PAR05)
			MV_PAR05 := Alltrim(StrTran(Str(SuperVal(MV_PAR05),Len(MV_PAR05),1),".",","))
		Endif
	Endif

	nPosA := 0
	Do Case
		Case MV_PAR01 == 1
	    lContinua := .T.
		nNrMe   := 0
		nSomMed := 0
		nTend   := 0
		nVlD2	:= 0
		nUltD2  := 0 
		nSigR   := 0 
		nSigB   := 0
		nTInv   := 0
		nTenLSE := 0
		nTenLIE := 0
		nVRfer  := 0
		nErmos  := 0
		If lMsa3Ed
			nErmos := Int(mv_par09)
			If nErmos == 0
			     MsgInfo(STR0042) 
			     lContinua := .F.
			EndIf
		Endif
		
		aMs3	:= {}	
		aTendencia:= {}               

		dbGoTop()
		
		While !Eof() .AND. lContinua
		
	    	TRB_FILIAL	:= TRB->QM7_FILIAL
    		TRB_INSTR	:= TRB->QM7_INSTR
    		TRB_REVINS	:= TRB->QM7_REVINS
	    	TRB_DATA	:= TRB->QM7_DATA    	
	    	TRB_REFER	:= TRB->QM7_ESPEC
			TRB_ESCALA	:= TRB->QM7_ESCALA	    	   
			TRB_REVESC	:= TRB->QM7_REVESC	    	   			
			TRB_PONTO	:= TRB->QM7_PONTO
			TRB_REVPAD	:= TRB->QM7_REVPAD
			TRB_CSEQ	:= TRB->QM7_CSEQ
	
			//Busca a tolerancia do processo
			dbSelectArea("QMR")
			QMR->( DbSetOrder(1) )
			DbSeek(xFilial('QMR')+cInstrumento+TRB_ESCALA)
			If Empty(QMR->QMR_TOLPRO)
				lTolPro := .F.		
			Else
				TRB_TOLPRO := QMR->QMR_TOLPRO
			EndIf
		
			//Busca o tipo da escala
			dbSelectArea("QM9")
			QM9->( DbSetOrder(1) )
			QM9->(DbSeek(xFilial('QM9')+TRB_ESCALA+Inverte(TRB_REVESC)))
			If lMsa3Ed    
				nTpMsa := 2
			Else	
				nTpMsa := 1                            
			Endif
			If (SuperVal(TRB_REFER)  >= SuperVal(MV_PAR04)) .And. (SuperVal(TRB_REFER)  <= SuperVal(MV_PAR05))
				If !INCLUI .AND. !ALTERA // Visualizacao
					dbSelectArea("QM8")
					dbSetOrder(1)
					If dbSeek(xFilial("QM8")+TRB_INSTR+TRB_REVINS+DtoS(TRB_DATA)+TRB_CSEQ+TRB_ESCALA+TRB_REVESC+TRB_PONTO+TRB_REVPAD)
						While QM8->(!Eof()) .and. QM8->QM8_FILIAL+QM8->QM8_INSTR+QM8->QM8_REVINS+DtoS(QM8->QM8_DATA)+;
						QM8->QM8_CSEQ+QM8->QM8_ESCALA+QM8->QM8_REVESC+QM8->QM8_PADRAO+QM8->QM8_REVPAD ==;
						xFilial("QM8")+TRB_INSTR+TRB_REVINS+DtoS(TRB_DATA)+TRB_CSEQ+TRB_ESCALA+TRB_REVESC+;
						TRB_PONTO+TRB_REVPAD                                                   
							If lQMC010CO
								lConEst := ExecBlock("QMC010CO",.F.,.F.,{MV_PAR01})
							Endif
			
							If lMsa4Ed
								cString := "QACHART.DLL - TENDENCIA 4ºEDICAO"
							Else
								cString := "QACHART.DLL - TENDENCIA"
							EndIf
						           
							If lConEst			
								If lMsa3Ed
									nPoTol := Ascan(aRegQM6, { |x| x[8]+Alltrim(x[2])+Alltrim(x[3])+Alltrim(x[7]) ==;
										DtoS(TRB_DATA)+Alltrim(TRB_ESCALA)+Alltrim(TRB_PONTO)+Alltrim(TRB_CSEQ)})
								Else
									nPoTol := Ascan(aRegQM6, { |x| x[7]+Alltrim(x[2])+Alltrim(x[3])+Alltrim(x[6]) ==;
										DtoS(TRB_DATA)+Alltrim(TRB_ESCALA)+Alltrim(TRB_PONTO)+Alltrim(TRB_CSEQ)})
								Endif									
								If nPoTol > 0
									If Empty(aRegQM6[nPoTol][5])
										TRB_TOLPRO := "0"										
									Else
										TRB_TOLPRO := aRegQM6[nPoTol][5]
									Endif
								Endif
								If (QM9->QM9_TIPAFE $ "3|9")
									TRB_CICLOS := QM8->QM8_VLRFID
								Else								
									TRB_CICLOS := QM8->QM8_VLRFIM
								EndIf								
								nGraph := aScan(aTendencia,{|x| x == "[REFERENCIA]"})
								If ( nGraph == 0 )
									aadd(aTendencia, cString )
									aadd(aTendencia, "[TITLE]" )
									aadd(aTendencia," Instr.: "+cInstrumento)

									AADD(aMed64, "Instr.: "+cInstrumento ) //Titulo

									Aadd(aTendencia,"[LANGUAGE]")
									Aadd(aTendencia,Upper(__Language) )

									aadd(aTendencia, "[REFERENCIA]" )
									aadd(aTendencia, TRB_REFER )
									nDec := Qa_NumDec(TRB_REFER)
									aadd(aTendencia, "[DECIMAIS]" )
									aadd(aTendencia, Str(nDec,1) )
									aadd(aTendencia, "[LSL]" )
									if cPaisLoc == "BRA"
										aadd(aTendencia, StrTran(Str(SuperVal(TRB_REFER) - SuperVal(TRB_TOLPRO),10,nDec),".",","))
									Else
										aadd(aTendencia, StrTran(Str(SuperVal(TRB_REFER) - SuperVal(TRB_TOLPRO),10,nDec),",","."))
									EndIf
									aadd(aTendencia, "[USL]" )
									if cPaisLoc == "BRA"
										aadd(aTendencia, StrTran(Str(SuperVal(TRB_REFER) + SuperVal(TRB_TOLPRO),10,nDec),".",","))
									else
										aadd(aTendencia, StrTran(Str(SuperVal(TRB_REFER) + SuperVal(TRB_TOLPRO),10,nDec),",","."))
									EndIf
									aadd(aTendencia, "[INICIO DE DADOS]" )
									aadd(aTendencia, AllTrim(iif(cPaisLoc == "BRA",StrTran(TRB_CICLOS,".",","),StrTran(TRB_CICLOS,",",".")))) 
								Else
									aadd(aTendencia, AllTrim(iif(cPaisLoc == "BRA",StrTran(TRB_CICLOS,".",","),StrTran(TRB_CICLOS,",",".")))) 
								EndIf 
								nVRfer := SuperVal(TRB_REFER) 
								nNrMe++
								nSomMed := nSomMed + SuperVal(TRB_CICLOS)								
								aadd(aMs3,SuperVal(TRB_CICLOS))
								aadd(aMed64, SuperVal(TRB_CICLOS))
							Endif
							dbSelectArea("QM8")
							dbSetOrder(1)
							dbSkip()
						EndDo
					Endif					
				Else // Alteracao e Inclusao
					If lQMC010CO
						lConEst := ExecBlock("QMC010CO",.F.,.F.,{MV_PAR01})
					Endif
			            
					If lConEst			
					
						nPosA := Ascan(aMedicoes, { |x| Alltrim(x[1]) == Alltrim(TRB_ESCALA) .and. Alltrim(x[2]) == Alltrim(TRB_PONTO)})
			
						If nPosA > 0
							If lMsa3Ed
								nPoTol := Ascan(aRegQM6, { |x| x[8]+Alltrim(x[2])+Alltrim(x[3])+Alltrim(x[7]) ==;
									DtoS(TRB_DATA)+Alltrim(TRB_ESCALA)+Alltrim(TRB_PONTO)+Alltrim(TRB_CSEQ)}) 
							Else
								nPoTol := Ascan(aRegQM6, { |x| x[7]+Alltrim(x[2])+Alltrim(x[3])+Alltrim(x[6]) ==;
									DtoS(TRB_DATA)+Alltrim(TRB_ESCALA)+Alltrim(TRB_PONTO)+Alltrim(TRB_CSEQ)})
							Endif	
							If nPoTol > 0
								If Empty(aRegQM6[nPoTol][5])
									TRB_TOLPRO := "0"										
								Else
									TRB_TOLPRO := aRegQM6[nPoTol][5]
								Endif
								TRB_ERMAS := aRegQM6[nPoTol][6]
							Endif
							
							TRB_REFER := aMedicoes[nPosA][3]							
			
							For nd := 1 To Len(aMedicoes[nPosA][4]) 
								For ni := 1 To Len(aMedicoes[nPosA][4][nd])									
									If ValType(aMedicoes[nPosA][4][nd][ni]) == "C"       
			
										TRB_CICLOS := aMedicoes[nPosA][4][nd][ni]
										nGr := Ascan(aQmuGraf,{ |x| Alltrim(x[7]) == Alltrim(TRB_ESCALA) .and. Alltrim(x[1]) == Alltrim(TRB_PONTO)})
										If nGr == 0
											Aadd(aQmuGraf,{TRB_PONTO,SuperVal(TRB_CICLOS),TRB_DATA,SuperVal(TRB_CICLOS),SuperVal(TRB_CICLOS),1,TRB_ESCALA})
										Else
											aQmuGraf[nGr][2] += SuperVal(TRB_CICLOS)
											//Maximo
											If SuperVal(TRB_CICLOS) > SuperVal(aQmuGraf[nGr][4])
												aQmuGraf[nGr][4] := SuperVal(TRB_CICLOS)
											Endif
											
											//Minimo
											If SuperVal(TRB_CICLOS) < SuperVal(aQmuGraf[nGr][5])
												aQmuGraf[nGr][5] := SuperVal(TRB_CICLOS)
											Endif
		
											aQmuGraf[nGr][6]++
                                        Endif
										

										nGraph := aScan(aTendencia,{|x| x == "[REFERENCIA]"})
			
										If ( nGraph == 0 )
											aadd(aTendencia, cString )
											aadd(aTendencia, "[TITLE]" )
											aadd(aTendencia," Instr.: "+cInstrumento)

											Aadd(aTendencia,"[LANGUAGE]")
											Aadd(aTendencia,Upper(__Language) )

											aadd(aTendencia, "[REFERENCIA]" )
											aadd(aTendencia, TRB_REFER )
											nDec := Qa_NumDec(TRB_REFER)
											aadd(aTendencia, "[DECIMAIS]" )
											aadd(aTendencia, Str(nDec,1) )
											aadd(aTendencia, "[LSL]" )
											if cPaisLoc == "BRA"
												aadd(aTendencia, StrTran(Str(SuperVal(TRB_REFER) - SuperVal(TRB_TOLPRO),10,nDec),".",","))
											Else
												aadd(aTendencia, StrTran(Str(SuperVal(TRB_REFER) - SuperVal(TRB_TOLPRO),10,nDec),",","."))
				            				EndIf
											aadd(aTendencia, "[USL]" )
											if cPaisLoc == "BRA"
												aadd(aTendencia, StrTran(Str(SuperVal(TRB_REFER) + SuperVal(TRB_TOLPRO),10,nDec),".",","))
											Else
												aadd(aTendencia, StrTran(Str(SuperVal(TRB_REFER) + SuperVal(TRB_TOLPRO),10,nDec),",","."))
											EndIf
											aadd(aTendencia, "[INICIO DE DADOS]" )
											aadd(aTendencia, AllTrim(iif(cPaisLoc == "BRA",StrTran(TRB_CICLOS,".",","),StrTran(TRB_CICLOS,",",".")))) 
										Else
											aadd(aTendencia, AllTrim(iif(cPaisLoc == "BRA",StrTran(TRB_CICLOS,".",","),StrTran(TRB_CICLOS,",",".")))) 
										EndIf
										nVRfer := SuperVal(TRB_REFER) 
										nNrMe++
										nSomMed := nSomMed + SuperVal(TRB_CICLOS)								
										aadd(aMs3,SuperVal(TRB_CICLOS))
										aadd(aMed64, Str(aMS3[LEN(aMS3)]))
									Endif
								Next ni
							Next nd
						EndIf
					Endif
				Endif
			Endif
		dbSelectArea("TRB")
		dbSkip()
	EndDo				
	If lMsa3Ed
		If nNrMe > 0

			// Verifica se o pergunte esta ativo para poder imprimir o grafico de media / amplitude
			If mv_par10 == 1 
				nSomasMed := 0
				nSaAmpli  := 0
				For nx := 1 To Len(aQmuGraf)
					aQmuGraf[nx][2] := aQmuGraf[nx][2]/Len(aQmuGraf)				
					aQmuGraf[nx][4] := Abs(SuperVal(aQmuGraf[nx][4]) - SuperVal(aQmuGraf[nx][5]))
					nSomasMed += SuperVal(aQmuGraf[nx][2])
					nSaAmpli  += SuperVal(aQmuGraf[nx][4])
				Next nx
				
				nNominal := nSomasMed/Len(aQmuGraf)	      
				nFtMul := 0
				nMltAmp := 0		
				aXbr := {}
				If Len(aQMUGraf) > 0
					If aQMUGraf[1,6] == 2
						nFtMul := 1.88 
						nMltAmp := 3.27
					ElseIf aQMUGraf[1,6] == 3
						nFtMul := 1.02 
						nMltAmp := 2.57
					ElseIf aQMUGraf[1,6] == 4	 
						nFtMul := 0.73
						nMltAmp := 2.28
					Else
						nFtMul := 0.58
						nMltAmp := 2.211
					Endif			
				Endif            
	
				nSLEv := nNominal + (nFtMul*(nSaAmpli/Len(aQMUGraf)))
				nLIEv := nNominal - (nFtMul*(nSaAmpli/Len(aQMUGraf)))
	            
	
				//Calculo da media da amplitude para o grafico - Tendencia XBR
				nMAmplt := nSaAmpli/Len(aQMUGraf)
	
				nLCSAmp := nMAmplt*nMltAmp
				nDec    := 2	
				//Grafico de xBr
				aAdd(aXbr,"QACHART.DLL - NORMAL")
				
				aAdd(aXbr,"[USL]")
				If cPaisLoc == "BRA"
					Aadd(aXbr,StrTran(Str(nSLEv,8,nDec),".",","))
				else
					Aadd(aXbr,StrTran(Str(nSLEv,8,nDec),",","."))
				EndIf

				aAdd(aXbr,"[LSL]") 
				if cPaisLoc == "BRA"
					Aadd(aXbr,StrTran(Str(nLIEv,8,nDec),".",","))			
				Else			
					Aadd(aXbr,StrTran(Str(nLIEv,8,nDec),",","."))							
				EndIF
				aAdd(aXbr,"[TARGET]")                         
				if cPaisLoc == "BRA"
					Aadd(aXbr,StrTran(Str(nNominal,8,nDec),".",","))						
				Else
					Aadd(aXbr,StrTran(Str(nNominal,8,nDec),",","."))						
				Endif													
				aAdd(aXbr,"[TITLE]")
				aAdd(aXbr,	AllTrim(QM2->QM2_INSTR)+" "+QM2->QM2_REVINS)

				Aadd(aXbr,"[LANGUAGE]")
				Aadd(aXbr,Upper(__Language) )
				
				aAdd(aXbr,"[FOOT]")
				aAdd(aXbr,	AllTrim(QM2->QM2_INSTR)+" "+QM2->QM2_REVINS+" "+;
								AllTrim("Carta XBR - Estudo de Tendencia")) 
								
				aAdd(aXbr,"[INICIO DE DADOS]")
				
				cMedi := 	StrZero(Day(dDataBase),2)+"/"+;
							StrZero(Month(dDataBase),2)+"/"+Str(Year(dDataBase),4)+;
							"00:00"
				nItem := 0
				
				For nx := 1 To Len(aMs3)
					nItem++
					aAdd(aXbr,cMedi+AllTrim(Str(aMS3[nx])))
				Next nx
					
				aAdd(aXbr,"[FIM DE DADOS]")
				
				aAdd(aXbr,"[SUBGRUPO]")
				Aadd(aXbr,Str(mv_par09)) //Criar campo para subgrupo.
            Endif

			//Calculo da Media...
			nMeMed := nSomMed/nNrMe					
			//Calculo da Tendencia...
			nTend  := nMeMed-SuperVal(nVRfer)					
			aSort(aMs3,,,{|x,y| x < y })					
			//Calculo da Amplitude...
			nAmpli := aMs3[Len(aMs3)] - aMs3[1]
			//Calculo SigmaR
			//Carrega o array...
			QTC010D2()	
			//Retorna o D2 posicionado...
			If nNrMe > 20
			   nNrMe := 20
			Endif
			nVlD2:= aTbv[nNrMe,1]
	   
			//Calcula variaveis do calculo da tendencia...
			cTbrAm := Alltrim(StrTran(Str((nErmos/100)/2),".",","))
			
			//Retorna o ultimo D2...
			nUltD2 := aTab[nNrMe,21]
			nSigR  := nAmpli/nVlD2
			nSigaB := aTbv[nNrMe,21]
			
			//Calculo Repetibilidade %EV usado MSA 4 Edição
			If lMsa4Ed
				If !Empty(cVarTot)		
					nPve := 100*(nSigR/SuperVal(cVarTot))
				Else
					nPve := 100*(nSigR/(ABS((SuperVal(aTendencia[11]) - SuperVal(aTendencia[13])))/6))  //Quando não for informado o campo QMU_VARTOT será realizado o calculo utilizando o 6 Sigma e a faixa de tolerancia. 
				EndIf
			EndIf
			
			//Calculo de SigmaB
			nSigB  := nSigR/(nNrMe^0.5)
			
			//Calculo da invertida...
			If Int(SuperVal(nErmos)) <= 0
				lMsg := .T.					
			Else
				lMsg := .F.	  
				If lInterpol
					lBiCaudal := !(abs(SuperVal(aTab[nNrMe,1])) - abs(round(SuperVal(aTab[nNrMe,1]),0))==0)   
				Else
					lBiCaudal := .F.
				EndIf
				If lBiCaudal                                                                    
					//Calculo do Valor Significativo t (bi-caudal) a partir dos graus de liberdade nErmos
					nTInv  := QM010IntL(SuperVal(aTab[nNrMe,1]),nErmos,Qa_NumDec(cTbrAm))
				Else
					If !lExistChart
						nTInv  := CallDll32("STUDENTINV",cTbrAm+";"+Alltrim(Str(Int(aTab[nNrMe,1]))))
					Else
						nTInv  := QLDSTDINV(SUPERVAL(nErmos), Int(aTab[nNrMe,1]))
					EndIf
				EndIf
			Endif

			nTInv  := SuperVal(nTInv)			   
		   	//nTenLSE:= nTend+((nSigB*(nSigaB/nVlD2))*nTInv)
			//nTenLIE:= nTend-((nSigB*(nSigaB/nVlD2))*nTInv)
			If lBiCaudal
				nTenLSE:= nTend + ( nSigB * nTInv)
				nTenLIE:= nTend - ( nSigB * nTInv)
			Else			   
			   	nTenLSE:= nTend + ((nSigB*(nSigaB/nVlD2))*nTInv)
				nTenLIE:= nTend - ((nSigB*(nSigaB/nVlD2))*nTInv)
			EndIf
			If nTenLSE < 0 
				cReTen := OemToAnsi(STR0033) //"O sistema de medicao nao e adequado quanto a tendencia"													
			ElseIf nTenLIE > 0 
				cReTen := OemToAnsi(STR0033) //"O sistema de medicao nao e adequado quanto a tendencia"								
			Else
				cReTen := OemToAnsi(STR0034) //"O sistema de medicao e adequado quanto a tendencia"				
			Endif
			aadd(aTendencia, "[FIM DE DADOS]" )	
			aadd(aTendencia, "[MEDIA]" )
			aadd(aTendencia, Alltrim(Str(nMeMed)))

            If lInterpol 
				aadd(aTendencia, "[POLAR]" )
			Endif

			If lMsa3Ed
				aadd(aTendencia, "[TEND]" )
			Else
				aadd(aTendencia, "[TENDENCIA]" )
			Endif

			aadd(aTendencia, Alltrim(Str(nTend)))
			aadd(aTendencia, "[AMPLT]" )
			aadd(aTendencia, Alltrim(Str(nAmpli)))
			aadd(aTendencia, "[SIGR]" )
			aadd(aTendencia, Alltrim(Str(nSigR)))
			aadd(aTendencia, "[SIGB]" )
			aadd(aTendencia, Alltrim(Str(nSigB)))
			aadd(aTendencia, "[TLIE]" )
			aadd(aTendencia, Alltrim(Str(nTenLIE)))
			aadd(aTendencia, "[TLSE]" )
			aadd(aTendencia, Alltrim(Str(nTenLSE)))
			aadd(aTendencia, "[MSGE]" )
			aadd(aTendencia, Alltrim(cReTen))
			If lMsa4Ed
				aadd(aTendencia, "[PVE]" )
				aadd(aTendencia, Alltrim(Str(nPve)))
			EndIf
		Endif
	Else
		aadd(aTendencia, "[FIM DE DADOS]" )		
	Endif									
	
	Case MV_PAR01 == 2
	nNrPec  := 0
	nVRfer  := 0 
	nSomX	:= 0
	nNreMed := 0
	nMedia	:= 0
	nNroTot := 0
	nNroPec := 0
	nMedias := 0
	nErmos  := 0
	If lMsa3Ed
		nErmos := mv_par09
		If nErmos == 0
		     MsgInfo(STR0042) 
		     lContinua := .F.
		EndIf
	Endif
	
	dbGoTop()
	While !Eof() .AND. lContinua
	
    	TRB_FILIAL	:= TRB->QM7_FILIAL
    	TRB_INSTR	:= TRB->QM7_INSTR
    	TRB_REVINS	:= TRB->QM7_REVINS
    	TRB_DATA	:= TRB->QM7_DATA    	
    	TRB_REFER	:= TRB->QM7_ESPEC
		TRB_ESCALA	:= TRB->QM7_ESCALA	    	   
		TRB_REVESC	:= TRB->QM7_REVESC	    	   			
		TRB_PONTO	:= TRB->QM7_PONTO
		TRB_REVPAD	:= TRB->QM7_REVPAD
		TRB_CSEQ	:= TRB->QM7_CSEQ
	
		//Busca a tolerancia do processo
		dbSelectArea("QMR")
		QMR->( DbSetOrder(1) )
		DbSeek(xFilial('QMR')+cInstrumento+TRB_ESCALA)
		If Empty(QMR->QMR_TOLPRO)
			lTolPro := .F.		
		Else
			TRB_TOLPRO := QMR->QMR_TOLPRO
		EndIf
	
		//Busca o tipo da escala
		dbSelectArea("QM9")
		QM9->( DbSetOrder(1) )
		QM9->(DbSeek(xFilial('QM9')+TRB_ESCALA+Inverte(TRB_REVESC)))			
		If lPrmi 
			cRefer := TRB_REFER
		Endif
		lPrmi := .f.
		//aLinear := {}
		//aLinearFim := {}
		If lMsa4Ed
			cString := "QACHART.DLL - LINEARIDADE 4ºEDICAO"
		Elseif lMsa3Ed
			cString := "QACHART.DLL - LINEARIDADE 3ºEDICAO"
		Else
			cString := "QACHART.DLL - LINEARIDADE"
		EndIf
		If (SuperVal(TRB_REFER)  >= SuperVal(MV_PAR04) .AND. SuperVal(TRB_REFER) <= SuperVal(MV_PAR05));
			.AND. QM6->QM6_INSTR+QM6->QM6_REVINS+DtoS(QM6->QM6_DATA)+QM6->QM6_CSEQ == TRB_INSTR+TRB_REVINS+DtoS(TRB_DATA)+TRB_CSEQ
			If lQMC010CO
				lConEst := ExecBlock("QMC010CO",.F.,.F.,{MV_PAR01})
			Endif
            
			If lConEst			
				nPosA := Ascan(aMedicoes, { |x| Alltrim(x[1]) == Alltrim(TRB_ESCALA) .and. Alltrim(x[2]) == Alltrim(TRB_PONTO)})
				If nPosA > 0
                   	If lMsa3Ed
						nPoTol := Ascan(aRegQM6, { |x| x[8]+Alltrim(x[2])+Alltrim(x[3])+Alltrim(x[7]) ==;
							DtoS(TRB_DATA)+Alltrim(TRB_ESCALA)+Alltrim(TRB_PONTO)+Alltrim(TRB_CSEQ)})
					Else
						nPoTol := Ascan(aRegQM6, { |x| x[7]+Alltrim(x[2])+Alltrim(x[3])+Alltrim(x[6]) ==;
							DtoS(TRB_DATA)+Alltrim(TRB_ESCALA)+Alltrim(TRB_PONTO)+Alltrim(TRB_CSEQ)})
					Endif	
					If nPoTol > 0
						If Empty(aRegQM6[nPoTol][5])
							TRB_TOLPRO := "0"										
						Else
							TRB_TOLPRO := aRegQM6[nPoTol][5]
						Endif
					Endif
					
		
					TRB_REFER := aMedicoes[nPosA][3]  

					nNreMed := Len(aMedicoes[nPosA][4])
					
					For nd := 1 To Len(aMedicoes[nPosA][4]) 
						For ni := 1 To Len(aMedicoes[nPosA][4][nd])									
							If ValType(aMedicoes[nPosA][4][nd][ni]) == "C"       
								TRB_CICLOS := aMedicoes[nPosA][4][nd][ni]
								nGraph := aScan(aLinear,{|x| x[1] == TRB_REFER})
								If ( nGraph == 0 )
									nMedias := nMedias + SuperVal(TRB_REFER)
									nNroPec++
									nNroTot++
									If lMsa3Ed
										aadd(aLinear,{ TRB_REFER , 1 , SuperVal(TRB_CICLOS),;
													SuperVal(TRB_CICLOS),((-1*SuperVal(TRB_REFER))+SuperVal(TRB_CICLOS))})
									Else
										aadd(aLinear,{ TRB_REFER , 1 , SuperVal(TRB_CICLOS),;
													SuperVal(TRB_CICLOS)})
									Endif				
									nVarPro := SuperVal(TRB_TOLPRO)
									aAdd(aLimites,SuperVal(TRB_REFER)+ SuperVal(QMU->QMU_TOLER)) //Limite Superior
	 								aAdd(aLimites,SuperVal(TRB_REFER) - SuperVal(QMU->QMU_TOLER)) //Limite Inferior
								Else
									nNroTot++
									aLinear[nGraph,2] ++
									aLinear[nGraph,3] += SuperVal(TRB_CICLOS)
									aLinear[nGraph,4] := aLinear[nGraph,3]/aLinear[nGraph,2]
									If lMsa3Ed
										Aadd(aLinear[nGraph],((-1*SuperVal(TRB_REFER))+SuperVal(TRB_CICLOS)))
									Endif													
								EndIf
							Endif
						Next ni
					Next nd
				Endif					
			Endif
		EndIf

		dbSelectArea("TRB")
		dbSkip()
	EndDo				

	//Utilziado para instrumentos que possuem MSA 2 e 3 edição
	If !lMsa3Ed .and. mv_par07==1
		If !Empty(nErmos)
			lMsa3Ed := .T.
			lRecal  := .T.
		EndIf
	EndIf		
	    	
	If !lMsa3Ed 
		mv_par07 := 2																				
	Endif	
	
	aLinear := aSort(aLinear,,,{|x,y| SuperVal(x[1])<SuperVal(y[1])})

	For nCntFor := 1 To Len(aLinear)
		nX      := SuperVal(aLinear[nCntFor,1])
		nY      := aLinear[ncntFor,4]-SuperVal(aLinear[nCntFor,1])
		nSomaX  += nX
		nSomaY  += nY
		nSomaXY += nX*nY
		nSomaX2 += nX**2
		nSomaY2 += nY**2
	Next nCntForr    
	
	nLinearA := (nSomaXY-(nSomax*nSomaY/Len(aLinear)))/;
					((nSomaX2)-((nSomaX**2)/Len(aLinear)))
	nLinearA := Round(nLinearA,4)
	nLinearB := (nSomaY-(nLinearA*nSomaX))/Len(aLinear)
	nLinearB := Round(nLinearB,4)
	nLinearR2:= ((nSomaXY-(nSomaX*nSomaY/Len(aLinear)))**2)/;
					((nSomaX2-((nSomaX**2)/Len(aLinear)))*(nSomaY2-((nSomaY**2)/Len(aLinear))))
	nLinearR2:= Round(nLinearR2,4)
	nLinearVp:= Round(nVarPro,4)
	nLinear  := Round(Abs(nLinearA)*nLinearVp,4)
	nLinearP := Round(100*nLinear/nLinearVp,4)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria arquivo texto para geracao do grafico                    ³
	//³ ATENCAO: NAO ALTERAR A SEQUENCIA DAS VARIAVEIS DO BLOCO ABAIXO³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nSomaY/Len(aLinear)) < 0
		nTende := (nSomaY/Len(aLinear)) * -1 //Inverter sinal
	Else
		nTende := (nSomaY/Len(aLinear)) 
	Endif
	
	aadd(aLinearFim, cString )
	aadd(aLinearFim, "[TITLE]" )  
	aadd(aLinearFim,"Instr.: "+cInstrumento)

	AADD(aMed64, "Instr.: "+cInstrumento ) //Titulo

	Aadd(aLinearFim,"[LANGUAGE]")
	Aadd(aLinearFim,Upper(__Language) )

	If !lMsa3Ed
		aadd(aLinearFim, "[LINEAR%]" )
		aadd(aLinearFim, AllTrim( StrTran( Str( nLinearP ), ".","," ) ) )
		aadd(aLinearFim, "[GRAU]" )
		aadd(aLinearFim, AllTrim( StrTran( Str( nLinearR2 ),".","," ) ) )
		aadd(aLinearFim, "[LINEAR]" )
		aadd(aLinearFim, AllTrim( StrTran( Str( nLinear ), ".","," ) ) )
		aadd(aLinearFim, "[TENDENCIA]" )
		aadd(aLinearFim, AllTrim( StrTran( Str( nTende ),".",",") ) )
	Else
		aadd(aLinearFim, "[GRAU]" )
		aadd(aLinearFim, AllTrim( StrTran( Str( nLinearR2 ),".","," ) ) )					
		aadd(aLinearFim, "[TENDENCIA]" )
		If nLinearA < 0
			aadd(aLinearFim, AllTrim( StrTran( Str( nLinearB )+"-"+AllTrim(Str( nLinearA * -1 ))+"y",".",",") ) ) //Inverter sinal
		Else
			aadd(aLinearFim, AllTrim( StrTran( Str( nLinearB )+"+"+AllTrim(Str( nLinearA ))+"y",".",",") ) ) 
		Endif
	Endif

	aadd(aMed64, aLinearFim[07]) //%Linearidade
	aadd(aMed64, aLinearFim[09]) //Grau de Ajuste(R2)
	aadd(aMed64, aLinearFim[11]) //Linearidade
	aadd(aMed64, aLinearFim[13]) //Têndencia

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta pontos da reta                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aadd(aLinearFim, "[RETA]" )
	aRetaMed64 := {}
	For nCntFor := 1 to len(aLinear)
		 aadd(aLinearFim,aLinear[nCntFor,1]+";"+;
			  AllTrim(StrTran(Str(nLinearB + nLinearA * SuperVal(aLinear[nCntFor,1])),".",",")))
		aadd(aRetaMed64, aLinearFim[Len(aLinearFim)])
	Next nCntFor
	aadd(aMed64, aRetaMed64) //Regressão  
	aadd(aLinearFim, "[FIM RETA]" )     
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta pontos de tendencia                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aadd(aLinearFim, "[MEDIA]" )
	aMedTena64 := {}
	For nCntFor := 1 to len(aLinear)
		 aadd(aLinearFim,aLinear[nCntFor,1]+";"+;
				AllTrim(StrTran(Str(aLinear[nCntFor,4]-;
				SuperVal(aLinear[nCntFor,1])),".",",")))
		aadd(aMedTena64, aLinearFim[Len(aLinearFim)])
	Next nCntFor
	aadd(aLinearFim, "[FIM MEDIA]" )
	aadd(aMed64, aMedTena64) //Médias das Têndencias

    If lMsa3Ed 
		nVll	:= 0
		nSomExp	:= 0     
		nSomYs	:= 0
		nSomXs	:= 0
		nSomPtos := 0
		nSomXYs	:= 0
		nSomYAs	:= 0			 
		nSxQuads := 0
		nMedias  := nMedias / nNroPec 
		For nx := 1 To Len(aLinear)
			nSomXs	:= nSomXs + SuperVal(aLinear[nx][1])
			nSxQuads := nSxQuads + SuperVal(aLinear[nx][1])^2
			For ny := 5 To Len(aLinear[nx])
				nGAx := aScan(aLinAux,{|x| x[1] == aLinear[nx][1]}) 
				nSomExp := nSomExp + (aLinear[nx][ny]^2)
				If nGAx == 0
					Aadd(aLinAux,{aLinear[nx][1],(aLinear[nx][ny]^2)})
				Else
					Aadd(aLinAux[nGAx],(aLinear[nx][ny]^2))
				Endif
				nSomPtos := nSomPtos + (aLinear[nx][ny]^2)
				nSomYAs := nSomYAs + aLinear[nx][ny]
				nSomYs := nSomYs + aLinear[nx][ny]
			Next ny
			Aadd(aLinear[nx],nSomYAs*SuperVal(aLinear[nx][1]))
			nSomYAs := 0
		Next nx
		nSomXs	:= nSomXs * nNreMed	
		nSxQuads := nSxQuads * nNreMed	
		aFinal := aClone(aLinear)
		//aLinear := {}
		//Estrutura do aLinear..
		//1		Ponto
		//2		Soma Y...
		//3		Soma X...	
		//4		Soma XY
		//5		Soma X quadrado
		//6		Valor A
		//7		Valor B
		//8		Calculo do S
		//9		Somatoria X - X Media
		//10	Calculo do Ta Modulo
		//11	Calculo do Ta Critico
		//12	Calculo do Tb Modulo
		//13	Calculo do Tb Critico	
		nSSQd := 0
    	For nx := 1 To Len(aFinal)
			nSomXYs	:= nSomXYs + aFinal[nx,Len(aFinal[nx])]				             
			nSSQd	:= nSSQd + ((SuperVal(aFinal[nx][1]) - nMedias)^2)
        Next nx

		nCalcA := ((nSomXYs-(nSomYs*nSomXs/nNroPec/nNreMed))/(nSxQuads-(nSomXs^2)/nNroPec/nNreMed))
		
		nCalcB := (nSomYs/nNroPec/nNreMed)-nCalcA*nMedias 
		
		nCalcS := ((nSomExp-nCalcB*nSomYs-nCalcA*nSomXYs)/(nNroPec*nNreMed-2))^0.5
		
		//Calculo Repetibilidade %VE usado MSA 4 Edição
		If lMsa4Ed
			If !Empty(cVarTot)		
				nPve := 100*(nCalcS/SuperVal(cVarTot))
			Else
				nPve := nPve := 100*(nCalcS/(ABS(aLimites[1] - aLimites[2])/6))   //Quando não for informado o campo QMU_VARTOT será realizado o calculo utilizando o 6 Sigma e a faixa de tolerancia. 
			EndIf
		EndIf
		
		//Calculo da Somatoria X - X Media
		nCaxMed := nNreMed * nSSQd
		
		//Calculo de Hipotese A
		nTa := Abs(nCalcA)/(nCalcS/(nCaxMed^0.5))    
		aadd(aLinearFim, "[NTA]" )	
		aadd(aLinearFim, Alltrim(Str(nTa)))	
		//Calculo de Hipotese B
		nTb := Abs(nCalcB)/(nCalcS*(((1/nNroPec/nNreMed)+(nMedias^2/nCaxMed))^0.5))
		aadd(aLinearFim, "[NTB]" )	
		aadd(aLinearFim, Alltrim(Str(nTb)))	
							
		nErmos := ((nErmos/100)/2)
		
		nErmos := StrTran(Alltrim(Str(nErmos)),".",",")
		
		IF !lExistChart
			nTCritA := CallDll32("STUDENTINV",nErmos+";"+Alltrim(Str(nNroTot-2)))
		ELSE
			nTCritA := QLDSTDINV(SUPERVAL(nErmos), nNroTot-2)
		ENDIF 
		
		aadd(aLinearFim, "[TCRITA]" )	
		aadd(aLinearFim, Alltrim(nTCritA))	
		
		aadd(aLinearFim, "[TCRITB]" )	
		aadd(aLinearFim, Alltrim(nTCritA))

		aadd(aLinearFim, "[PONTOS]" )
		aPtsaMed64 := {}
		For nCntFor := 1 to len(aLinear)
			For nX:=5 to Len(aLinear[nCntFor])-1 
				AADD(aLinearFim,aLinear[nCntFor,1]+";"+AllTrim(StrTran(Str(SuperVal(aLinear[nCntFor,nX])),".",",")))
				aadd(aPtsaMed64, aLinearFim[Len(aLinearFim)])
			Next nX  
		Next nCntFor          
		aadd(aLinearFim, "[FIM PONTOS]" ) 
		aadd(aMed64, aPtsaMed64) //Resultados Intermediários    
		aLinear := {}
		//Analises
		If nTa > SuperVal(nTCritA)
			cAnaLin1 := OemToAnsi(STR0035) //"A tendencia nao e igual ao longo da faixa de medicao"
		Else
			cAnaLin1 := OemToAnsi(STR0036) //"A tendencia e igual ao longo da faixa de medicao"
		Endif          
			
		If SuperVal(nTb) > SuperVal(nTCritA)
			cAnaLin2 := OemToAnsi(STR0037) //"A tendencia nao e igual a zero"
		Else
			cAnaLin2 := OemToAnsi(STR0038) //"A tendencia e igual a zero"
		Endif          

		aadd(aLinearFim, "[MSGA]" )	
		aadd(aLinearFim, Alltrim(cAnaLin1))	

		aadd(aLinearFim, "[MSGB]" )	
		aadd(aLinearFim, Alltrim(cAnaLin2))	

		For nx := 1 To Len(aLinAux)
			//Deslocamento
			IF !lExistChart
				nInv := SuperVal(CallDll32("STUDENTINV",nErmos+";"+Alltrim(Str(Int(nNroPec*nNreMed-2)))))
			ELSE
				nInv := QLDSTDINV(SUPERVAL(nErmos), Int(nNroPec*nNreMed-2))
			ENDIF

			nDeslo := nCalcS*SuperVal(nInv)*((((1/nNroPec/nNreMed)+((SuperVal(aLinAux[nx][1])-nMedias)^2)/nCaxMed))^0.5)
			//Reta
			nBx0 := nCalcB+nCalcA*SuperVal(aLinAux[nx][1])
			//Deslocamento + Reta
			nDMaBx0 := nBx0+nDeslo
			//Deslocamento - Reta
			nDMiBx0 := nBx0-nDeslo				
			AADD(aRetasL,{nDMaBx0,nDMiBx0})
		Next nx
	
		//Linhas de Confiança
		aadd(aLinearFim, "[RETA SUPERIOR]" )
		aRetSupa64 := {}
		For nX:=1 to Len(aRetasL)
			 aadd(aLinearFim,aLinAux[nx][1]+";"+;
    			 AllTrim(StrTran(Str(aRetasL[nX,1]),".",",")))
			aadd(aRetSupa64, aLinearFim[Len(aLinearFim)])
		Next nX
		aadd(aLinearFim, "[FIM RETA SUPERIOR]" )
		aadd(aMed64, aRetSupa64) //Intervalo de Confiança Superior     
		
		aadd(aLinearFim, "[RETA INFERIOR]" )
		aRetInfa64 := {}
		For nX := 1 to len(aRetasL)
			aadd(aLinearFim,aLinAux[nX][1]+";"+;
    			 AllTrim(StrTran(Str(aRetasL[nX,2]),".",",")))
			aadd(aRetInfa64, aLinearFim[Len(aLinearFim)])
		Next nX
		aadd(aLinearFim, "[FIM RETA INFERIOR]" ) 
		aadd(aMed64, aRetInfa64) //Intervalo de Confiança Superior 

		If lMsa4Ed
			aadd(aLinearFim, "[PVE]" )
			aadd(aLinearFim, Alltrim(Str(nPve)))
		EndIf
	Endif
	Case MV_PAR01 == 3
			If lMsa3Ed
				nErmos := mv_par09
				If nErmos == 0
				     MsgInfo(STR0042) 
				     lContinua := .F.
				EndIf
			Endif
			dbGoTop()
			While !Eof() .AND. lContinua 
		    	TRB_FILIAL	:= TRB->QM7_FILIAL
	    		TRB_INSTR	:= TRB->QM7_INSTR
	    		TRB_REVINS	:= TRB->QM7_REVINS
		    	TRB_DATA	:= TRB->QM7_DATA    	
		    	TRB_REFER	:= TRB->QM7_ESPEC
				TRB_ESCALA	:= TRB->QM7_ESCALA	    	   
				TRB_REVESC	:= TRB->QM7_REVESC	    	   			
				TRB_PONTO	:= TRB->QM7_PONTO
				TRB_REVPAD	:= TRB->QM7_REVPAD
				TRB_CSEQ	:= TRB->QM7_CSEQ
			
				//Busca a tolerancia do processo
				dbSelectArea("QMR")
				QMR->( DbSetOrder(1) )
				DbSeek(xFilial('QMR')+cInstrumento+TRB_ESCALA)
				If Empty(QMR->QMR_TOLPRO)
					lTolPro := .F.		
				Else
					TRB_TOLPRO := QMR->QMR_TOLPRO
				EndIf
			
				//Busca o tipo da escala
				dbSelectArea("QM9")
				QM9->( DbSetOrder(1) )
				QM9->(DbSeek(xFilial('QM9')+TRB_ESCALA+Inverte(TRB_REVESC)))			
				
				cString := "QACHART.DLL - ESTABILIDADE"
				If  (SuperVal(TRB_REFER)  >= SuperVal(MV_PAR04) .And. SuperVal(TRB_REFER)  <= SuperVal(MV_PAR05))
						If QM6->QM6_INSTR+QM6->QM6_REVINS+DtoS(QM6->QM6_DATA)+QM6->QM6_CSEQ ==;
							TRB_INSTR+TRB_REVINS+DtoS(TRB_DATA)+TRB_CSEQ
							nPosA := Ascan(aMedicoes, { |x| Alltrim(x[1]) == Alltrim(TRB_ESCALA) .and. Alltrim(x[2]) == Alltrim(TRB_PONTO)})
							If nPosA > 0
                                If lMsa3Ed
									nPoTol := Ascan(aRegQM6, { |x| x[8]+Alltrim(x[2])+Alltrim(x[3])+Alltrim(x[7]) ==;
										DtoS(TRB_DATA)+Alltrim(TRB_ESCALA)+Alltrim(TRB_PONTO)+Alltrim(TRB_CSEQ)})
								Else
									nPoTol := Ascan(aRegQM6, { |x| x[7]+Alltrim(x[2])+Alltrim(x[3])+Alltrim(x[6]) ==;
										DtoS(TRB_DATA)+Alltrim(TRB_ESCALA)+Alltrim(TRB_PONTO)+Alltrim(TRB_CSEQ)})
								Endif	

								If nPoTol > 0
									If Empty(aRegQM6[nPoTol][5])
										TRB_TOLPRO := "0"										
									Else
										TRB_TOLPRO := aRegQM6[nPoTol][5]
									Endif
								Endif

								TRB_REFER := aMedicoes[nPosA][3]							
								For nd := 1 To Len(aMedicoes[nPosA][4]) 
									For ni := 1 To Len(aMedicoes[nPosA][4][nd])									
										If ValType(aMedicoes[nPosA][4][nd][ni]) == "C"       

											TRB_CICLOS := aMedicoes[nPosA][4][nd][ni]
	
											nGraph := aScan(aEstab,{|x| x == "[REFERENCIA]"})
				
											If ( nGraph == 0 )

												nRefer := SuperVal(TRB_REFER)
												If lConts 
													nSubG++
												Endif	
												aadd(aEstab, cString )
												aadd(aEstab, "[TITLE]" )
												aadd(aEstab," Instr.: "+cInstrumento)

												//AADD(aMed64, "Instr.: "+cInstrumento ) //Titulo

												Aadd(aEstab,"[LANGUAGE]")
												Aadd(aEstab,Upper(__Language) )

												aadd(aEstab, "[REFERENCIA]" )
												aadd(aEstab, TRB_REFER )
												nDec := Qa_NumDec(TRB_REFER)
												aadd(aEstab, "[DECIMAIS]" )
												aadd(aEstab, Str(nDec,1) )
												aadd(aEstab, "[INICIO DE DADOS]" )
												If (mv_par06 == 1 .AND. !lMsa3Ed .OR. mv_par06 == 2 .AND. lMsa3Ed)
													aadd(aVlr, STRZERO(DAY(TRB_DATA),2,0)+"/"+STRZERO(MONTH(TRB_DATA),2,0)+"/"+STRZERO(YEAR(TRB_DATA),4,0)+"00:00"+ AllTrim(iif(cPaisLoc == "BRA",StrTran(TRB_CICLOS,".",","),StrTran(TRB_CICLOS,",",".")))) 
													aadd(aMed64, AllTrim(iif(cPaisLoc == "BRA",StrTran(TRB_CICLOS,".",","),StrTran(TRB_CICLOS,",","."))))
												Endif
												dData := TRB_DATA
												nSoma := SuperVal(TRB_CICLOS)
												nAcum := 1
												nMaior:= SuperVal(TRB_CICLOS)
												nMenor:= SuperVal(TRB_CICLOS)
												nNroAmo++
												nNreMed++
											Else
												If dData == TRB_DATA
													nNreMed++
													If lConts
														nSubG++
													Endif	
													nSoma += SuperVal(TRB_CICLOS)
													nAcum += 1
													If SuperVal(TRB_CICLOS) > nMaior
														nMaior := SuperVal(TRB_CICLOS)
													Endif
							                        cUltVlr := TRB_CICLOS
													If SuperVal(TRB_CICLOS) < nMenor
														nMenor := SuperVal(TRB_CICLOS)
													Endif                          
													If (mv_par06 == 1 .AND. !lMsa3Ed .OR. mv_par06 == 2 .AND. lMsa3Ed)
														aadd(aVlr, STRZERO(DAY(TRB_DATA),2,0)+"/"+STRZERO(MONTH(TRB_DATA),2,0)+"/"+STRZERO(YEAR(TRB_DATA),4,0)+"00:00"+AllTrim(iif(cPaisLoc == "BRA",StrTran(TRB_CICLOS,".",","),StrTran(TRB_CICLOS,",",".")))) 
														aadd(aMed64, AllTrim(iif(cPaisLoc == "BRA",StrTran(TRB_CICLOS,".",","),StrTran(TRB_CICLOS,",","."))))
												Endif
												Else
													lConts := .F.
													If lMsa3Ed
														nRefer := SuperVal(TRB_REFER)
														nSomAmp := nSomAmp + (nMaior - nMenor)
													Endif	
													aadd(aEstab, STRZERO(DAY(dData),2,0)+"/"+STRZERO(MONTH(dData),2,0)+"/"+STRZERO(YEAR(dData),4,0)+AllTrim(StrTran(Str(nSoma/nAcum,10,nDec),".",",")))
													nSomMed := nSomMed + (nSoma/nAcum)
													If !Eof() .and. TRB_FILIAL == xFilial("QM7") .And.;
														TRB_INSTR+TRB_REVINS == cInstrumento .And.;
														TRB_DATA <= MV_PAR03
														If (SuperVal(TRB_REFER)  >= SuperVal(MV_PAR04) .and. SuperVal(TRB_REFER)  <= SuperVal(MV_PAR05))
															nSoma := SuperVal(TRB_CICLOS)
															nAcum := 1
															dData := TRB_DATA
															nMaior := SuperVal(TRB_CICLOS)
															nMenor := SuperVal(TRB_CICLOS)
															nNroAmo++
															nNreMed :=0 
															If (mv_par06 == 1 .AND. !lMsa3Ed .OR. mv_par06 == 2 .AND. lMsa3Ed)
																aadd(aVlr, STRZERO(DAY(TRB_DATA),2,0)+"/"+STRZERO(MONTH(TRB_DATA),2,0)+"/"+STRZERO(YEAR(TRB_DATA),4,0)+"00:00"+AllTrim(iif(cPaisLoc == "BRA",StrTran(TRB_CICLOS,".",","),StrTran(TRB_CICLOS,",",".")))) 
																aadd(aMed64, AllTrim(iif(cPaisLoc == "BRA",StrTran(TRB_CICLOS,".",","),StrTran(TRB_CICLOS,",","."))))
															Endif
														Endif
													EndIf
												EndIf
											EndIf
										Endif
									Next ni
								Next nd
							Endif					
					    Else
							dbSelectArea("QM8")
							dbSetOrder(1)
							If dbSeek(xFilial("QM8")+TRB_INSTR+TRB_REVINS+DtoS(TRB_DATA)+TRB_CSEQ+TRB_ESCALA+TRB_REVESC+TRB_PONTO+TRB_REVPAD)
								While QM8->(!Eof()) .and. QM8->QM8_FILIAL+QM8->QM8_INSTR+QM8->QM8_REVINS+DtoS(QM8->QM8_DATA)+;
								      QM8->QM8_CSEQ+QM8->QM8_ESCALA+QM8->QM8_REVESC+QM8->QM8_PADRAO+QM8->QM8_REVPAD ==;
								      xFilial("QM8")+TRB_INSTR+TRB_REVINS+DtoS(TRB_DATA)+TRB_CSEQ+TRB_ESCALA+TRB_REVESC+;
								      TRB_PONTO+TRB_REVPAD
		    						
									nPoTol := Ascan(aRegQM6, { |x| x[7]+Alltrim(x[2])+Alltrim(x[3])+Alltrim(x[6]) ==;
									DtoS(TRB_DATA)+Alltrim(TRB_ESCALA)+Alltrim(TRB_PONTO)+Alltrim(TRB_CSEQ)})
									If nPoTol > 0
										If Empty(aRegQM6[nPoTol][5])
											TRB_TOLPRO := "0"										
										Else
											TRB_TOLPRO := aRegQM6[nPoTol][5]
										Endif
									Endif
		    						
									If (QM9->QM9_TIPAFE $ "3|9")
										TRB_CICLOS := QM8->QM8_VLRFID
									Else								
										TRB_CICLOS := QM8->QM8_VLRFIM
									EndIf								
		
									nGraph := aScan(aEstab,{|x| x == "[REFERENCIA]"})
		
									If ( nGraph == 0 )
										nRefer := SuperVal(TRB_REFER)
										If lConts 
											nSubG++
										Endif
										aadd(aEstab, cString )
										aadd(aEstab, "[TITLE]" )
										aadd(aEstab," Instr.: "+cInstrumento)

										//AADD(aMed64, "Instr.: "+cInstrumento ) //Titulo

										Aadd(aEstab,"[LANGUAGE]")
										Aadd(aEstab,Upper(__Language) )

										aadd(aEstab, "[REFERENCIA]" )
										aadd(aEstab, TRB_REFER )
										nDec := Qa_NumDec(TRB_REFER)
										aadd(aEstab, "[DECIMAIS]" )
										aadd(aEstab, Str(nDec,1) )
										aadd(aEstab, "[INICIO DE DADOS]" )
										If (mv_par06 == 1 .AND. !lMsa3Ed .OR. mv_par06 == 2 .AND. lMsa3Ed)
											aadd(aVlr, STRZERO(DAY(TRB_DATA),2,0)+"/"+STRZERO(MONTH(TRB_DATA),2,0)+"/"+STRZERO(YEAR(TRB_DATA),4,0)+"00:00"+ AllTrim(iif(cPaisLoc == "BRA",StrTran(TRB_CICLOS,".",","),StrTran(TRB_CICLOS,",",".")))) 
											aadd(aMed64, AllTrim(iif(cPaisLoc == "BRA",StrTran(TRB_CICLOS,".",","),StrTran(TRB_CICLOS,",","."))))
										Endif
										dData := TRB_DATA
										nSoma := SuperVal(TRB_CICLOS)
										nAcum := 1
										nMaior:= SuperVal(TRB_CICLOS)
										nMenor:= SuperVal(TRB_CICLOS)
										nNroAmo++
										nNreMed++
									Else
										If dData == TRB_DATA
											nSoma += SuperVal(TRB_CICLOS)
											nAcum += 1     
											nNreMed++
											If lConts
												nSubG++
											Endif	
											If SuperVal(TRB_CICLOS) > nMaior
												nMaior := SuperVal(TRB_CICLOS)
											Endif
							                cUltVlr := TRB_CICLOS
											If SuperVal(TRB_CICLOS) < nMenor
												nMenor := SuperVal(TRB_CICLOS)
											Endif
											If (mv_par06 == 1 .AND. !lMsa3Ed .OR. mv_par06 == 2 .AND. lMsa3Ed)
												aadd(aVlr, STRZERO(DAY(TRB_DATA),2,0)+"/"+STRZERO(MONTH(TRB_DATA),2,0)+"/"+STRZERO(YEAR(TRB_DATA),4,0)+"00:00"+AllTrim(iif(cPaisLoc == "BRA",StrTran(TRB_CICLOS,".",","),StrTran(TRB_CICLOS,",",".")))) 
												aadd(aMed64, AllTrim(iif(cPaisLoc == "BRA",StrTran(TRB_CICLOS,".",","),StrTran(TRB_CICLOS,",","."))))
											Endif 
										Else
											lConts := .F.
											If lMsa3Ed
												nRefer := SuperVal(TRB_REFER)
												nSomAmp := nSomAmp + (nMaior - nMenor)
											Endif
											aadd(aEstab, STRZERO(DAY(dData),2,0)+"/"+STRZERO(MONTH(dData),2,0)+"/"+STRZERO(YEAR(dData),4,0)+AllTrim(StrTran(Str(nSoma/nAcum,10,nDec),".",",")))
											nSomMed := nSomMed + (nSoma/nAcum)
	
											If !Eof() .and. TRB_FILIAL == xFilial("QM7") .And.;
												TRB_INSTR+TRB_REVINS == cInstrumento .And.;
												TRB_DATA <= MV_PAR03
												If (SuperVal(TRB_REFER)  >= SuperVal(MV_PAR04) .and. SuperVal(TRB_REFER)  <= SuperVal(MV_PAR05))
													nSoma := SuperVal(TRB_CICLOS)
													nAcum := 1
													dData := TRB_DATA
													nMaior := SuperVal(TRB_CICLOS)
													nMenor := SuperVal(TRB_CICLOS)
													nNroAmo++
													nNreMed :=0
													If (mv_par06 == 1 .AND. !lMsa3Ed .OR. mv_par06 == 2 .AND. lMsa3Ed) 
														aadd(aVlr, STRZERO(DAY(TRB_DATA),2,0)+"/"+STRZERO(MONTH(TRB_DATA),2,0)+"/"+STRZERO(YEAR(TRB_DATA),4,0)+"00:00"+AllTrim(iif(cPaisLoc == "BRA",StrTran(TRB_CICLOS,".",","),StrTran(TRB_CICLOS,",",".")))) 
												    	aadd(aMed64, AllTrim(iif(cPaisLoc == "BRA",StrTran(TRB_CICLOS,".",","),StrTran(TRB_CICLOS,",","."))))
													Endif
												Endif
											EndIf

										EndIf
									EndIf
									dbSelectArea("QM8")
									dbSetOrder(1)
									dbSkip()
								EndDo
							Endif
						Endif
				Endif

				If mv_par01 == 3 .AND. mv_par06 == 2 // Validacao de qtde. de medicoes coletadas p/ dia no intervalo para Grafico de Estabilidade MSA 3 Edicao
					nsGrupo		:= 0
					aQtdeMedDia := {}
					cDataAtu := Substr(aVlr[1],1,10)
					Aadd(aQtdeMedDia,0)
					For nK:=1 To Len(aVlr)
						If Alltrim(cDataAtu) == Alltrim(Substr(aVlr[nk],1,10))
							aQtdeMedDia[Len(aQtdeMedDia)]++
						Else
						    cDataAtu := Substr(aVlr[nk],1,10)
							Aadd(aQtdeMedDia,1)
						Endif
					Next nK				
					nsGrupo := aQtdeMedDia[1]
					
					For nK:=1 To Len(aQtdeMedDia) // Validacao para verificar se no periodo ha numero igual de medicoes por dia
						For nJ:=2 To Len(aQtdeMedDia)
							If aQtdeMedDia[nK] <> aQtdeMedDia[nJ]
								HELP(" ",1,"QMC10QTMED")
								Return(NIL)
							Endif
						Next nJ
					Next nK
					
				Endif

				dbSelectArea("TRB")
				dbSkip()
				
				EndDo					
				
				If lContinua
					aadd(aEstab, STRZERO(DAY(dData),2,0)+"/"+STRZERO(MONTH(dData),2,0)+"/"+STRZERO(YEAR(dData),4,0)+AllTrim(StrTran(Str(nSoma/nAcum,10,nDec),".",",")))
                EndIf
		
				If Len(aEstab) < 8 .OR. (!lMsa3Ed .AND. Len(aEstab) <=  9) // Um aEstab com 9 linhas   tem  somente uma  data
					MsgInfo(STR0041)	
					aEstab := {} // Zero o Array
					lContinua := .F.
				EndIf                

				If lMsa3Ed .AND. lContinua
					Aadd(aNov,"QACHART.DLL - NORMAL") 
		
					aadd(aNov, "[TITLE]" )
					aadd(aNov, OemToAnsi(STR0039)+Alltrim(cInstrumento)) //Instrumento:			 

					Aadd(aNov,"[LANGUAGE]")
					Aadd(aNov,Upper(__Language) )

					aadd(aNov, "[INICIO DE DADOS]" )
					For ny := 1 To Len(aVlr)
						aadd(aNov,aVlr[ny]) 			
					Next ny
					aadd(aNov, "[FIM DE DADOS]")  
					nNreMed++
					nSomMed := (nSomMed + (nSoma/nAcum))/(nNroAmo)
					nSomAmp := (nSomAmp + (nMaior - nMenor))/nNroAmo
					
					If nNreMed == 2
						nConst := 1.88
					Else
						If nNreMed == 3
							nConst := 1.02
						Else
							IF nNreMed == 4
								nConst := 0.73
							Else
								nConst := 0.58
					        Endif
						Endif
					Endif				        
		
					nSomLSE := nSomMed + nSomAmp*nConst
					nSomLIE := nSomMed - nSomAmp*nConst			             
		
					If nNreMed == 2
						nConst := 3.27
					Else
						If nNreMed == 3
							nConst := 2.57
						Else
							If nNreMed == 4
								nConst := 2.28
							Else
								nConst := 2.211
							Endif
						Endif
					Endif	
		
					//Calculo para serem mostrados no relatorio MSA 3 Edicao
					
					nTend := nSomMed - nRefer
		
		            //Carrega a tabela D2
					QTC010D2()
					If nNreMed > 20
						nNreAu := 20					
					Else
						nNreAu := nNreMed
					Endif
					If nNroAmo >  21
						nNroAu := 21
					Else
						nNroAu := nNroAmo
					Endif
					
					If (nNreAu == 0) .OR. (nNroAu == 0)
						nSigR := 0
					Else
						nSigR := nSomAmp/aTbv[nNreAu,nNroAu]
					EndIf
					
					
					nSigB := nSigR/((nNreAu*nNroAu)^0.5)
					
					nErmos := Alltrim(StrTran(Str((nErmos/100)/2),".",","))		

					IF !lExistChart
						nTInv := SuperVal(CallDll32("STUDENTINV",nErmos+";"+Alltrim(Str(Int(aTab[nNreAu,nNroAu])))))
					ELSE
						nTInv := QLDSTDINV(SUPERVAL(nErmos), Int(aTab[nNreAu,nNroAu]))
					ENDIF

					nTendLSE := nTend + ((nSigB * (aTbv[nNreAu,21]/aTbv[nNreAu,nNroAu]))*nTInv)
					
					nTendLIE := nTend - ((nSigB * (aTbv[nNreAu,21]/aTbv[nNreAu,nNroAu]))*nTInv)		
		
					If nRefer ==0
						cReten := ""
					Else
						If nRefer < 0
							cReTen := OemToAnsi(STR0033)		//"O sistema nao e adequado quanto a tendencia"
						Else
							If nTendLIE > 0
								cReTen := OemToAnsi(STR0033)	//"O sistema nao e adequado quanto a tendencia"
							Else
								cReTen := OemToAnsi(STR0034)	//"O sistema de medicao e adequado quanto a tendencia"
							Endif	
						Endif
					Endif				
				Endif	
		
				If lMsa3Ed .AND. lContinua
					aadd(aNov, "[SUBGRUPO]")			
					aadd(aNov, Alltrim(Str(IIF(MV_PAR09 == 0, nsGrupo, MV_PAR09))))			
					aadd(aNov, "[MSGE]")					
					aadd(aNov, Alltrim(cReTen))								
					aadd(aNov, "[TEND]")					
					aadd(aNov, Alltrim(Str(nTend)))								
					aadd(aNov, "[SIGR]")					
					aadd(aNov, Alltrim(Str(nSigR)))								
					aadd(aNov, "[SIGB]")					
					aadd(aNov, Alltrim(Str(nSigB)))								
					aadd(aNov, "[TLSE]")					
					aadd(aNov, Alltrim(Str(nTendLSE)))								
					aadd(aNov, "[TLIE]")					
					aadd(aNov, Alltrim(Str(nTendLIE)))								
				Else
					aadd(aEstab, "[FIM DE DADOS]" )
				Endif				

		EndCase 
Endif  

dbCloseArea()

Endif
RestArea(aArea)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Controle para abertura do grafico. Caso o grafico fique aberto por mais de 3 minutos ³
//³ nao perca a conexao.																 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PtInternal(9,"FALSE")

IF LEN(aMed64) == 0
	Help(NIL, NIL, STR0050, NIL, STR0051, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0052})//###"Medições" ###"Não existem medições suficientes para gerar o gráfico." ###"Para gerar o gráfico deste instrumento realize as medições."
ELSE
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta pontos da reta                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do Case
		Case MV_PAR01 == 1
			If MV_PAR08 == 1
				If lExistChart
					aMedicoe := {}
					aDatas   := {}
					FOR nX := 1 TO LEN(aMedAux)
						nPosDoisPt := AT(":", aMedAux[nX])
						cDataMed   := ALLTRIM(SUBSTR(aMedAux[nX], 1, AT(":", aMedAux[nX]) - 1))
						If aScan(aDatas, cDataMed) == 0
							If nX > 1
								AADD(aMedicoe, aMedic)
							EndIf
							aDatas := {}
							aMedic := {}
						EndIf
						AADD(aDatas, cDataMed)
						AADD(aMedic, SUPERVAL(ALLTRIM(SUBSTR(aMedAux[nX], nPosDoisPt + 1, LEN(aMedAux[nX])))))
						If nX == Len(aMedAux)
							AADD(aMedicoe, aMedic)
						Endif
					NEXT nX

					QIEMGRAFIC(aMedic, 1,aMedicoe,{"Media", "Amplitude Movel"})
				Else
					GERATXT32(aXbr,,cDir)
					CallDll32("ShowChart","QACHART.SPC","6",cDir,"1",Iif(!Empty(cSenhas),Encript(Alltrim(cSenhas),0),"PADRAO"))
				EndIf
			Endif
			If !lExistChart	
				GERATXT32(aTendencia,,cDir)
			EndIf
			If !lMsg
				If lExistChart
					nPosRef := ASCAN( aTendencia, "[REFERENCIA]" ) + 1
					nPosLSL := ASCAN( aTendencia, "[LSL]" ) + 1
					nPosUSL := ASCAN( aTendencia, "[USL]" ) + 1
					aLimites := {}
					aMedic   := {}
					aLimites := {SUPERVAL(aTendencia[nPosRef]), SUPERVAL(aTendencia[nPosLSL]), SUPERVAL(aTendencia[nPosUSL])}
					
					FOR nX := 1 TO LEN(aMed64)
						AADD(aMedic, ALLTRIM(aMed64[nX]))
					NEXT nX

					QIEMGRAFIC(aMedic, 5,,,aLimites)
				Else
					If lMsa4Ed
						Calldll32("ShowChart","QACHART.SPC","13",cDir,TENDENCIA4E,Iif(!Empty(cSenhas),Encript(Alltrim(cSenhas),0),"PADRAO"))
					Else
						Calldll32("ShowChart","QACHART.SPC","3",cDir,TENDENCIA,Iif(!Empty(cSenhas),Encript(Alltrim(cSenhas),0),"PADRAO"))
					EndIf
				EndIf
			Else
				MsgAlert(STR0049)//"Nao sera possivel gerar o grafico de Histograma,pois o Erro Amostral não foi cadastrado!"
			Endif	
		Case MV_PAR01 == 2
			If lExistChart
				IF FWIsInCallStack("QMTA140")
					aPontos := {}
					FOR nX := 1 TO LEN(aMed64[6])
						AADD(aPontos, aMed64[6, nX])
					NEXT nX
					FOR nX := 1 TO LEN(aMed64[7])
						AADD(aPontos, aMed64[7, nX])
					NEXT nX
					AADD(aMed64, aPontos)
				ENDIF
				QIEMGRAFIC(aMed64, 4)		
			Else
				GERATXT32(aLinearFim,,cDir)
				If lMsa4Ed .AND. IIF(!lCalib,MV_PAR06==3,MV_PAR07==2)
					Calldll32("ShowChart","QACHART.SPC","14",cDir,LINEARIDADE4E,Iif(!Empty(cSenhas),Encript(Alltrim(cSenhas),0),"PADRAO"))
				ElseIf lMsa3Ed .AND. IIF(!lCalib,MV_PAR06==2,MV_PAR07==2)
					Calldll32("ShowChart","QACHART.SPC","11",cDir,LINEARIDADE3E,Iif(!Empty(cSenhas),Encript(Alltrim(cSenhas),0),"PADRAO"))
				Else
					Calldll32("ShowChart","QACHART.SPC","5",cDir,LINEARIDADE,Iif(!Empty(cSenhas),Encript(Alltrim(cSenhas),0),"PADRAO"))
				EndIF
			EndIf
		Case MV_PAR01 == 3
			If lExistChart

				/* nPosRef := ASCAN( aNov, "[TEND]" ) + 1
				nPosLSL := ASCAN( aNov, "[TLSE]" ) + 1
				nPosUSL := ASCAN( aNov, "[TLIE]" ) + 1
				aLimites := {}
				aLimites := {SUPERVAL(aNov[nPosRef]), SUPERVAL(aNov[nPosLSL]), SUPERVAL(aNov[nPosUSL])} */

				/* aMedicoe := {}
				FOR nX := 1 TO LEN(aMed64)
					AADD(aMedic, SUPERVAL(STRTRAN(ALLTRIM(aMed64[nX]),",",".")))
				NEXT nX
				AADD(aMedicoe, aMedic) */

				aMedicoe := {}
				aDatas   := {}
				FOR nX := 1 TO LEN(aVlr)
					nPosDoisPt := AT(":", aVlr[nX])
					cDataMed   := ALLTRIM(SUBSTR(aVlr[nX], 1, AT(":", aVlr[nX]) - 1))
					If aScan(aDatas, cDataMed) == 0
						If nX > 1
							AADD(aMedicoe, aMedic)
						EndIf
						aDatas := {}
						aMedic := {}
					EndIf
					AADD(aDatas, cDataMed)
					AADD(aMedic, SUPERVAL(ALLTRIM(SUBSTR(aVlr[nX], nPosDoisPt + 1, LEN(aVlr[nX])))))
					If nX == Len(aVlr)
						AADD(aMedicoe, aMedic)
					Endif
				NEXT nX
				
				QIEMGRAFIC(aMed64, 1,aMedicoe,{"Media", "Amplitude Movel"})
			Else
				If lMsa3Ed
					GERATXT32(aNov,,cDir)
					Calldll32("ShowChart","QACHART.SPC","6",cDir,NORMAL,Iif(!Empty(cSenhas),Encript(Alltrim(cSenhas),0),"PADRAO"))
				Else
					GERATXT32(aEstab,,cDir)
					Calldll32("ShowChart","QACHART.SPC","5",cDir,ESTABILIDADE,Iif(!Empty(cSenhas),Encript(Alltrim(cSenhas),0),"PADRAO"))
				Endif
			EndIf	
	EndCase
ENDIF    

PtInternal(9,"TRUE")

If !lImprm
	If mv_par07 == 1 .and. lMsa3Ed //Imprime grafico, disponibilizado para 3 Edicao....
		If mv_par01 == 1
			If Right(cDir,1) <> "\"
				cDir += "\"
			Endif
			If File(cDir+"TENDE.BMP")
				QMTR340(.t.,mv_par01,,,,lBiCaudal)
			Endif	
		ElseIf mv_par01 == 2
			If Right(cDir,1) <> "\"
				cDir += "\"
			Endif
			If File(cDir+"LINEA.BMP")
				QMTR340(.t.,mv_par01)	
			Endif	
		ElseIf mv_par01 == 3
			If Right(cDir,1) <> "\"
				cDir += "\"
			Endif
			If File(cDir+"LEG1.BMP")
				QMTR340(.t.,mv_par01)	
			Endif	
		Endif
	Endif	
Else
	If mv_par08 == 1 .and. lMsa3Ed
		If mv_par01 == 1
			If Right(cDir,1) <> "\"
				cDir += "\"
			Endif
			If File(cDir+"TENDE.BMP")
				QMTR340(.f.,mv_par01,SubStr(cInstrumento,1,(TamSx3("QM2_INSTR")[1])),SubStr(cInstrumento,TamSx3("QM2_INSTR")[1]+1,TamSx3("QM2_REVINS")[1]),cDM2Dec)
			Endif	
		ElseIf mv_par01 == 2
			If Right(cDir,1) <> "\"
				cDir += "\"
			Endif
			If File(cDir+"LINEA.BMP")
				QMTR340(.f.,mv_par01,SubStr(cInstrumento,1,(TamSx3("QM2_INSTR")[1])),SubStr(cInstrumento,TamSx3("QM2_INSTR")[1]+1,TamSx3("QM2_REVINS")[1]),cDM2Dec)	
			Endif	
		ElseIf mv_par01 == 3
			If Right(cDir,1) <> "\"
				cDir += "\"
			Endif
			If File(cDir+"LEG1.BMP")
				QMTR340(.f.,mv_par01,SubStr(cInstrumento,1,(TamSx3("QM2_INSTR")[1])),SubStr(cInstrumento,TamSx3("QM2_INSTR")[1]+1,TamSx3("QM2_REVINS")[1]),cDM2Dec)	
			Endif	
		Endif
	Endif
Endif

Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Qmc010DCLkTolºAutor  ³Denis Martins	    º Data ³  06/17/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Permite edicao do listbox coluna Tolerancia                 	 º±±
±±º          ³                                                            	 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTC010                                                   	 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qmc010DCLkTol(aRegQM6,oQual)
lEditCell(@aRegQM6,oQual,PesqPict("QM7","QM7_ESPEC",TamSx3("QM7_ESPEC")[1]),5)
If lMsa3Ed
	lEditCell(@aRegQM6,oQual,PesqPict("QM7","QM7_ESPEC",TamSx3("QM7_ESPEC")[1]),6)
Endif	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Qmc010LinºAutor  ³Denis Martins	    º Data ³  06/17/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Permite edicao do listbox coluna Tolerancia                º±±
±±º          ³                                                         	 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTC010                                                 	 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qmc010Lin(oQual,oDlgTol,aRegQM6)
oSay1:SetText(STR0025+aRegQM6[oQual:nAT,2]) //"Escala: "
oSay2:SetText(STR0026+aRegQM6[oQual:nAT,3]) //"Ponto.: "
oSay1:Show()
oSay2:Show()
Return 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QTC010D2  ºAutor  ³Denis Martins       º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o valor da tabela D2                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTC010                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QTC010D2(lGraus)
Default lGraus := .F.
/*	2						3						4						5						6						7						8						9						10						11						12						13						14						15						16						17						18						19						20
1	aTab[2,1] := 1,41421;	aTab[3,1] := 1,91155;	aTab[4,1]:= 2,23887;	aTab[5,1] := 2,48124;	aTab[6,1] := 2,67253;	aTab[7,1] := 2,82981;	aTab[8,1] := 2,96288;	aTab[9,1] := 3,07794;	aTab[10,1] := 3,17905;	aTab[11,1] := 3,26909;	aTab[12,1] := 3,35016;	aTab[13,1] := 3,42378;	aTab[14,1] := 3,49116;	aTab[15,1] := 3,55333;	aTab[16,1] := 3,61071;	aTab[17,1] := 3,66422;	aTab[18,1] := 3,71424;	aTab[19,1] := 3,76118;	aTab[20,1] := 3,80537
2	aTab[2,2] := 1,27931	aTab[3,2] := 1,80538	aTab[4,2] := 2,15069	aTab[5,2] := 2,40484	aTab[6,2] := 2,60438	aTab[7,2] := 2,76779	aTab[8,2] := 2,90562	aTab[9,2] := 3,02446	aTab[10,2] := 3,12869	aTab[11,2] := 3,22134	aTab[12,2] := 3,30463;	aTab[13,2] := 3,38017	aTab[14,2] := 3,44922	aTab[15,2] := 3,51287	aTab[16,2] := 3,57156	aTab[17,2] := 3,62625	aTab[18,2] := 3,67734	aTab[19,2] := 3,72524	aTab[20,2] := 3,77032
3	aTab[2,3] := 1,23105	aTab[3,3] := 1,76858	aTab[4,3] := 2,12049	aTab[5,3] := 2,37883	aTab[6,3] := 2,58127	aTab[7,3] := 2,74681	aTab[8,3] := 2,88628	aTab[9,3] := 3,00643	aTab[10,3] := 3,11173	aTab[11,3] := 3,20526	aTab[12,3] := 3,28931	aTab[13,3] := 3,3655	aTab[14,3] := 3,43512	aTab[15,3] := 3,49927	aTab[16,3] := 3,55842	aTab[17,3] := 3,61351	aTab[18,3] := 3,66495	aTab[19,3] := 3,71319	aTab[20,3] := 3,75857
4	aTab[2,4] := 1,20621	aTab[3,4] := 1,74989	aTab[4,4] := 2,10522	aTab[5,4] := 2,36571	aTab[6,4] := 2,56964	aTab[7,4] := 2,73626	aTab[8,4] := 2,87656	aTab[9,4] := 2,99737	aTab[10,4] := 3,10321	aTab[11,4] := 3,1972	aTab[12,4] := 3,28163	aTab[13,4] := 3,35815	aTab[14,4] := 3,42805	aTab[15,4] := 3,49246	aTab[16,4] := 3,55183	aTab[17,4] := 3,60712	aTab[18,4] := 3,65875	aTab[19,4] := 3,70715	aTab[20,4] := 3,75268
5	aTab[2,5] := 1,19105	aTab[3,5] := 1,73857	aTab[4,5] := 2,09601	aTab[5,5] := 2,35781	aTab[6,5] := 2,56263	aTab[7,5] := 2,72991	aTab[8,5] := 2,87071	aTab[9,5] := 2,99192	aTab[10,5] := 3,09808	aTab[11,5] := 3,19235	aTab[12,5] := 3,27701	aTab[13,5] := 3,35372	aTab[14,5] := 3,42381	aTab[15,5] := 3,48836	aTab[16,5] := 3,54787	aTab[17,5] := 3,60328	aTab[18,5] := 3,65502	aTab[19,5] := 3,70352	aTab[20,5] := 3,74914
6	aTab[2,6] := 1,18083	aTab[3,6] := 1,73099	aTab[4,6] := 2,08985	aTab[5,6] := 2,35253	aTab[6,6] := 2,55795	aTab[7,6] := 2,72567	aTab[8,6] := 2,8668		aTab[9,6] := 2,98829	aTab[10,6] := 3,09467	aTab[11,6] := 3,18911	aTab[12,6] := 3,27392	aTab[13,6] := 3,35077	aTab[14,6] := 3,42097	aTab[15,6] := 3,48563	aTab[16,6] := 3,54522	aTab[17,6] := 3,60072	aTab[18,6] := 3,65253	aTab[19,6] := 3,70109	aTab[20,6] := 3,74678
7	aTab[2,7] := 1,17348	aTab[3,7] := 1,72555	aTab[4,7] := 2,08543	aTab[5,7] := 2,34875	aTab[6,7] := 2,5546		aTab[7,7] := 2,72263	aTab[8,7] := 2,86401	aTab[9,7] := 2,98568	aTab[10,7] := 3,09222	aTab[11,7] := 3,18679	aTab[12,7] := 3,27172	aTab[13,7] := 3,34866	aTab[14,7] := 3,41894	aTab[15,7] := 3,48368	aTab[16,7] := 3,54333	aTab[17,7] := 3,59888	aTab[18,7] := 3,65075	aTab[19,7] := 3,69936	aTab[20,7] := 3,74509
8	aTab[2,8] := 1,16794	aTab[3,8] := 1,72147	aTab[4,8] := 2,08212	aTab[5,8] := 2,34591	aTab[6,8] := 2,55208	aTab[7,8] := 2,72036	aTab[8,8] := 2,86192	aTab[9,8] := 2,98373	aTab[10,8] := 3,09039	aTab[11,8] := 3,18506	aTab[12,8] := 3,27006	aTab[13,8] := 3,34708	aTab[14,8] := 3,41742	aTab[15,8] := 3,48221	aTab[16,8] := 3,54192	aTab[17,8] := 3,59751	aTab[18,8] := 3,64941	aTab[19,8] := 3,69806	aTab[20,8] := 3,74382
9	aTab[2,9] := 1,16361	aTab[3,9] := 1,71828	aTab[4,9] := 2,07953	aTab[5,9] := 2,3437		aTab[6,9] := 2,55013	aTab[7,9] := 2,71858	aTab[8,9] := 2,86028	aTab[9,9] := 2,98221	aTab[10,9] := 3,08896	aTab[11,9] := 3,1837	aTab[12,9] := 3,26878	aTab[13,9] := 3,34585	aTab[14,9] := 3,41624	aTab[15,9] := 3,48107	aTab[16,9] := 3,54081	aTab[17,9] := 3,59644	aTab[18,9] := 3,64838	aTab[19,9] := 3,69705	aTab[20,9] := 3,74284
10	aTab[2,10] := 1,16014	aTab[3,10] := 1,71573	aTab[4,10] := 2,07746	aTab[5,10] := 2,34192	aTab[6,10] := 2,54856	aTab[7,10] := 2,71717	aTab[8,10] := 2,85898	aTab[9,10] := 2,981		aTab[10,10] := 3,08781	aTab[11,10] := 3,18262	aTab[12,10] := 3,26775	aTab[13,10] := 3,34486	aTab[14,10] := 3,41529	aTab[15,10] := 3,48016	aTab[16,10] := 3,53993	aTab[17,10] := 3,59559	aTab[18,10] := 3,64755	aTab[19,10] := 3,69625	aTab[20,10] := 3,742050
11	aTab[2,11] := 1,15729	aTab[3,11] := 1,71363	aTab[4,11] := 2,07577	aTab[5,11] := 2,34048	aTab[6,11] := 2,54728	aTab[7,11] := 2,716		aTab[8,11] := 2,85791	aTab[9,11] := 2,98		aTab[10,11] := 3,08688	aTab[11,11] := 3,18174	aTab[12,11] := 3,2669	aTab[13,11] := 3,34406	aTab[14,11] := 3,41452	aTab[15,11] := 3,47941	aTab[16,11] := 3,53921	aTab[17,11] := 3,59489	aTab[18,11] := 3,64687	aTab[19,11] := 3,69558	aTab[20,11] := 3,74141
12	aTab[2,12] := 1,1549	aTab[3,12] := 1,71189	aTab[4,12] := 2,07436	aTab[5,12] := 2,33927	aTab[6,12] := 2,54621	aTab[7,12] := 2,71504	aTab[8,12] := 2,85702	aTab[9,12] := 2,97917	aTab[10,12] := 3,0861	aTab[11,12] := 3,181	aTab[12,12] := 3,2662	aTab[13,12] := 3,34339	aTab[14,12] := 3,41387	aTab[15,12] := 3,47879	aTab[16,12] := 3,53861	aTab[17,12] := 3,5943	aTab[18,12] := 3,6463	aTab[19,12] := 3,69503	aTab[20,12] := 3,74087
13	aTab[2,13] := 1,15289	aTab[3,13] := 1,71041	aTab[4,13] := 2,07316	aTab[5,13] := 2,33824	aTab[6,13] := 2,5453	aTab[7,13] := 2,71422	aTab[8,13] := 2,85627	aTab[9,13] := 2,97847	aTab[10,13] := 3,08544	aTab[11,13] := 3,18037	aTab[12,13] := 3,26561	aTab[13,13] := 3,34282	aTab[14,13] := 3,41333	aTab[15,13] := 3,47826	aTab[16,13] := 3,5381	aTab[17,13] := 3,59381	aTab[18,13] := 3,64582	aTab[19,13] := 3,69457	aTab[20,13] := 3,74041                                                                                                                                                                                                                                                                                               
14	aTab[2,14] := 1,15115	aTab[3,14] := 1,70914	aTab[4,14] := 2,07213	aTab[5,14] := 2,33737	aTab[6,14] := 2,54452	aTab[7,14] := 2,71351	aTab[8,14] := 2,85562	aTab[9,14] := 2,97787	aTab[10,14] := 3,08487	aTab[11,14] := 3,17984	aTab[12,14] := 3,2651	aTab[13,14] := 3,34233	aTab[14,14] := 3,41286	aTab[15,14] := 3,47781	aTab[16,14] := 3,53766	aTab[17,14] := 3,59339	aTab[18,14] := 3,64541	aTab[19,14] := 3,69417	aTab[20,14] := 3,740027
15	aTab[2,15] := 1,14965	aTab[3,15] := 1,70804	aTab[4,15] := 2,07125	aTab[5,15] := 2,33661	aTab[6,15] := 2,54385	aTab[7,15] := 2,7129	aTab[8,15] := 2,85506	aTab[9,15] := 2,97735	aTab[10,15] := 3,08438	aTab[11,15] := 3,17938	aTab[12,15] := 3,26465	aTab[13,15] := 3,34191	aTab[14,15] := 3,41245	aTab[15,15] := 3,47742	aTab[16,15] := 3,53728	aTab[17,15] := 3,59302	aTab[18,15] := 3,64505	aTab[19,15] := 3,69382	aTab[20,15] := 3,77969
16	aTab[2,16] := 1,14833	aTab[3,16] := 1,70708	aTab[4,16] := 2,07047	aTab[5,16] := 2,33594	aTab[6,16] := 2,54326	aTab[7,16] := 2,71237	aTab[8,16] := 2,85457	aTab[9,16] := 2,97689	aTab[10,16] := 3,08395	aTab[11,16] := 3,17897	aTab[12,16] := 3,26427	aTab[13,16] := 3,34154	aTab[14,16] := 3,4121	aTab[15,16] := 3,47707	aTab[16,16] := 3,53695	aTab[17,16] := 3,5927	aTab[18,16] := 3,64474	aTab[19,16] := 3,69351	aTab[20,16] := 3,73939
17	aTab[2,17] := 1,14717	aTab[3,17] := 1,70623	aTab[4,17] := 2,06978	aTab[5,17] := 2,33535	aTab[6,17] := 2,54274	aTab[7,17] := 2,7119	aTab[8,17] := 2,85413	aTab[9,17] := 2,97649	aTab[10,17] := 3,08358	aTab[11,17] := 3,17861	aTab[12,17] := 3,26393	aTab[13,17] := 3,34121	aTab[14,17] := 3,41178	aTab[15,17] := 3,47677	aTab[16,17] := 3,53666	aTab[17,17] := 3,59242	aTab[18,17] := 3,64447	aTab[19,17] := 3,69325	aTab[20,17] := 3,73913
18	aTab[2,18] := 1,14613	aTab[3,18] := 1,70547	aTab[4,18] := 2,06917	aTab[5,18] := 2,33483	aTab[6,18] := 2,54228	aTab[7,18] := 2,71148	aTab[8,18] := 2,85375	aTab[9,18] := 2,97613	aTab[10,18] := 3,08324	aTab[11,18] := 3,17829	aTab[12,18] := 3,26362	aTab[13,18] := 3,34092	aTab[14,18] := 3,4115	aTab[15,18] := 3,4765	aTab[16,18] := 3,5364	aTab[17,18] := 3,59216	aTab[18,18] := 3,64422	aTab[19,18] := 3,69301	aTab[20,18] := 3,7389
19	aTab[2,19] := 1,1452	aTab[3,19] := 1,7048	aTab[4,19] := 2,06862	aTab[5,19] := 2,33436	aTab[6,19] := 2,54187	aTab[7,19] := 2,71111	aTab[8,19] := 2,85341	aTab[9,19] := 2,97581	aTab[10,19] := 3,08294	aTab[11,19] := 3,17801	aTab[12,19] := 3,26335	aTab[13,19] := 3,34066	aTab[14,19] := 3,41125	aTab[15,19] := 3,47626	aTab[16,19] := 3,53617	aTab[17,19] := 3,59194	aTab[18,19] := 3,644	aTab[19,19] := 3,6928	aTab[20,19] := 3,73869
20	aTab[2,20] := 1,14437	aTab[3,20] := 1,70419	aTab[4,20] := 2,06813	aTab[5,20] := 2,33394	aTab[6,20] := 2,54149	aTab[7,20] := 2,71077	aTab[8,20] := 2,8531	aTab[9,20] := 2,97552	aTab[10,20] := 3,08267	aTab[11,20] := 3,17775	aTab[12,20] := 3,26311	aTab[13,20] := 3,34042	aTab[14,20] := 3,41103	aTab[15,20] := 3,47605	aTab[16,20] := 3,53596	aTab[17,20] := 3,59174	aTab[18,20] := 3,6438	aTab[19,20] := 3,6926	aTab[20,20] := 3,7385
X	aTab[2,21] := 1,12838	aTab[3,21] := 1,69257	aTab[4,21] := 2,05875	aTab[5,21] := 2,32593	aTab[6,21] := 2,53441	aTab[7,21] := 2,70436	aTab[8,21] := 2,8472	aTab[9,21] := 2,97003	aTab[10,21] := 3,07751	aTab[11,21] := 3,17287	aTab[12,21] := 3,25846	aTab[13,21] := 3,33598	aTab[14,21] := 3,40676	aTab[15,21] := 3,47193	aTab[16,21] := 3,53198	aTab[17,21] := 3,58788	aTab[18,21] := 3,64006	aTab[19,21] := 3,68896	aTab[20,21] := 3,735
*/
If aTbv[1,1] == Nil
   aTbv[1,1] := 1    // Caso não tenha atbv garante ter 1 para não acontecer divisão por zero.
   aTbv[1,21] := 1  
Endif 
If aTab[1,1] == Nil  // Idem 
   aTab[1,1] := 1
   aTab[1,21] := 1   
EndIf


If aTab[2,1] == Nil
	atab[2,1] := 1		;	atab[3,1] := 2		;atab[4,1] := 2.9   	;atab[5,1] := 3.8   	;atab[6,1] := 4.7    	;atab[7,1] := 5.5		;atab[8,1] := 6.3    	;atab[9,1] := 7		  	;atab[10,1] := 7.7			;atab[11,1] := 8.3		;atab[12,1] := 9		;atab[13,1] := 9.6		;atab[14,1] := 10.2    	;atab[15,1] := 10.8        	;atab[16,1] := 11.3		   	;atab[17,1] := 11.9		    ;atab[18,1] := 12.4			;atab[19,1] := 12.9			;atab[20,1] := 13.4
	atab[2,2] := 1.9	;	atab[3,2] := 3.8   ;atab[4,2] := 5.7      	;atab[5,2] := 7.5      	;atab[6,2] := 9.2    	;atab[7,2] := 10.8     	;atab[8,2] := 12.3     	;atab[9,2] := 13.8    	;atab[10,2] := 15.1        	;atab[11,2] := 16.5    	;atab[12,2] := 17.8    	;atab[13,2] := 19      	;atab[14,2] := 20.2    	;atab[15,2] := 21.3        	;atab[16,2] := 22.4        	;atab[17,2] := 23.5        	;atab[18,2] := 24.5        	;atab[19,2] := 25.5        	;atab[20,2] := 26.5
	atab[2,3] := 2.8	;	atab[3,3] := 5.7   ;atab[4,3] := 8.4      	;atab[5,3] := 11.1     	;atab[6,3] := 13.6   	;atab[7,3] := 16	    ;atab[8,3] := 18.3     	;atab[9,3] := 20.5    	;atab[10,3] := 22.6        	;atab[11,3] := 24.6    	;atab[12,3] := 26.5    	;atab[13,3] := 28.4    	;atab[14,3] := 30.1    	;atab[15,3] := 31.9       	;atab[16,3] := 33.5        	;atab[17,3] := 35.1        	;atab[18,3] := 36.7        	;atab[19,3] := 38.2        	;atab[20,3] := 39.7
	atab[2,4] := 3.7	;	atab[3,4] := 7.5   ;atab[4,4] := 11.2     	;atab[5,4] := 14.7     	;atab[6,4] := 18.1   	;atab[7,4] := 21.3	    ;atab[8,4] := 24.4    	;atab[9,4] := 27.3    	;atab[10,4] := 30.1        	;atab[11,4] := 32.7    	;atab[12,4] := 35.3    	;atab[13,4] := 37.7    	;atab[14,4] := 40.1    	;atab[15,4] := 42.4        	;atab[16,4] := 44.6        	;atab[17,4] := 46.7        	;atab[18,4] := 48.8        	;atab[19,4] := 50.8        	;atab[20,4] := 52.8
	atab[2,5] := 4.6	;	atab[3,5] := 9.3   ;atab[4,5] := 13.9     	;atab[5,5] := 18.4    	;atab[6,5] := 22.6    	;atab[7,5] := 26.6     	;atab[8,5] := 30.4     	;atab[9,5] := 34      	;atab[10,5] := 27.5        	;atab[11,5] := 40.8    	;atab[12,5] := 44      	;atab[13,5] := 47.1    	;atab[14,5] := 50.1    	;atab[15,5] := 52.9        	;atab[16,5] := 55.7        	;atab[17,5] := 58.4        	;atab[18,5] := 61          	;atab[19,5] := 63.5        	;atab[20,5] := 65.9
	atab[2,6] := 5.5	;	atab[3,6] := 11.1  ;atab[4,6] := 16.7     	;atab[5,6] := 22      	;atab[6,6] := 27      	;atab[7,6] := 31.8     	;atab[8,6] := 36.4     	;atab[9,6] := 40.8     	;atab[10,6] := 45          	;atab[11,6] := 49      	;atab[12,6] := 52.8    	;atab[13,6] := 56.5    	;atab[14,6] := 60.1    	;atab[15,6] := 63.5        	;atab[16,6] := 66.8        	;atab[17,6] := 70          	;atab[18,6] := 73.1        	;atab[19,6] := 76.1        	;atab[20,6] := 79.1
	atab[2,7] := 6.4	;	atab[3,7] := 12.9  ;atab[4,7] := 19.4     	;atab[5,7] := 25.6     	;atab[6,7] := 31.5    	;atab[7,7] := 37.1     	;atab[8,7] := 42.5     	;atab[9,7] := 47.6     	;atab[10,7] := 52.4	        ;atab[11,7] := 57.1    	;atab[12,7] := 61.6    	;atab[13,7] := 65.9    	;atab[14,7] := 70      	;atab[15,7] := 74          	;atab[16,7] := 77.9        	;atab[17,7] := 81.6        	;atab[18,7] := 85.3        	;atab[19,7] := 88.8        	;atab[20,7] := 92.2
	atab[2,8] := 7.2	;	atab[3,8] := 14.8  ;atab[4,8] := 22.1     	;atab[5,8] := 29.2     	;atab[6,8] := 36       	;atab[7,8] := 42.4     	;atab[8,8] := 48.5     	;atab[9,8] := 54.3     	;atab[10,8] := 59.9        	;atab[11,8] := 65.2    	;atab[12,8] := 70.3    	;atab[13,8] := 75.2    	;atab[14,8] := 80      	;atab[15,8] := 84.6        	;atab[16,8] := 89          	;atab[17,8] := 93.3        	;atab[18,8] := 97.4        	;atab[19,8] := 101.4       	;atab[20,8] := 105.3
	atab[2,9] := 8.1	;	atab[3,9] := 16.6  ;atab[4,9] := 24.9     	;atab[5,9] := 32.9     	;atab[6,9] := 40.4     	;atab[7,9] := 47.7     	;atab[8,9] := 54.5     	;atab[9,9] := 61.1     	;atab[10,9] := 67.3        	;atab[11,9] := 73.3    	;atab[12,9] := 79.1    	;atab[13,9] := 84.6    	;atab[14,9] := 90      	;atab[15,9] := 95.1        	;atab[16,9] := 100.1       	;atab[17,9] := 104.9       	;atab[18,9] := 109.5       	;atab[19,9] := 114.1       	;atab[20,9] := 118.5
	atab[2,10] := 9		;	atab[3,10] := 18.4 ;atab[4,10] := 27.6	   	;atab[5,10] := 36.5    	;atab[6,10] := 44.9    	;atab[7,10] := 52.9    	;atab[8,10] := 60.6    	;atab[9,10] := 67.8    	;atab[10,10] := 74.8       	;atab[11,10] := 81.5   	;atab[12,10] := 87.9   	;atab[13,10] := 94     	;atab[14,10] := 99.9   	;atab[15,10] := 105.6      	;atab[16,10] := 111.2      	;atab[17,10] := 116.5      	;atab[18,10] := 121.7      	;atab[19,10] := 126.7      	;atab[20,10] := 131.6
	atab[2,11] := 9.9	;	atab[3,11] := 20.2 ;atab[4,11] := 30.4   	;atab[5,11] := 40.1    	;atab[6,11] := 49.4    	;atab[7,11] := 58.2    	;atab[8,11] := 66.6    	;atab[9,11] := 74.6    	;atab[10,11] := 82.2       	;atab[11,11] := 89.6   	;atab[12,11] := 96.6   	;atab[13,11] := 103.4  	;atab[14,11] := 109.9  	;atab[15,11] := 116.2      	;atab[16,11] := 122.3      	;atab[17,11] := 128.1      	;atab[18,11] := 133.8      	;atab[19,11] := 139.4      	;atab[20,11] := 144.7
	atab[2,12] := 10.7	;	atab[3,12] := 22   ;atab[4,12] := 33.1   	;atab[5,12] := 43.7    	;atab[6,12] := 53.8    	;atab[7,12] := 63.5    	;atab[8,12] := 72.6    	;atab[9,12] := 81.3    	;atab[10,12] := 89.7       	;atab[11,12] := 97.7   	;atab[12,12] := 105.4  	;atab[13,12] := 112.7  	;atab[14,12] := 119.9  	;atab[15,12] := 126.7      	;atab[16,12] := 133.3      	;atab[17,12] := 139.8      	;atab[18,12] := 146        	;atab[19,12] := 152        	;atab[20,12] := 157.9
	atab[2,13] := 11.6	;	atab[3,13] := 23.8 ;atab[4,13] := 35.8   	;atab[5,13] := 47.3    	;atab[6,13] := 58.3    	;atab[7,13] := 68.7    	;atab[8,13] := 78.6    	;atab[9,13] := 88.1    	;atab[10,13] := 97.1       	;atab[11,13] := 105.8  	;atab[12,13] := 114.1  	;atab[13,13] := 122.1  	;atab[14,13] := 129.8  	;atab[15,13] := 137.3      	;atab[16,13] := 144.4      	;atab[17,13] := 151.4      	;atab[18,13] := 158.1      	;atab[19,13] := 164.7      	;atab[20,13] := 171
	atab[2,14] := 12.5 	;	atab[3,14] := 25.7 ;atab[4,14] := 38.6   	;atab[5,14] := 51      	;atab[6,14] := 62.8    	;atab[7,14] := 74      	;atab[8,14] := 84.7    	;atab[9,14] := 94.9    	;atab[10,14] := 104.6      	;atab[11,14] := 113.9  	;atab[12,14] := 122.9  	;atab[13,14] := 131.5  	;atab[14,14] := 139.8  	;atab[15,14] := 147.8      	;atab[16,14] := 155.5      	;atab[17,14] := 163        	;atab[18,14] := 170.3      	;atab[19,14] := 177.3      	;atab[20,14] := 184.2
	atab[2,15] := 13.4	;	atab[3,15] := 27.5 ;atab[4,15] := 41.3   	;atab[5,15] := 54.6    	;atab[6,15] := 67.2    	;atab[7,15] := 79.3    	;atab[8,15] := 90.7    	;atab[9,15] := 101.6   	;atab[10,15] := 112.1     	;atab[11,15] := 122.1  	;atab[12,15] := 131.7  	;atab[13,15] := 140.9  	;atab[14,15] := 149.8  	;atab[15,15] := 158.3      	;atab[16,15] := 166.6      	;atab[17,15] := 174.6      	;atab[18,15] := 182.4      	;atab[19,15] := 190        	;atab[20,15] := 197.3
	atab[2,16] := 14.3	;	atab[3,16] := 29.3 ;atab[4,16] := 44.1   	;atab[5,16] := 58.2    	;atab[6,16] := 71.7    	;atab[7,16] := 84.5    	;atab[8,16] := 96.7    	;atab[9,16] := 108.4   	;atab[10,16] := 119.5     	;atab[11,16] := 130.2  	;atab[12,16] := 140.4  	;atab[13,16] := 150.2  	;atab[14,16] := 159.7  	;atab[15,16] := 168.9      	;atab[16,16] := 177.7      	;atab[17,16] := 186.3      	;atab[18,16] := 194.6      	;atab[19,16] := 202.6      	;atab[20,16] := 210.4
	atab[2,17] := 15.1	;	atab[3,17] := 31.1 ;atab[4,17] := 46.8   	;atab[5,17] := 61.8    	;atab[6,17] := 76.2    	;atab[7,17] := 89.8    	;atab[8,17] := 102.8   	;atab[9,17] := 115.1   	;atab[10,17] := 127        	;atab[11,17] := 138.3  	;atab[12,17] := 149.2  	;atab[13,17] := 159.6  	;atab[14,17] := 169.7  	;atab[15,17] := 179.4      	;atab[16,17] := 188.8      	;atab[17,17] := 197.9      	;atab[18,17] := 206.7      	;atab[19,17] := 215.2      	;atab[20,17] := 223.6
	atab[2,18] := 16	;	atab[3,18] := 32.9 ;atab[4,18] := 49.5   	;atab[5,18] := 65.5    	;atab[6,18] := 80.6    	;atab[7,18] := 95.1    	;atab[8,18] := 108.8   	;atab[9,18] := 121.9   	;atab[10,18] := 134.4      	;atab[11,18] := 146.4  	;atab[12,18] := 157.9  	;atab[13,18] := 169    	;atab[14,18] := 179.7  	;atab[15,18] := 190        	;atab[16,18] := 199.9      	;atab[17,18] := 209.5      	;atab[18,18] := 218.8      	;atab[19,18] := 227.9      	;atab[20,18] := 236.7
	atab[2,19] := 16.9	;	atab[3,19] := 34.7 ;atab[4,19] := 52.3   	;atab[5,19] := 69.1    	;atab[6,19] := 85.1    	;atab[7,19] := 100.3   	;atab[8,19] := 114.8   	;atab[9,19] := 128.7   	;atab[10,19] := 141.9      	;atab[11,19] := 154.5  	;atab[12,19] := 166.7  	;atab[13,19] := 178.4  	;atab[14,19] := 189.6  	;atab[15,19] := 200.5      	;atab[16,19] := 211        	;atab[17,19] := 221.1      	;atab[18,19] := 231        	;atab[19,19] := 240.5      	;atab[20,19] := 249.8
	atab[2,20] := 17.8 	;	atab[3,20] := 36.5 ;atab[4,20] := 55     	;atab[5,20] := 72.7    	;atab[6,20] := 89.6    	;atab[7,20] := 105.6   	;atab[8,20] := 120.9   	;atab[9,20] := 135.4   ;atab[10,20] := 149.3      	;atab[11,20] := 162.7  	;atab[12,20] := 175.5  	;atab[13,20] := 187.8  	;atab[14,20] := 199.6  	;atab[15,20] := 211        	;atab[16,20] := 222.1      	;atab[17,20] := 232.8      	;atab[18,20] := 243.1      	;atab[19,20] := 253.2      	;atab[20,20] := 263
	atab[2,21] := 0.876	;	atab[3,21] := 1.815;atab[4,21] := 2.7378 	;atab[5,21] := 3.623   	;atab[6,21] := 4.4658	;atab[7,21] := 5.2673  	;atab[8,21] := 6.0305	;atab[9,21] := 6.7582	;atab[10,21] := 7.4539     	;atab[11,21] := 8.1207 	;atab[12,21] := 8.7602 	;atab[13,21] := 9.3751 	;atab[14,21] := 9.9679	;atab[15,21] := 10.5396		;atab[16,21] := 11.0913		;atab[17,21] := 11.6259		;atab[18,21] := 12.144     	;atab[19,21] := 12.6468		;atab[20,21] := 13.1362

	aTbv[2,1] := 1.41421;	aTbv[3,1] := 1.91155;	aTbv[4,1]:= 2.23887;	aTbv[5,1] := 2.48124;	aTbv[6,1] := 2.67253;	aTbv[7,1] := 2.82981;	aTbv[8,1] := 2.96288;	aTbv[9,1] := 3.07794;	aTbv[10,1] := 3.17905;	aTbv[11,1] := 3.26909;		aTbv[12,1] := 3.35016;		aTbv[13,1] := 3.42378;	 aTbv[14,1] := 3.49116;	 	aTbv[15,1] := 3.55333;		aTbv[16,1] := 3.61071;		aTbv[17,1] := 3.66422;	aTbv[18,1] := 3.71424;	aTbv[19,1] := 3.76118;	aTbv[20,1] := 3.80537
	aTbv[2,2] := 1.27931;	aTbv[3,2] := 1.80538;	aTbv[4,2] := 2.15069;	aTbv[5,2] := 2.40484;	aTbv[6,2] := 2.60438;	aTbv[7,2] := 2.76779;	aTbv[8,2] := 2.90562;	aTbv[9,2] := 3.02446;	aTbv[10,2] := 3.12869;	aTbv[11,2] := 3.22134;		aTbv[12,2] := 3.30463;		aTbv[13,2] := 3.38017;	 aTbv[14,2] := 3.44922;	 	aTbv[15,2] := 3.51287;		aTbv[16,2] := 3.57156;		aTbv[17,2] := 3.62625;	aTbv[18,2] := 3.67734;	aTbv[19,2] := 3.72524;	aTbv[20,2] := 3.77032
	aTbv[2,3] := 1.23105;	aTbv[3,3] := 1.76858;	aTbv[4,3] := 2.12049;	aTbv[5,3] := 2.37883;	aTbv[6,3] := 2.58127;	aTbv[7,3] := 2.74681;	aTbv[8,3] := 2.88628;	aTbv[9,3] := 3.00643;	aTbv[10,3] := 3.11173;	aTbv[11,3] := 3.20526;		aTbv[12,3] := 3.28931;		aTbv[13,3] := 3.3655;	 aTbv[14,3] := 3.43512;	 	aTbv[15,3] := 3.49927;		aTbv[16,3] := 3.55842;		aTbv[17,3] := 3.61351;	aTbv[18,3] := 3.66495;	aTbv[19,3] := 3.71319;	aTbv[20,3] := 3.75857
	aTbv[2,4] := 1.20621;	aTbv[3,4] := 1.74989;	aTbv[4,4] := 2.10522;	aTbv[5,4] := 2.36571;	aTbv[6,4] := 2.56964;	aTbv[7,4] := 2.73626;	aTbv[8,4] := 2.87656;	aTbv[9,4] := 2.99737;	aTbv[10,4] := 3.10321;	aTbv[11,4] := 3.1972;		aTbv[12,4] := 3.28163;		aTbv[13,4] := 3.35815;	 aTbv[14,4] := 3.42805;	 	aTbv[15,4] := 3.49246;		aTbv[16,4] := 3.55183;		aTbv[17,4] := 3.60712;	aTbv[18,4] := 3.65875;	aTbv[19,4] := 3.70715;	aTbv[20,4] := 3.75268
	aTbv[2,5] := 1.19105;	aTbv[3,5] := 1.73857;	aTbv[4,5] := 2.09601;	aTbv[5,5] := 2.35781;	aTbv[6,5] := 2.56263;	aTbv[7,5] := 2.72991;	aTbv[8,5] := 2.87071;	aTbv[9,5] := 2.99192;	aTbv[10,5] := 3.09808;	aTbv[11,5] := 3.19235;		aTbv[12,5] := 3.27701;		aTbv[13,5] := 3.35372;	 aTbv[14,5] := 3.42381;	 	aTbv[15,5] := 3.48836;		aTbv[16,5] := 3.54787;		aTbv[17,5] := 3.60328;	aTbv[18,5] := 3.65502;	aTbv[19,5] := 3.70352;	aTbv[20,5] := 3.74914
	aTbv[2,6] := 1.18083;	aTbv[3,6] := 1.73099;	aTbv[4,6] := 2.08985;	aTbv[5,6] := 2.35253;	aTbv[6,6] := 2.55795;	aTbv[7,6] := 2.72567;	aTbv[8,6] := 2.8668	;	aTbv[9,6] := 2.98829;	aTbv[10,6] := 3.09467;	aTbv[11,6] := 3.18911;		aTbv[12,6] := 3.27392;		aTbv[13,6] := 3.35077;	 aTbv[14,6] := 3.42097;	 	aTbv[15,6] := 3.48563;		aTbv[16,6] := 3.54522;		aTbv[17,6] := 3.60072;	aTbv[18,6] := 3.65253;	aTbv[19,6] := 3.70109;	aTbv[20,6] := 3.74678
	aTbv[2,7] := 1.17348;	aTbv[3,7] := 1.72555;	aTbv[4,7] := 2.08543 ;	aTbv[5,7] := 2.34875;	aTbv[6,7] := 2.5546	;	aTbv[7,7] := 2.72263;	aTbv[8,7] := 2.86401;	aTbv[9,7] := 2.98568;	aTbv[10,7] := 3.09222;	aTbv[11,7] := 3.18679;		aTbv[12,7] := 3.27172;		aTbv[13,7] := 3.34866;	 aTbv[14,7] := 3.41894;	 	aTbv[15,7] := 3.48368;		aTbv[16,7] := 3.54333;		aTbv[17,7] := 3.59888;	aTbv[18,7] := 3.65075;	aTbv[19,7] := 3.69936;	aTbv[20,7] := 3.74509
	aTbv[2,8] := 1.16794;	aTbv[3,8] := 1.72147;	aTbv[4,8] := 2.08212 ;	aTbv[5,8] := 2.34591;	aTbv[6,8] := 2.55208;	aTbv[7,8] := 2.72036;	aTbv[8,8] := 2.86192;	aTbv[9,8] := 2.98373;	aTbv[10,8] := 3.09039;	aTbv[11,8] := 3.18506;		aTbv[12,8] := 3.27006;		aTbv[13,8] := 3.34708;	 aTbv[14,8] := 3.41742;	 	aTbv[15,8] := 3.48221;		aTbv[16,8] := 3.54192;		aTbv[17,8] := 3.59751;	aTbv[18,8] := 3.64941;	aTbv[19,8] := 3.69806;	aTbv[20,8] := 3.74382
	aTbv[2,9] := 1.16361;	aTbv[3,9] := 1.71828;	aTbv[4,9] := 2.07953 ;	aTbv[5,9] := 2.3437	;	aTbv[6,9] := 2.55013;	aTbv[7,9] := 2.71858;	aTbv[8,9] := 2.86028;	aTbv[9,9] := 2.98221;	aTbv[10,9] := 3.08896;	aTbv[11,9] := 3.1837;		aTbv[12,9] := 3.26878;		aTbv[13,9] := 3.34585;	 aTbv[14,9] := 3.41624;	 	aTbv[15,9] := 3.48107;		aTbv[16,9] := 3.54081; 		aTbv[17,9] := 3.59644;	aTbv[18,9] := 3.64838;	aTbv[19,9] := 3.69705;	aTbv[20,9] := 3.74284
	aTbv[2,10] := 1.16014;	aTbv[3,10] := 1.71573;	aTbv[4,10] := 2.07746;	aTbv[5,10] := 2.34192;	aTbv[6,10] := 2.54856;	aTbv[7,10] := 2.71717;	aTbv[8,10] := 2.85898;	aTbv[9,10] := 2.981	;	aTbv[10,10] := 3.08781;	aTbv[11,10] := 3.18262;		aTbv[12,10] := 3.26775;		aTbv[13,10] := 3.34486;	 aTbv[14,10] := 3.41529; 	aTbv[15,10] := 3.48016;		aTbv[16,10] := 3.53993;		aTbv[17,10] := 3.59559;	aTbv[18,10] := 3.64755;	aTbv[19,10] := 3.69625;	aTbv[20,10] := 3.742050
	aTbv[2,11] := 1.15729;	aTbv[3,11] := 1.71363;	aTbv[4,11] := 2.07577;	aTbv[5,11] := 2.34048;	aTbv[6,11] := 2.54728;	aTbv[7,11] := 2.716	;	aTbv[8,11] := 2.85791;	aTbv[9,11] := 2.98;		aTbv[10,11] := 3.08688;	aTbv[11,11] := 3.18174;		aTbv[12,11] := 3.2669;		aTbv[13,11] := 3.34406;	 aTbv[14,11] := 3.41452	; 	aTbv[15,11] := 3.47941;		aTbv[16,11] := 3.53921;		aTbv[17,11] := 3.59489;	aTbv[18,11] := 3.64687;	aTbv[19,11] := 3.69558;	aTbv[20,11] := 3.74141
	aTbv[2,12] := 1.1549;	aTbv[3,12] := 1.71189;	aTbv[4,12] := 2.07436;	aTbv[5,12] := 2.33927;	aTbv[6,12] := 2.54621;	aTbv[7,12] := 2.71504;	aTbv[8,12] := 2.85702;	aTbv[9,12] := 2.97917;	aTbv[10,12] := 3.0861;	aTbv[11,12] := 3.181;		aTbv[12,12] := 3.2662;		aTbv[13,12] := 3.34339;	 aTbv[14,12] := 3.41387	; 	aTbv[15,12] := 3.47879;		aTbv[16,12] := 3.53861;		aTbv[17,12] := 3.5943;	aTbv[18,12] := 3.6463;	aTbv[19,12] := 3.69503;	aTbv[20,12] := 3.74087
	aTbv[2,13] := 1.15289;	aTbv[3,13] := 1.71041;	aTbv[4,13] := 2.07316;	aTbv[5,13] := 2.33824;	aTbv[6,13] := 2.5453;	aTbv[7,13] := 2.71422;	aTbv[8,13] := 2.85627;	aTbv[9,13] := 2.97847;	aTbv[10,13] := 3.08544;	aTbv[11,13] := 3.18037;		aTbv[12,13] := 3.26561;	 	aTbv[13,13] := 3.34282; aTbv[14,13] := 3.41333; 	aTbv[15,13] := 3.47826; 	aTbv[16,13] := 3.5381;		aTbv[17,13] := 3.59381;	aTbv[18,13] := 3.64582;	aTbv[19,13] := 3.69457;	aTbv[20,13] := 3.74041                                                                                                                                                                                                                                                                                               
	aTbv[2,14] := 1.15115;	aTbv[3,14] := 1.70914;	aTbv[4,14] := 2.07213;	aTbv[5,14] := 2.33737;	aTbv[6,14] := 2.54452;	aTbv[7,14] := 2.71351;	aTbv[8,14] := 2.85562;	aTbv[9,14] := 2.97787;	aTbv[10,14] := 3.08487;	aTbv[11,14] := 3.17984;		aTbv[12,14] := 3.2651;	 	aTbv[13,14] := 3.34233; aTbv[14,14] := 3.41286; 	aTbv[15,14] := 3.47781;	 	aTbv[16,14] := 3.53766;		aTbv[17,14] := 3.59339;	aTbv[18,14] := 3.64541;	aTbv[19,14] := 3.69417;	aTbv[20,14] := 3.740027
	aTbv[2,15] := 1.14965;	aTbv[3,15] := 1.70804;	aTbv[4,15] := 2.07125;	aTbv[5,15] := 2.33661;	aTbv[6,15] := 2.54385;	aTbv[7,15] := 2.7129;	aTbv[8,15] := 2.85506;	aTbv[9,15] := 2.97735;	aTbv[10,15] := 3.08438;	aTbv[11,15] := 3.17938;		aTbv[12,15] := 3.26465;	 	aTbv[13,15] := 3.34191; aTbv[14,15] := 3.41245; 	aTbv[15,15] := 3.47742;	 	aTbv[16,15] := 3.53728;		aTbv[17,15] := 3.59302;	aTbv[18,15] := 3.64505;	aTbv[19,15] := 3.69382;	aTbv[20,15] := 3.77969
	aTbv[2,16] := 1.14833;	aTbv[3,16] := 1.70708;	aTbv[4,16] := 2.07047;	aTbv[5,16] := 2.33594;	aTbv[6,16] := 2.54326;	aTbv[7,16] := 2.71237;	aTbv[8,16] := 2.85457;	aTbv[9,16] := 2.97689;	aTbv[10,16] := 3.08395;	aTbv[11,16] := 3.17897;		aTbv[12,16] := 3.26427;	 	aTbv[13,16] := 3.34154	; aTbv[14,16] := 3.4121	;	aTbv[15,16] := 3.47707; 	aTbv[16,16] := 3.53695;		aTbv[17,16] := 3.5927;	aTbv[18,16] := 3.64474;	aTbv[19,16] := 3.69351;	aTbv[20,16] := 3.73939
	aTbv[2,17] := 1.14717;	aTbv[3,17] := 1.70623;	aTbv[4,17] := 2.06978;	aTbv[5,17] := 2.33535;	aTbv[6,17] := 2.54274;	aTbv[7,17] := 2.7119;	aTbv[8,17] := 2.85413;	aTbv[9,17] := 2.97649;	aTbv[10,17] := 3.08358;	aTbv[11,17] := 3.17861;		aTbv[12,17] := 3.26393;	 	aTbv[13,17] := 3.34121	; aTbv[14,17] := 3.41178; 	aTbv[15,17] := 3.47677;	 	aTbv[16,17] := 3.53666;		aTbv[17,17] := 3.59242;	aTbv[18,17] := 3.64447;	aTbv[19,17] := 3.69325;	aTbv[20,17] := 3.73913
	aTbv[2,18] := 1.14613;	aTbv[3,18] := 1.70547;	aTbv[4,18] := 2.06917;	aTbv[5,18] := 2.33483;	aTbv[6,18] := 2.54228;	aTbv[7,18] := 2.71148;	aTbv[8,18] := 2.85375;	aTbv[9,18] := 2.97613;	aTbv[10,18] := 3.08324;	aTbv[11,18] := 3.17829;		aTbv[12,18] := 3.26362;	 	aTbv[13,18] := 3.34092	; aTbv[14,18] := 3.4115	;	aTbv[15,18] := 3.4765; 		aTbv[16,18] := 3.5364;		aTbv[17,18] := 3.59216;	aTbv[18,18] := 3.64422;	aTbv[19,18] := 3.69301;	aTbv[20,18] := 3.7389
	aTbv[2,19] := 1.1452;	aTbv[3,19] := 1.7048 ;	aTbv[4,19] := 2.06862;	aTbv[5,19] := 2.33436;	aTbv[6,19] := 2.54187;	aTbv[7,19] := 2.71111;	aTbv[8,19] := 2.85341;	aTbv[9,19] := 2.97581;	aTbv[10,19] := 3.08294;	aTbv[11,19] := 3.17801;		aTbv[12,19] := 3.26335;	 	aTbv[13,19] := 3.34066	; aTbv[14,19] := 3.41125; 	aTbv[15,19] := 3.47626;	 	aTbv[16,19] := 3.53617;		aTbv[17,19] := 3.59194;	aTbv[18,19] := 3.644;	aTbv[19,19] := 3.6928;	aTbv[20,19] := 3.73869
	aTbv[2,20] := 1.14437;	aTbv[3,20] := 1.70419;	aTbv[4,20] := 2.06813;	aTbv[5,20] := 2.33394;	aTbv[6,20] := 2.54149;	aTbv[7,20] := 2.71077;	aTbv[8,20] := 2.8531;	aTbv[9,20] := 2.97552;	aTbv[10,20] := 3.08267;	aTbv[11,20] := 3.17775;		aTbv[12,20] := 3.26311;	 	aTbv[13,20] := 3.34042	; aTbv[14,20] := 3.41103; 	aTbv[15,20] := 3.47605;	 	aTbv[16,20] := 3.53596;		aTbv[17,20] := 3.59174;	aTbv[18,20] := 3.6438;	aTbv[19,20] := 3.6926;	aTbv[20,20] := 3.7385
	aTbv[2,21] := 1.12838;	aTbv[3,21] := 1.69257;	aTbv[4,21] := 2.05875;	aTbv[5,21] := 2.32593;	aTbv[6,21] := 2.53441;	aTbv[7,21] := 2.70436;	aTbv[8,21] := 2.8472;	aTbv[9,21] := 2.97003;	aTbv[10,21] := 3.07751;	aTbv[11,21] := 3.17287;		aTbv[12,21] := 3.25846; 	aTbv[13,21] := 3.33598	; aTbv[14,21] := 3.40676; 	aTbv[15,21] := 3.47193; 	aTbv[16,21] := 3.53198;		aTbv[17,21] := 3.58788;	aTbv[18,21] := 3.64006;	aTbv[19,21] := 3.68896;	aTbv[20,21] := 3.735
Endif

Return Nil 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Qm010MSA  ºAutor  ³Denis Martins       º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Caso exista o campo identificador de MSA 2 / 3 Edicao acertaº±±
±±º          ³o arquivo...                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTC010                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qm010MSA()

dbSelectArea("QMU")
dbSetOrder(1)
While QMU->(!Eof())
	//Caso seja espaco/branco gravar como segunda edicao do MSA...
	If Empty(QMU->QMU_TPMSA)
		RecLock("QMU",.F.)
		Replace QMU->QMU_TPMSA With "1"
		MsUnlock()
	Endif
	dbSkip()
Enddo 

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QM010IntL ºAutor  ³ Cicero Cruz        º Data ³ 03/08/05    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Descobre atraves da formula de Interpolacao Linear o       º±±
±±º          ³ Valor bi-Caudal de um  valor x quebrado                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTC010                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QM010IntL(nVal,nTol,nDec)
Local nRes:=0
Local nValS := 0
Local nValI := 0 
Local nValSTS := 0
Local nValITS := 0 
Local nDetA0 := 0 
Local nDetA1 := 0          
Local cTbrAm := " "
// Divido a Erro padrão da Media por 2
cTbrAm:=StrTran(str(round((nTol/100)/2,nDec)),".",",")

// Obtenho o valor inteiro (Inferior e Superior)do numero que  quero  Calcular 
nValI := SuperVal(Alltrim(Str(iif(round(nVal,0)  >nVal   ,round(nVal-1 ,0),round(nVal,0)  ))))
nValS := SuperVal(Alltrim(Str(iif(round(nVal,0)+1>nVal+1 ,round(nVal   ,0),round(nVal,0)+1))))

// Calculo do Valor T-Student dos nuemros inteiros imediatamente (Inferior e Superior)do numero que  quero  Calcular 
IF !lExistChart
	nValITS  := CallDll32("STUDENTINV",cTbrAm+";"+StrTran(Str(nValI),".",",")) // Guardo o Valor Inteiro Inferior
	nValSTS  := CallDll32("STUDENTINV",cTbrAm+";"+StrTran(Str(nValS),".",",")) // Guardo o Valor Inteiro Superior
ELSE
	nValITS  := QLDSTDINV(SuperVal(cTbrAm), nValI)
	nValSTS  := QLDSTDINV(SuperVal(cTbrAm), nValS)
ENDIF

nValITS  := round(SuperVal(nValITS),nDec)
nValSTS  := round(SuperVal(nValSTS),nDec)

/*
|1	x1|	X |a0| = y1
|1	x2|	  |a1| = y2

|1	nValI|	X |a0| = nValITS
|1	nValS|	  |a1| = nValSTS  
                              
Para cTbrAm = '0,027' e nVal = 10,8

|1	10|	X |a0| = 2,183
|1	11|	  |a1| = 2,157

Para solucao  usa-se a Regra de Crammer

|1	nValI|
|1	nValS|  

Determinante Prin = (1*nValS) - (1*nValI) = nDetDP

|1	10|	
|1	11|

Determinate Prin = (1*11) - (1*10) = 1

|nValITS nValI|
|nValSTS nValS|

Determinante Auxiliar 0 = (nValITS*nValS) - (nValSTS*nValI) = nDetA0 

|2,183	10|  
|2,157	11|

Determinante Auxiliar 0 = (2,183*11) - (2,157*10) = 2,4417

*/

nDetA0 := (nValITS*nValS) - (nValSTS*nValI)

/*

|1  nValITS|
|1  nValSTS|

Determinante Auxiliar 0 = (1*nValSTS) - (1*nValITS) = nDetA1 

|1  2,183|  
|1  2,157|

Determinante Auxiliar 0 = (1*2,157) - (1*2,183) = -0,0259

*/

nDetA1 := (1*nValSTS) - (1*nValITS)  

/*/
nRes   := nDetA0 + (nDetA1 * nVal)
/*/

nRes   := nDetA0 + (nDetA1 * nVal)

Return nRes

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Q010MSA3  ºAutor  ³Denis Martins       º Data ³  08/25/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica obrigatoriedade de digitacao das perguntas para    º±±
±±º          ³MSA 3a Edicao                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTC010                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q010MSA3(lEstd)
Local lRet        := .T.
Local lExistChart := FindFunction("QIEMGRAFIC") .AND. GetBuild() >= "7.00.170117A" //controle se executa o grafico modelo novo ou por DLL
Default lEstd     := .T.

If lEstd
	If mv_par06 == 1
		mv_par07 := 2   
		mv_par08 := 2	 
		mv_par09 := 0
	Endif
Else
	If mv_par07 == 1
		mv_par08 := 2
		mv_par09 := 0	 
		mv_par10 := 2 
		mv_par11 := 0 
	Endif	
Endif

If lExistChart
	IF IsInCallStack("QMTC010")
		If mv_par06 <> 3 .AND. READVAR() $ "MV_PAR06" //Estudo MSA ?
			Help(NIL, NIL, "Estudo MSA", NIL, "Opção não disponível.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"O gráfico está disponível apenas para o Estudo Msa 4ª edição"})
			Return .F.
		EndIf

		If mv_par07 <> 2 .AND. READVAR() $ "MV_PAR07" //Imprime Grafico ?
			Help(NIL, NIL, "Imprime Gráfico", NIL, "Opção não disponível.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Selecione uma opção disponível."})
			Return .F.
		EndIf
	ELSE
		If mv_par07 <> 3 .AND. READVAR() $ "MV_PAR07" //Estudo MSA ?
			Help(NIL, NIL, "Estudo MSA", NIL, "Opção não disponível.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"O gráfico está disponível apenas para o Estudo Msa 4ª edição"})
			Return .F.
		EndIf
		If mv_par08 <> 2 .AND. READVAR() $ "MV_PAR08" //Imprime Grafico ?
			Help(NIL, NIL, "Imprime Gráfico", NIL, "Opção não disponível.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Selecione uma opção disponível."})
			Return .F.
		EndIf
	ENDIF
EndIf

Return .T.