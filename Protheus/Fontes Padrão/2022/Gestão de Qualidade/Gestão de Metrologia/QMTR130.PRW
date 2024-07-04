#INCLUDE "QMTR130.CH"
#INCLUDE "PROTHEUS.CH"
#include "report.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QMTR130  ³ Autor ³ Cicero Cruz           ³ Data ³ 13.06.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio de Disponibilidade de Instumentos                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QMTR130(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QMTR130()
Local oReport

If TRepInUse()
	// Interface de impressao
	oReport := ReportDef()
 	oReport:PrintDialog()
Else
	QMTR130R3()
EndIf

Return
         
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³ Cicero Cruz           ³ Data ³ 06/06/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QMTR130                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef()
Local oReport 
Local oSection1
Local aOrdem    := {}

Private cPerg		:="QMR130"

DEFINE REPORT oReport NAME "QMTR130" TITLE STR0005 PARAMETER cPerg ACTION {|oReport| ReportPrint(oReport)} DESCRIPTION STR0001+STR0002

aOrdem := {}

DEFINE SECTION oSection OF oReport TABLES "QM2","QM6" Title OemToAnsi(STR0025) //Disponibilidade de Instrumentos

DEFINE CELL NAME "QM2_TIPO"  OF oSection ALIAS "QM2" SIZE 20
DEFINE CELL NAME "QM2_INSTR" OF oSection ALIAS "QM2" SIZE 20
DEFINE CELL NAME "QM2_DEPTO" OF oSection ALIAS "QM2" SIZE 15
DEFINE CELL NAME "QM2_FABR"  OF oSection ALIAS "QM2" SIZE 15          
DEFINE CELL NAME "MES1"      OF oSection TITLE "-----" SIZE 17
DEFINE CELL NAME "MES2"      OF oSection TITLE "-----" SIZE 17
DEFINE CELL NAME "MES3"      OF oSection TITLE "-----" SIZE 17            

DEFINE SECTION oTotal OF oReport Title OemtoAnsi(STR0026) //"Totalizar Mensal"
oTotal:SetHeaderSection()                                    
DEFINE CELL NAME "TEXTO"       OF oTotal SIZE 83 Title OemtoAnsi(STR0028) // Medias
DEFINE CELL NAME "TOTAL1"      OF oTotal SIZE 18 Title OemtoAnsi(STR0029) //"Tot.Mes 1"
DEFINE CELL NAME "TOTAL2"      OF oTotal SIZE 21 Title OemtoAnsi(STR0030) //"Tot.Mes 2"
DEFINE CELL NAME "TOTAL3"      OF oTotal SIZE 18 Title OemtoAnsi(STR0031) //"Tot.Mes 3"

DEFINE SECTION oTotal2 OF oReport TITLE OemtoAnsi(STR0027) //"Totalizador Trimestral"
oTotal2:SetHeaderSection()                                    
DEFINE CELL NAME "TEXTO"       OF oTotal2 SIZE 134 Title OemtoAnsi(STR0028) // Medias
DEFINE CELL NAME "TOTAL1"      OF oTotal2 SIZE 48  Title OemtoAnsi(STR0032) //"Tot.Trimestral" 

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrin³ Autor ³Cicero Cruz            ³ Data ³ 06/06/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ A funcao estatica ReportDef devera ser criada para todos os³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1: Objeto Report do Relatorio                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QMTR130                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportPrint(oReport)
Local aMeses	:= {STR0009,STR0010,STR0011,STR0012,STR0013,STR0014,; // "Jan"###"Fev"###"Mar"###"Abr"###"Mai"###"Jun"
STR0015,STR0016,STR0017,STR0018,STR0019,STR0020 } // "Jul"###"Ago"###"Set"###"Out"###"Nov"###"Dez"
Local oSection1 := oReport:Section(1)
Local oTotal    := oReport:Section(2)
Local oTotal2   := oReport:Section(3)
Local cPerg		:= "QMR130"
Local cAliasQM2 := "QM2"       
Local nCntFor   := 0
Local aCab1     := {}  
Local nTotPrev  := { 0, 0, 0}
Local nTotPar   := { 0, 0, 0}
Local nTotAcum  := 0
Local nMes      := 0
Local nAno      := 0
Local cVar		:= ""
Local cChave	:= ""
Local lImp2		:= .F.
Pergunte(cPerg,.F.)  

R130Cab1(aCab1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Transforma parametros Range em expressao SQL                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MakeSqlExpr(oReport:uParam) 


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query do relatório da secao 1                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1:BeginQuery()	

cAliasQM2 := GetNextAlias()

cChave := "%QM2_FILIAL, QM2_INSTR%"

BeginSql Alias cAliasQM2                   

SELECT QM2.QM2_FILIAL, QM2.QM2_INSTR,  QM2.QM2_REVINS, QM2.QM2_STATUS, QM2.QM2_TIPO,   QM2.QM2_DEPTO,
	   QM2.QM2_FABR,   QM2.QM2_RESP,   QM2.QM2_NHORDI
 	FROM %table:QM2% QM2 	
	WHERE QM2.QM2_FILIAL = %xFilial:QM2% AND 
		  QM2.QM2_INSTR BETWEEN %Exp:mv_par01% AND %Exp:mv_par02% AND
	      QM2.QM2_DEPTO BETWEEN %Exp:mv_par04% AND %Exp:mv_par05% AND         
	      QM2.QM2_TIPO  BETWEEN %Exp:mv_par11% AND %Exp:mv_par12% AND
	      QM2.QM2_FABR  BETWEEN %Exp:mv_par13% AND %Exp:mv_par14% AND
	      QM2.QM2_RESP  BETWEEN %Exp:mv_par15% AND %Exp:mv_par16% AND
	      QM2.QM2_FLAG  = '1' AND
	      QM2.%notDel%		                
 		ORDER BY %Exp:cChave%	
EndSql   
oSection1:EndQuery()

While !&(cAliasQM2)->(Eof())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se status do instrumento esta com atualiza ativo       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !QMTXSTAT(&(cAliasQM2+"->QM2_STATUS"))
		(cAliasQM2)->(dbSkip())
		loop
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifico O.C. interno e externo                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par06 == 1
		If ! Calibrador(0,mv_par07,mv_par08,mv_par09,mv_par10,&(cAliasQM2+"->QM2_INSTR"),&(cAliasQM2+"->QM2_REVINS"))
			&(cAliasQM2)->(dbSkip())
			Loop
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifico O.C. interno                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par06 == 2
		If ! Calibrador(2,mv_par07,mv_par08,mv_par09,mv_par10,&(cAliasQM2+"->QM2_INSTR"),&(cAliasQM2+"->QM2_REVINS"))
			&(cAliasQM2)->(dbSkip())
			Loop
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifico O.C. externo                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If mv_par06 == 3
		If ! Calibrador(1,mv_par07,mv_par08,mv_par09,mv_par10,&(cAliasQM2+"->QM2_INSTR"),&(cAliasQM2+"->QM2_REVINS"))
			&(cAliasQM2)->(dbSkip())
			Loop
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifico se ha horas previstas cadastradas                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     
	If Val(Substr(QM2_NHORDI,1,2))+Val(Substr(QM2_NHORDI,4,2)) <= 0
		&(cAliasQM2)->(dbSkip())
	   	Loop
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Procura o departamento no QAD - Centro de Custo.             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QAD")
	dbSetOrder(1)
	dbSeek( xFilial("QAD") + &(cAliasQM2+"->QM2_DEPTO") )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Procura a descricao da familia no QM1                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea( "QM1" )
	dbSetOrder( 1 )
	dbSeek( xFilial("QM1") + &(cAliasQM2+"->QM2_TIPO") )
	
	lImp := .F.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializa a matriz para valores num‚ricos ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aResult := array(Len(aCab1))
	For nCntFor := 1	To Len(aResult)
		aResult[nCntFor] := 0
	Next
	
	dbSelectArea("QM6")
	QM6->(DbSetOrder(1))
	If QM6->(DbSeek( xFilial("QM6") + &(cAliasQM2+"->QM2_INSTR") + &(cAliasQM2+"->QM2_REVINS") ))
		DO WHILE &(cAliasQM2+"->QM2_FILIAL")+&(cAliasQM2+"->QM2_INSTR")+&(cAliasQM2+"->QM2_REVINS") == ;
			QM6->QM6_FILIAL+QM6->QM6_INSTR+QM6->QM6_REVINS
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifico se a data corrente ‚ valida  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cChave := Alltrim(Str(Year(QM6->QM6_DATA),4))+Alltrim(Str(Month(QM6->QM6_DATA),4))
			
			For nCntFor := 1 to Len(aCab1)
				If cChave == aCab1[nCntFor]
					aResult[nCntFor] += (Val(Subs(QM6->QM6_TOTHOR,1,2))* 60) + ;
					Val(Subs(QM6->QM6_TOTHOR,4,2))
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ So imprime se houver valores maiores que zero   ³
					//³  para pelo menos um mes do trimestre exibido    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If (Val(Subs(QM6->QM6_TOTHOR,1,2))* 60) + ;
						Val(Subs(QM6->QM6_TOTHOR,4,2)) > 0
						lImp := .T.
						lImp2 := .T.
					EndIf
				EndIf
			Next nCntFor
			QM6->(DbSkip())
		EndDo
		
		If lImp
			oSection1:Init()
			nMes := Month(mv_par03)
			nAno := Year(mv_par03)
			
			dUltDiaMes := CToD("01/" + ;
			StrZero(nMes+1,2) + "/" + ;
			Str(nAno),"DDMMYY" ) - 1
			
			nHoraPrev :=  ( (Val(Substr(&(cAliasQM2+"->QM2_NHORDI"),1,2)) * 60) ;
			+ Val(Substr(&(cAliasQM2+"->QM2_NHORDI"),4,2)) ;
			) *  Day(dUltDiaMes)
			
			nTotPrev[1] +=  nHoraPrev
			nTotPar[1]  +=  aResult[1]
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³  Calcula a porcentagem antes de arredondar nHoraPrev  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nHoraPrev <= 0
				nPerc := 100 - ( ( aResult[1] / 1 ) * 100 )
			Else
				nPerc := 100 - ( ( aResult[1] / nHoraPrev ) * 100 )
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³  Faz o calculo do tempo previsto  em Hora/Minutos   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nMinPrev  := Mod(nHoraPrev,60)
			nHoraPrev := Int(nHoraPrev / 60)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³  Faz o calculo do tempo  parado em minutos        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nMinPar  := Mod(aResult[1], 60)
			nHoraPar := Int(aResult[1]/60)

			cVar := Str(nHoraPrev,3)+":"+StrZero(nMinPrev,2)+" "+Str(nHoraPar,3)+":"+StrZero(nMinPar,2)+" "+StrTran (Str(nPerc,6,2),".",",",1)
			oSection1:Cell("MES1"):cTitle := "-- " + aMeses[nMes] + "/" + Right(Str(nAno),2) + " -----" + CRLF + STR0022
			oSection1:Cell("MES1"):SetValue(cVar)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula o n§ de dias do mes anterior subtraindo   ³
			//³  1 do mes corrente                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Month(mv_par03) - 1 < 1
				nMes := 12
				nAno := Year(mv_par03) - 1
			Else
				nMes := Month(mv_par03) - 1
				nAno := Year(mv_par03)
			EndIf
			
			dUltDiaMes :=    CToD("01/" + ;
			StrZero(nMes+1,2) + "/" + ;
			Str(nAno),"DDMMYY" ) - 1
			
			nHoraPrev :=  ( (Val(Substr(&(cAliasQM2+"->QM2_NHORDI"),1,2)) * 60) ;
			+ Val(Substr(&(cAliasQM2+"->QM2_NHORDI"),4,2)) ;
			) *  Day(dUltDiaMes)
			
			nTotPrev[2] +=  nHoraPrev
			nTotPar[2]  +=  aResult[2]
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³  Calcula a porcentagem antes de arredondar nHoraPrev  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPerc := ( 100 - ( aResult[2] / nHoraPrev ) * 100 )
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³  Faz o calculo do tempo previsto em Hora/Minutos    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nMinPrev  := Mod(nHoraPrev,60)
			nHoraPrev := Int(nHoraPrev / 60)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³  Faz o calculo do tempo parado em Hora/Minutos    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nMinPar  := Mod(aResult[2], 60)
			nHoraPar := Int( aResult[2] / 60 )
			
			cVar := Str(nHoraPrev,3)+":"+StrZero(nMinPrev,2)+" "+Str(nHoraPar,3)+":"+StrZero(nMinPar,2)+" "+StrTran (Str(nPerc,6,2),".",",",1)
			oSection1:Cell("MES2"):cTitle += "-- " + aMeses[nMes] + "/" + Right(Str(nAno),2) + " -----" + CRLF + STR0022
			oSection1:Cell("MES2"):SetValue(cVar)
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula o n§ de dias do penultimo mes subtraindo  ³
			//³  um do mes anterior ao corrente                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Month(mv_par03) - 2 < 1
				nMes := 12
				nAno := Year(mv_par03) - 2
			Else
				nMes := Month(mv_par03) - 2
				nAno := Year(mv_par03)
			EndIf
			
			dUltDiaMes :=     CToD("01/" + ;
			StrZero(nMes+1,2) + "/" + ;
			Str(nAno),"DDMMYY" ) - 1
			
			nHoraPrev :=  ( (Val(Substr(&(cAliasQM2+"->QM2_NHORDI"),1,2)) * 60) ;
			+ Val(Substr(&(cAliasQM2+"->QM2_NHORDI"),4,2)) ;
			) *  Day(dUltDiaMes)
			
			nTotPrev[3] +=  nHoraPrev
			nTotPar[3]  +=  aResult[3]
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³  Calcula a porcentagem antes de arredondar nHoraPrev  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPerc := 100 - ( ( aResult[3] / nHoraPrev ) * 100 )
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³  Faz o calculo do tempo  previsto  em Hora/Minutos  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nMinPrev  := Mod(nHoraPrev,60)
			nHoraPrev := Int(nHoraPrev / 60)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³  Faz o calculo do tempo  parado  em Hora/Minutos  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nMinPar  := Mod(aResult[3], 60)
			nHoraPar := Int( aResult[3] / 60 )
			
			cVar := Str(nHoraPrev,3)+":"+StrZero(nMinPrev,2)+" "+Str(nHoraPar,3)+":"+StrZero(nMinPar,2)+" "+StrTran (Str(nPerc,6,2),".",",",1)
			oSection1:Cell("MES3"):cTitle += "-- " + aMeses[nMes] + "/" + Right(Str(nAno),2) + " -----" + CRLF + STR0022
			oSection1:Cell("MES3"):SetValue(cVar)
			
			lImp := .F.
			aResult := array(Len(aCab1))
			cVar := ""
			oSection1:PrintLine()
		EndIf
	EndIf
	
	&(cAliasQM2)->(dbSkip())
	
EndDo
If lImp2
	oTotal:Init()
	oTotal:Cell("TEXTO"):SetValue(STR0023)
	nPerc :=  100 - ( nTotPar[1] / nTotPrev[1] ) * 100                                                                   
	oTotal:Cell("TOTAL1"):SetValue(StrTran(Str(nPerc,6,2),".",",",1))
	nPerc :=  100 - ( nTotPar[2] / nTotPrev[2] ) * 100
	oTotal:Cell("TOTAL2"):SetValue(StrTran(Str(nPerc,6,2),".",",",1))           
	nPerc :=  100 - ( nTotPar[3] / nTotPrev[3] ) * 100
	oTotal:Cell("TOTAL3"):SetValue(StrTran(Str(nPerc,6,2),".",",",1))
	oTotal:PrintLine()                  
	
	oTotal2:Init()
	oTotal2:Cell("TEXTO"):SetValue(STR0024)
	nTotAcum :=  100 - ( (nTotPar[1] + nTotPar[2] + nTotPar[3]);
	/ (nTotPrev[1] + nTotPrev[2] + nTotPrev[3])  ) * 100                                                          
	oTotal2:Cell("TOTAL1"):SetValue(StrTran(Str(nTotAcum,6,2),".",",",1))
	oTotal2:PrintLine()                  
Endif
Return                                                


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QMTR130R3³ Autor ³ Wanderley Goncalves   ³ Data ³ 23.12.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio de Disponibilidade de Instumentos                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QMTR130R3(void)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QMTR130R3()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cDesc1	:= OemToAnsi( STR0001 ) // "Este programa ir  emitir a rela‡„o de"
Local cDesc2	:= OemToAnsi( STR0002 ) // "disponibilidade de instrumentos."
Local cDesc3	:= ""
Local wnrel
Local lImpLin2	:= .T.
Local cString	:="QM2"

Private titulo
Private cabec1		:= ""
Private cabec2    := ""
Private aReturn	:= { OemToAnsi(STR0003), 1,OemToAnsi(STR0004), 1, 2, 1, "",1 } //"Zebrado"###"Administra‡„o"
Private nomeprog	:="QMTR130"

Private nLastKey	:= 0
Private cPerg		:="QMR130"
Private cTamanho := "M"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                  ³
//³ mv_par01   : Instrumento Inicial                      ³
//³ mv_par02   : Instrumento Final                        ³
//³ mv_par03   : Periodo Inicial                          ³
//³ mv_par04   : Departamento Inicial                     ³
//³ mv_par05   : Departamento Final                       ³
//³ mv_par06   : Orgao Calibrador Todos/Interno/Externo   ³
//³ mv_par07   : Orgao Calibrador interno de              ³
//³ mv_par08   : Orgao Calibrador interno ate             ³
//³ mv_par09   : Orgao Calibrador externo de              ³
//³ mv_par10   : Orgao Calibrador externo ate             ³
//³ mv_par11   : Fam¡lia de                               ³
//³ mv_par12   : Fam¡lia ate                              ³
//³ mv_par13   : Fabricante de                            ³
//³ mv_par14   : Fabricante ate                           ³
//³ mv_par15   : Usu rio de                               ³
//³ mv_par16   : Usu rio ate                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao dos cabecalhos                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
titulo := OemToAnsi( STR0005 ) // "Relatorio de Disponibilidade"
cabec1 := ''
cabec2 := OemToAnsi( STR0006 ) // "FAMILIA          INSTRUMENTO      DEPARTAMENTO     FABRICANTE       PREVIS PARADO   %    PREVIS PARADO    %   PREVIS PARADO   %   "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:="QMTR130"   //Nome Default do relatorio em Disco
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,cTamanho,"",.F.)

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
Endif

RptStatus({|lEnd| MTR130Imp(@lEnd,wnRel,cString,lImpLin2)},Titulo)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MTR130IMP³ Autor ³ Wanderley Goncalves   ³ Data ³ 23.12.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao do relatorio                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MTR130IMP(lEnd,wnRel,cString)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lEnd    - A‡Æo do Codeblock                                ³±±
±±³          ³ wnRel   - T¡tulo do relat¢rio                              ³±±
±±³          ³ cString - Mensagem                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MTR130Imp(lEnd,wnRel,cString,lImpLin2)

Local cbCont
Local cbTxt
Local tamanho		:= "M"
Local nOrder		:= IndexOrd()
Local cAlias		:= Alias()
Local cChave		:= ""
Local aCab1			:= {}
Local nCntFor		:= 0
Local aResult		:= {}
Local lImp 			:= .F.
Local lImp2 	    := .F.
Local nIndice
Local cFiltro
Private cIndice		:= ""

Private TRB_FILIAL	
Private	TRB_INSTR	
Private	TRB_REVINS	
Private	TRB_DEPTO	
Private	TRB_TIPO	
Private	TRB_FABR	
Private	TRB_STATUS	
Private	TRB_RESP	
Private	TRB_NHORDI	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cabec1	:= R130Cab1(aCab1)
cbtxt    := SPACE(10)
cbcont   := 0
li       := 80
m_pag    := 1

SetRegua(RecCount())

dbSelectArea( "QM2" )
dbSetOrder(1)

nTotPrev  := { 0, 0, 0}
nTotPar   := { 0, 0, 0}
nTotAcum  := 0
nMes      := 0
nAno      := 0

cChave := "QM2_FILIAL+QM2_INSTR"	
cFiltro:= "SELECT QM2_FILIAL,QM2_INSTR,QM2_REVINS,QM2_STATUS,QM2_DEPTO,QM2_TIPO,QM2_FABR,QM2_RESP,QM2_NHORDI "		
cFiltro+= "FROM "+RetSqlName("QM2")+" "
cFiltro+= "WHERE "
cFiltro+= "QM2_FILIAL = '"	+xFilial("QM2")+	"' AND "
cFiltro+= "QM2_INSTR	>= '"	+ mv_par01 +	"' AND " 
cFiltro+= "QM2_INSTR	<= '"	+ mv_par02 +	"' AND " 
cFiltro+= "QM2_DEPTO	>= '"	+ mv_par04 +	"' AND " 
cFiltro+= "QM2_DEPTO	<= '"	+ mv_par05 +	"' AND " 
cFiltro+= "QM2_TIPO		>= '"	+ mv_par11 +	"' AND " 
cFiltro+= "QM2_TIPO		<= '"	+ mv_par12 +	"' AND " 
cFiltro+= "QM2_FABR		>= '"	+ mv_par13 +	"' AND " 
cFiltro+= "QM2_FABR		<= '"	+ mv_par14 +	"' AND " 
cFiltro+= "QM2_RESP		>= '"	+ mv_par15 +	"' AND " 
cFiltro+= "QM2_RESP		<= '"	+ mv_par16 +	"' AND "  
cFiltro+= "QM2_FLAG		= '1' AND " 
cFiltro+= "D_E_L_E_T_= ' ' "
cFiltro+= "ORDER BY " + SqlOrder(cChave)
cFiltro:= ChangeQuery(cFiltro)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cFiltro),"TRB",.T.,.T.)
dbSelectArea( "TRB" )				

SetRegua(RecCount())

While ! Eof()

	TRB_FILIAL	:= TRB->QM2_FILIAL
	TRB_INSTR	:= TRB->QM2_INSTR
	TRB_REVINS	:= TRB->QM2_REVINS
	TRB_DEPTO	:= TRB->QM2_DEPTO
	TRB_TIPO	:= TRB->QM2_TIPO
	TRB_FABR	:= TRB->QM2_FABR
	TRB_STATUS	:= TRB->QM2_STATUS
	TRB_RESP	:= TRB->QM2_RESP
	TRB_NHORDI	:= TRB->QM2_NHORDI
	
	IF lEnd
		@Prow()+1,001 PSAY OemToAnsi(STR0007)  //"CANCELADO PELO OPERADOR"
		EXIT
	ENDIF
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se status do instrumento esta com atualiza ativo       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !QMTXSTAT(TRB_STATUS)
		dbskip()
		loop
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifico O.C. interno e externo                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par06 == 1
		If ! Calibrador(0,mv_par07,mv_par08,mv_par09,mv_par10,TRB_INSTR,TRB_REVINS)
			dbSkip()
			Loop
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifico O.C. externo                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par06 == 2
		If ! Calibrador(2,mv_par07,mv_par08,mv_par09,mv_par10,TRB_INSTR,TRB_REVINS)
			dbSkip()
			Loop
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifico O.C. interno                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If mv_par06 == 3
		If ! Calibrador(1,,,mv_par09,mv_par10,TRB_INSTR,TRB_REVINS)
			dbSkip()
			Loop
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifico se ha horas previstas cadastradas                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Val(Substr(TRB_NHORDI,1,2))+Val(Substr(TRB_NHORDI,4,2)) <= 0
		dbSkip()
		Loop
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Procura o departamento no QAD - Centro de Custo.             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QAD")
	dbSetOrder(1)
	dbSeek( xFilial("QAD") + TRB_DEPTO )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Procura a descricao da familia no QM1                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea( "QM1" )
	dbSetOrder( 1 )
	dbSeek( xFilial("QM1") + TRB_TIPO )
	
	/*
	1         2         3         4         5         6         7         8         9         0         1         2         3
	012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
	FAMILIA          INSTRUMENTO      DEPARTAMENTO     FABRICANTE       PREVIS PARADO   %    PREVIS PARADO    %   PREVIS PARADO   %
	================ ================ ================ ================ ====== ====== ====== ====== ====== ====== ====== ====== ======
	XXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXX 999:99 999:99 999,99 999:99 999:99 999,99 999:99 999:99 999,99
	XX               XX
	*/
	
	IncRegua()
	lImp := .F.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializa a matriz para valores num‚ricos ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aResult := array(Len(aCab1))
	For nCntFor := 1	To Len(aResult)
		aResult[nCntFor] := 0
	Next
	
	dbSelectArea("QM6")
	QM6->(DbSetOrder(1))
	If QM6->(DbSeek( xFilial("QM6") + TRB_INSTR + TRB_REVINS ))
		Do while TRB_FILIAL+TRB_INSTR+TRB_REVINS == ;
			QM6->QM6_FILIAL+QM6->QM6_INSTR+QM6->QM6_REVINS
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifico se a data corrente ‚ valida  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cChave := Alltrim(Str(Year(QM6->QM6_DATA),4))+Alltrim(Str(Month(QM6->QM6_DATA),4))
			
			For nCntFor := 1 to Len(aCab1)
				If cChave == aCab1[nCntFor]
					aResult[nCntFor] += (Val(Subs(QM6->QM6_TOTHOR,1,2))* 60) + ;
					Val(Subs(QM6->QM6_TOTHOR,4,2))
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ So imprime se houver valores maiores que zero   ³
					//³  para pelo menos um mes do trimestre exibido    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If (Val(Subs(QM6->QM6_TOTHOR,1,2))* 60) + ;
						Val(Subs(QM6->QM6_TOTHOR,4,2)) > 0
						lImp := .T.
						lImp2 := .T.
					EndIf
				EndIf
			Next nCntFor
			QM6->(DbSkip())
		EndDo
		
		If lImp
			li := li + 1
			If li > 58
				cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIF(aReturn[4]==1,15,18))
				li++
			EndIf
			
			@ li,000 PSAY TRB_TIPO
			@ li,017 PSAY TRB_INSTR
			@ li,034 PSAY TRB_DEPTO
			@ li,051 PSAY TRB_FABR
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula o n§ de dias do mes corrente subtraindo   ³
			//³  um do mes posterior ao corrente                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (Month(mv_par03) + 1) > 12
				nMes := 01
				nAno := Year(mv_par03) + 1
			Else
				nMes := Month(mv_par03) + 1
				nAno := Year(mv_par03)
			EndIf
			
			dUltDiaMes := CToD("01/" + ;
			StrZero(nMes,2) + "/" + ;
			Str(nAno),"DDMMYY" ) - 1
			
			nHoraPrev :=  ( (Val(Substr(TRB_NHORDI,1,2)) * 60) ;
			+ Val(Substr(TRB_NHORDI,4,2)) ;
			) *  Day(dUltDiaMes)
			
			nTotPrev[1] +=  nHoraPrev
			nTotPar[1]  +=  aResult[1]
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³  Calcula a porcentagem antes de arredondar nHoraPrev  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nHoraPrev <= 0
				nPerc := 100 - ( ( aResult[1] / 1 ) * 100 )
			Else
				nPerc := 100 - ( ( aResult[1] / nHoraPrev ) * 100 )
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³  Faz o calculo do tempo previsto  em Hora/Minutos   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nMinPrev  := Mod(nHoraPrev,60)
			nHoraPrev := Int(nHoraPrev / 60)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³  Faz o calculo do tempo  parado em minutos        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nMinPar  := Mod(aResult[1], 60)
			nHoraPar := Int( aResult[1] / 60 )
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Passa para Caracter para imprimir os zeros        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			@ li,068 PSAY Str(nHoraPrev,3) Picture "999"
			@ li,071 PSAY ":"
			@ li,072 PSAY StrZero(nMinPrev,2) Picture "99"
			
			@ li,075 PSAY Str(nHoraPar,3) Picture "999"
			@ li,078 PSAY ":"
			@ li,079 PSAY StrZero(nMinPar,2) Picture "99"
			
			@ li,082 PSAY nPerc Picture "@E 999.99"
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula o n§ de dias do mes anterior subtraindo   ³
			//³  1 do mes corrente                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			// Calcula o mes anterior
			nMes := Month(mv_par03)
			nAno := Year(mv_par03)
			
			dUltDiaMes :=    CToD("01/" + ;
			StrZero(nMes,2) + "/" + ;
			Str(nAno),"DDMMYY" ) - 1
			
			nHoraPrev :=  ( (Val(Substr(TRB_NHORDI,1,2)) * 60) ;
			+ Val(Substr(TRB_NHORDI,4,2)) ;
			) *  Day(dUltDiaMes)
			
			nTotPrev[2] +=  nHoraPrev
			nTotPar[2]  +=  aResult[2]
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³  Calcula a porcentagem antes de arredondar nHoraPrev  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPerc := ( 100 - ( aResult[2] / nHoraPrev ) * 100 )
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³  Faz o calculo do tempo previsto em Hora/Minutos    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nMinPrev  := Mod(nHoraPrev,60)
			nHoraPrev := Int(nHoraPrev / 60)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³  Faz o calculo do tempo parado em Hora/Minutos    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nMinPar  := Mod(aResult[2], 60)
			nHoraPar := Int( aResult[2] / 60 )
			
			@ li,089 PSAY Str(nHoraPrev,3) Picture "999"
			@ li,092 PSAY ":"
			@ li,093 PSAY StrZero(nMinPrev,2) Picture "99"
			
			@ li,096 PSAY Str(nHoraPar,3) Picture "999"
			@ li,099 PSAY ":"
			@ li,100 PSAY StrZero(nMinPar,2) Picture "99"
			
			@ li,103 PSAY nPerc Picture "@E 999.99"
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula o n§ de dias do penultimo mes subtraindo  ³
			//³  um do mes anterior ao corrente                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Month(mv_par03) - 1 < 1
				nMes := 12
				nAno := Year(mv_par03) - 1
			Else
				nMes := Month(mv_par03) - 1
				nAno := Year(mv_par03)
			EndIf
			
			dUltDiaMes :=     CToD("01/" + ;
			StrZero(nMes,2) + "/" + ;
			Str(nAno),"DDMMYY" ) - 1
			
			nHoraPrev :=  ( (Val(Substr(TRB_NHORDI,1,2)) * 60) ;
			+ Val(Substr(TRB_NHORDI,4,2)) ;
			) *  Day(dUltDiaMes)
			
			nTotPrev[3] +=  nHoraPrev
			nTotPar[3]  +=  aResult[3]
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³  Calcula a porcentagem antes de arredondar nHoraPrev  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPerc := 100 - ( ( aResult[3] / nHoraPrev ) * 100 )
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³  Faz o calculo do tempo  previsto  em Hora/Minutos  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nMinPrev  := Mod(nHoraPrev,60)
			nHoraPrev := Int(nHoraPrev / 60)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³  Faz o calculo do tempo  parado  em Hora/Minutos  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nMinPar  := Mod(aResult[3], 60)
			nHoraPar := Int( aResult[3] / 60 )
			
			@ li,110 PSAY Str(nHoraPrev,3) Picture "999"
			@ li,113 PSAY ":"
			@ li,114 PSAY StrZero(nMinPrev,2) Picture "99"
			
			@ li,117 PSAY Str(nHoraPar,3) Picture "999"
			@ li,120 PSAY ":"
			@ li,121 PSAY StrZero(nMinPar,2) Picture "99"
			
			@ li,124 PSAY nPerc Picture "@E 999.99"
			
			lImp := .F.
			aResult := array(Len(aCab1))
		EndIf
	EndIf
	
	dbSelectArea("TRB")
	DbSkip()
EndDo

If lImp2
	If li+4  > 58
		Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIF(aReturn[4]==1,15,18))
		li++
	EndIf
	
	li := li + 2
	@ li, 044 PSAY OemToAnsi(STR0033) //"MEDIA DO MES..........:"
	nPerc :=  100 - ( nTotPar[1] / nTotPrev[1] ) * 100
	@ li, 082 PSAY nPerc Picture "@E 999.99"
	nPerc :=  100 - ( nTotPar[2] / nTotPrev[2] ) * 100
	@ li, 103 PSAY nPerc Picture "@E 999.99"
	nPerc :=  100 - ( nTotPar[3] / nTotPrev[3] ) * 100
	@ li, 124 PSAY nPerc Picture "@E 999.99"
	li := li + 1
	@ li, 044 PSAY OemToAnsi(STR0034) //"MEDIA DO TRIMESTRE....:"
	nTotAcum :=  100 - ( (nTotPar[1] + nTotPar[2] + nTotPar[3]);
	/ (nTotPrev[1] + nTotPrev[2] + nTotPrev[3])  ) * 100
	@ li, 124 PSAY nTotAcum Picture "@E 999.99"
EndIf

Roda( cbCont, cbTxt, Tamanho )

Set Device To Screen
dbSelectArea("TRB")
dbCloseArea()
dbSelectArea(cAlias)
dbSetOrder(nOrder)

If aReturn[5] = 1
	Set Printer TO
	dbCommitall()
	ourspool(wnrel)
End
MS_FLUSH()

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³R130Cab1  ³ Autor ³ Wandreley Goncalves   ³ Data ³ 23.12.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta a primeira linha do cabecalho                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ R130Cab1()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTR130													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION R130Cab1(aCab1)

Local aMeses	:= {STR0009,STR0010,STR0011,STR0012,STR0013,STR0014,; // "Jan"###"Fev"###"Mar"###"Abr"###"Mai"###"Jun"
STR0015,STR0016,STR0017,STR0018,STR0019,STR0020 } // "Jul"###"Ago"###"Set"###"Out"###"Nov"###"Dez"

Local nMes     := Month(mv_par03)
Local nAno		:= Year(mv_par03)
Local cCab1    := ""
Local nI

cCab1 := space(68)
cCab1 += "------ " + aMeses[nMes]+"/"+Subs(AllTrim(Str(nAno)),3,2)+" ------ "

Aadd(aCab1,Alltrim(Str(nAno,4))+Alltrim(Str(nMes,4)))

For nI := 1 to 2
	nMes--
	If nMes == 0
		nMes := 12
		nAno := nAno - 1
	EndIf
	cCab1 += "------ " + aMeses[nMes]+"/"+Subs(AllTrim(Str(nAno)),3,2)+" ------ "
	
	aadd(aCab1,Alltrim(Str(nAno,4))+Alltrim(Str(nMes,4)))
	
Next nI

Return( cCab1 )