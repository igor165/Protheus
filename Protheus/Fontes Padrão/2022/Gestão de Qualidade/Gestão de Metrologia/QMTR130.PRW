#INCLUDE "QMTR130.CH"
#INCLUDE "PROTHEUS.CH"
#include "report.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QMTR130  � Autor � Cicero Cruz           � Data � 13.06.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de Disponibilidade de Instumentos                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QMTR130(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor � Cicero Cruz           � Data � 06/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Uso       � QMTR130                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrin� Autor �Cicero Cruz            � Data � 06/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � A funcao estatica ReportDef devera ser criada para todos os���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1: Objeto Report do Relatorio                          ���
�������������������������������������������������������������������������Ĵ��
���Uso       � QMTR130                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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

//������������������������������������������������������������������������Ŀ
//�Transforma parametros Range em expressao SQL                            �
//��������������������������������������������������������������������������
MakeSqlExpr(oReport:uParam) 


//������������������������������������������������������������������������Ŀ
//�Query do relat�rio da secao 1                                           �
//��������������������������������������������������������������������������
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
	//�����������������������������������������������������������������Ŀ
	//� Verifica se status do instrumento esta com atualiza ativo       �
	//�������������������������������������������������������������������
	If !QMTXSTAT(&(cAliasQM2+"->QM2_STATUS"))
		(cAliasQM2)->(dbSkip())
		loop
	EndIf
	
	//�����������������������������������������������������������������Ŀ
	//� Verifico O.C. interno e externo                                 �
	//�������������������������������������������������������������������
	If mv_par06 == 1
		If ! Calibrador(0,mv_par07,mv_par08,mv_par09,mv_par10,&(cAliasQM2+"->QM2_INSTR"),&(cAliasQM2+"->QM2_REVINS"))
			&(cAliasQM2)->(dbSkip())
			Loop
		EndIf
	EndIf
	
	//�����������������������������������������������������������������Ŀ
	//� Verifico O.C. interno                                           �
	//�������������������������������������������������������������������
	If mv_par06 == 2
		If ! Calibrador(2,mv_par07,mv_par08,mv_par09,mv_par10,&(cAliasQM2+"->QM2_INSTR"),&(cAliasQM2+"->QM2_REVINS"))
			&(cAliasQM2)->(dbSkip())
			Loop
		EndIf
	EndIf
	
	//�����������������������������������������������������������������Ŀ
	//� Verifico O.C. externo                                           �
	//�������������������������������������������������������������������
	
	If mv_par06 == 3
		If ! Calibrador(1,mv_par07,mv_par08,mv_par09,mv_par10,&(cAliasQM2+"->QM2_INSTR"),&(cAliasQM2+"->QM2_REVINS"))
			&(cAliasQM2)->(dbSkip())
			Loop
		EndIf
	EndIf
	
	//�����������������������������������������������������������������Ŀ
	//� Verifico se ha horas previstas cadastradas                      �
	//�������������������������������������������������������������������     
	If Val(Substr(QM2_NHORDI,1,2))+Val(Substr(QM2_NHORDI,4,2)) <= 0
		&(cAliasQM2)->(dbSkip())
	   	Loop
	EndIf
	
	//��������������������������������������������������������������Ŀ
	//� Procura o departamento no QAD - Centro de Custo.             �
	//����������������������������������������������������������������
	dbSelectArea("QAD")
	dbSetOrder(1)
	dbSeek( xFilial("QAD") + &(cAliasQM2+"->QM2_DEPTO") )
	
	//��������������������������������������������������������������Ŀ
	//� Procura a descricao da familia no QM1                        �
	//����������������������������������������������������������������
	dbSelectArea( "QM1" )
	dbSetOrder( 1 )
	dbSeek( xFilial("QM1") + &(cAliasQM2+"->QM2_TIPO") )
	
	lImp := .F.
	
	//�������������������������������������������Ŀ
	//�Inicializa a matriz para valores num�ricos �
	//���������������������������������������������
	aResult := array(Len(aCab1))
	For nCntFor := 1	To Len(aResult)
		aResult[nCntFor] := 0
	Next
	
	dbSelectArea("QM6")
	QM6->(DbSetOrder(1))
	If QM6->(DbSeek( xFilial("QM6") + &(cAliasQM2+"->QM2_INSTR") + &(cAliasQM2+"->QM2_REVINS") ))
		DO WHILE &(cAliasQM2+"->QM2_FILIAL")+&(cAliasQM2+"->QM2_INSTR")+&(cAliasQM2+"->QM2_REVINS") == ;
			QM6->QM6_FILIAL+QM6->QM6_INSTR+QM6->QM6_REVINS
			
			//���������������������������������������Ŀ
			//� Verifico se a data corrente � valida  �
			//�����������������������������������������
			cChave := Alltrim(Str(Year(QM6->QM6_DATA),4))+Alltrim(Str(Month(QM6->QM6_DATA),4))
			
			For nCntFor := 1 to Len(aCab1)
				If cChave == aCab1[nCntFor]
					aResult[nCntFor] += (Val(Subs(QM6->QM6_TOTHOR,1,2))* 60) + ;
					Val(Subs(QM6->QM6_TOTHOR,4,2))
					//�������������������������������������������������Ŀ
					//� So imprime se houver valores maiores que zero   �
					//�  para pelo menos um mes do trimestre exibido    �
					//���������������������������������������������������
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
			
			//�������������������������������������������������������Ŀ
			//�  Calcula a porcentagem antes de arredondar nHoraPrev  �
			//���������������������������������������������������������
			If nHoraPrev <= 0
				nPerc := 100 - ( ( aResult[1] / 1 ) * 100 )
			Else
				nPerc := 100 - ( ( aResult[1] / nHoraPrev ) * 100 )
			EndIf
			
			//�����������������������������������������������������Ŀ
			//�  Faz o calculo do tempo previsto  em Hora/Minutos   �
			//�������������������������������������������������������
			nMinPrev  := Mod(nHoraPrev,60)
			nHoraPrev := Int(nHoraPrev / 60)
			
			//���������������������������������������������������Ŀ
			//�  Faz o calculo do tempo  parado em minutos        �
			//�����������������������������������������������������
			nMinPar  := Mod(aResult[1], 60)
			nHoraPar := Int(aResult[1]/60)

			cVar := Str(nHoraPrev,3)+":"+StrZero(nMinPrev,2)+" "+Str(nHoraPar,3)+":"+StrZero(nMinPar,2)+" "+StrTran (Str(nPerc,6,2),".",",",1)
			oSection1:Cell("MES1"):cTitle := "-- " + aMeses[nMes] + "/" + Right(Str(nAno),2) + " -----" + CRLF + STR0022
			oSection1:Cell("MES1"):SetValue(cVar)
			
			//���������������������������������������������������Ŀ
			//� Calcula o n� de dias do mes anterior subtraindo   �
			//�  1 do mes corrente                                �
			//�����������������������������������������������������
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
			
			//�������������������������������������������������������Ŀ
			//�  Calcula a porcentagem antes de arredondar nHoraPrev  �
			//���������������������������������������������������������
			nPerc := ( 100 - ( aResult[2] / nHoraPrev ) * 100 )
			
			//�����������������������������������������������������Ŀ
			//�  Faz o calculo do tempo previsto em Hora/Minutos    �
			//�������������������������������������������������������
			nMinPrev  := Mod(nHoraPrev,60)
			nHoraPrev := Int(nHoraPrev / 60)
			
			//���������������������������������������������������Ŀ
			//�  Faz o calculo do tempo parado em Hora/Minutos    �
			//�����������������������������������������������������
			nMinPar  := Mod(aResult[2], 60)
			nHoraPar := Int( aResult[2] / 60 )
			
			cVar := Str(nHoraPrev,3)+":"+StrZero(nMinPrev,2)+" "+Str(nHoraPar,3)+":"+StrZero(nMinPar,2)+" "+StrTran (Str(nPerc,6,2),".",",",1)
			oSection1:Cell("MES2"):cTitle += "-- " + aMeses[nMes] + "/" + Right(Str(nAno),2) + " -----" + CRLF + STR0022
			oSection1:Cell("MES2"):SetValue(cVar)
	
			//���������������������������������������������������Ŀ
			//� Calcula o n� de dias do penultimo mes subtraindo  �
			//�  um do mes anterior ao corrente                   �
			//�����������������������������������������������������
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
			
			//�������������������������������������������������������Ŀ
			//�  Calcula a porcentagem antes de arredondar nHoraPrev  �
			//���������������������������������������������������������
			nPerc := 100 - ( ( aResult[3] / nHoraPrev ) * 100 )
			
			//�����������������������������������������������������Ŀ
			//�  Faz o calculo do tempo  previsto  em Hora/Minutos  �
			//�������������������������������������������������������
			nMinPrev  := Mod(nHoraPrev,60)
			nHoraPrev := Int(nHoraPrev / 60)
			
			//���������������������������������������������������Ŀ
			//�  Faz o calculo do tempo  parado  em Hora/Minutos  �
			//�����������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QMTR130R3� Autor � Wanderley Goncalves   � Data � 23.12.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de Disponibilidade de Instumentos                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QMTR130R3(void)                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function QMTR130R3()
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������

Local cDesc1	:= OemToAnsi( STR0001 ) // "Este programa ir� emitir a rela��o de"
Local cDesc2	:= OemToAnsi( STR0002 ) // "disponibilidade de instrumentos."
Local cDesc3	:= ""
Local wnrel
Local lImpLin2	:= .T.
Local cString	:="QM2"

Private titulo
Private cabec1		:= ""
Private cabec2    := ""
Private aReturn	:= { OemToAnsi(STR0003), 1,OemToAnsi(STR0004), 1, 2, 1, "",1 } //"Zebrado"###"Administra��o"
Private nomeprog	:="QMTR130"

Private nLastKey	:= 0
Private cPerg		:="QMR130"
Private cTamanho := "M"

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
pergunte(cPerg,.F.)
//�������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                  �
//� mv_par01   : Instrumento Inicial                      �
//� mv_par02   : Instrumento Final                        �
//� mv_par03   : Periodo Inicial                          �
//� mv_par04   : Departamento Inicial                     �
//� mv_par05   : Departamento Final                       �
//� mv_par06   : Orgao Calibrador Todos/Interno/Externo   �
//� mv_par07   : Orgao Calibrador interno de              �
//� mv_par08   : Orgao Calibrador interno ate             �
//� mv_par09   : Orgao Calibrador externo de              �
//� mv_par10   : Orgao Calibrador externo ate             �
//� mv_par11   : Fam�lia de                               �
//� mv_par12   : Fam�lia ate                              �
//� mv_par13   : Fabricante de                            �
//� mv_par14   : Fabricante ate                           �
//� mv_par15   : Usu�rio de                               �
//� mv_par16   : Usu�rio ate                              �
//���������������������������������������������������������

//��������������������������������������������������������������Ŀ
//� Definicao dos cabecalhos                                     �
//����������������������������������������������������������������
titulo := OemToAnsi( STR0005 ) // "Relatorio de Disponibilidade"
cabec1 := ''
cabec2 := OemToAnsi( STR0006 ) // "FAMILIA          INSTRUMENTO      DEPARTAMENTO     FABRICANTE       PREVIS PARADO   %    PREVIS PARADO    %   PREVIS PARADO   %   "
//��������������������������������������������������������������Ŀ
//� Envia controle para a funcao SETPRINT                        �
//����������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MTR130IMP� Autor � Wanderley Goncalves   � Data � 23.12.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao do relatorio                                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MTR130IMP(lEnd,wnRel,cString)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� lEnd    - A��o do Codeblock                                ���
���          � wnRel   - T�tulo do relat�rio                              ���
���          � cString - Mensagem                                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape    �
//����������������������������������������������������������������
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
	
	//�����������������������������������������������������������������Ŀ
	//� Verifica se status do instrumento esta com atualiza ativo       �
	//�������������������������������������������������������������������
	If !QMTXSTAT(TRB_STATUS)
		dbskip()
		loop
	EndIf
	
	//�����������������������������������������������������������������Ŀ
	//� Verifico O.C. interno e externo                                 �
	//�������������������������������������������������������������������
	If mv_par06 == 1
		If ! Calibrador(0,mv_par07,mv_par08,mv_par09,mv_par10,TRB_INSTR,TRB_REVINS)
			dbSkip()
			Loop
		EndIf
	EndIf
	
	//�����������������������������������������������������������������Ŀ
	//� Verifico O.C. externo                                           �
	//�������������������������������������������������������������������
	If mv_par06 == 2
		If ! Calibrador(2,mv_par07,mv_par08,mv_par09,mv_par10,TRB_INSTR,TRB_REVINS)
			dbSkip()
			Loop
		EndIf
	EndIf
	
	//�����������������������������������������������������������������Ŀ
	//� Verifico O.C. interno                                           �
	//�������������������������������������������������������������������
	
	If mv_par06 == 3
		If ! Calibrador(1,,,mv_par09,mv_par10,TRB_INSTR,TRB_REVINS)
			dbSkip()
			Loop
		EndIf
	EndIf
	
	//�����������������������������������������������������������������Ŀ
	//� Verifico se ha horas previstas cadastradas                      �
	//�������������������������������������������������������������������
	If Val(Substr(TRB_NHORDI,1,2))+Val(Substr(TRB_NHORDI,4,2)) <= 0
		dbSkip()
		Loop
	EndIf
	
	//��������������������������������������������������������������Ŀ
	//� Procura o departamento no QAD - Centro de Custo.             �
	//����������������������������������������������������������������
	dbSelectArea("QAD")
	dbSetOrder(1)
	dbSeek( xFilial("QAD") + TRB_DEPTO )
	
	//��������������������������������������������������������������Ŀ
	//� Procura a descricao da familia no QM1                        �
	//����������������������������������������������������������������
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
	
	//�������������������������������������������Ŀ
	//�Inicializa a matriz para valores num�ricos �
	//���������������������������������������������
	aResult := array(Len(aCab1))
	For nCntFor := 1	To Len(aResult)
		aResult[nCntFor] := 0
	Next
	
	dbSelectArea("QM6")
	QM6->(DbSetOrder(1))
	If QM6->(DbSeek( xFilial("QM6") + TRB_INSTR + TRB_REVINS ))
		Do while TRB_FILIAL+TRB_INSTR+TRB_REVINS == ;
			QM6->QM6_FILIAL+QM6->QM6_INSTR+QM6->QM6_REVINS
			//���������������������������������������Ŀ
			//� Verifico se a data corrente � valida  �
			//�����������������������������������������
			cChave := Alltrim(Str(Year(QM6->QM6_DATA),4))+Alltrim(Str(Month(QM6->QM6_DATA),4))
			
			For nCntFor := 1 to Len(aCab1)
				If cChave == aCab1[nCntFor]
					aResult[nCntFor] += (Val(Subs(QM6->QM6_TOTHOR,1,2))* 60) + ;
					Val(Subs(QM6->QM6_TOTHOR,4,2))
					//�������������������������������������������������Ŀ
					//� So imprime se houver valores maiores que zero   �
					//�  para pelo menos um mes do trimestre exibido    �
					//���������������������������������������������������
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
			
			//���������������������������������������������������Ŀ
			//� Calcula o n� de dias do mes corrente subtraindo   �
			//�  um do mes posterior ao corrente                  �
			//�����������������������������������������������������
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
			
			//�������������������������������������������������������Ŀ
			//�  Calcula a porcentagem antes de arredondar nHoraPrev  �
			//���������������������������������������������������������
			If nHoraPrev <= 0
				nPerc := 100 - ( ( aResult[1] / 1 ) * 100 )
			Else
				nPerc := 100 - ( ( aResult[1] / nHoraPrev ) * 100 )
			EndIf
			
			//�����������������������������������������������������Ŀ
			//�  Faz o calculo do tempo previsto  em Hora/Minutos   �
			//�������������������������������������������������������
			nMinPrev  := Mod(nHoraPrev,60)
			nHoraPrev := Int(nHoraPrev / 60)
			
			//���������������������������������������������������Ŀ
			//�  Faz o calculo do tempo  parado em minutos        �
			//�����������������������������������������������������
			nMinPar  := Mod(aResult[1], 60)
			nHoraPar := Int( aResult[1] / 60 )
			
			//���������������������������������������������������Ŀ
			//� Passa para Caracter para imprimir os zeros        �
			//�����������������������������������������������������
			@ li,068 PSAY Str(nHoraPrev,3) Picture "999"
			@ li,071 PSAY ":"
			@ li,072 PSAY StrZero(nMinPrev,2) Picture "99"
			
			@ li,075 PSAY Str(nHoraPar,3) Picture "999"
			@ li,078 PSAY ":"
			@ li,079 PSAY StrZero(nMinPar,2) Picture "99"
			
			@ li,082 PSAY nPerc Picture "@E 999.99"
			
			//���������������������������������������������������Ŀ
			//� Calcula o n� de dias do mes anterior subtraindo   �
			//�  1 do mes corrente                                �
			//�����������������������������������������������������
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
			
			//�������������������������������������������������������Ŀ
			//�  Calcula a porcentagem antes de arredondar nHoraPrev  �
			//���������������������������������������������������������
			nPerc := ( 100 - ( aResult[2] / nHoraPrev ) * 100 )
			
			//�����������������������������������������������������Ŀ
			//�  Faz o calculo do tempo previsto em Hora/Minutos    �
			//�������������������������������������������������������
			nMinPrev  := Mod(nHoraPrev,60)
			nHoraPrev := Int(nHoraPrev / 60)
			
			//���������������������������������������������������Ŀ
			//�  Faz o calculo do tempo parado em Hora/Minutos    �
			//�����������������������������������������������������
			nMinPar  := Mod(aResult[2], 60)
			nHoraPar := Int( aResult[2] / 60 )
			
			@ li,089 PSAY Str(nHoraPrev,3) Picture "999"
			@ li,092 PSAY ":"
			@ li,093 PSAY StrZero(nMinPrev,2) Picture "99"
			
			@ li,096 PSAY Str(nHoraPar,3) Picture "999"
			@ li,099 PSAY ":"
			@ li,100 PSAY StrZero(nMinPar,2) Picture "99"
			
			@ li,103 PSAY nPerc Picture "@E 999.99"
			
			//���������������������������������������������������Ŀ
			//� Calcula o n� de dias do penultimo mes subtraindo  �
			//�  um do mes anterior ao corrente                   �
			//�����������������������������������������������������
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
			
			//�������������������������������������������������������Ŀ
			//�  Calcula a porcentagem antes de arredondar nHoraPrev  �
			//���������������������������������������������������������
			nPerc := 100 - ( ( aResult[3] / nHoraPrev ) * 100 )
			
			//�����������������������������������������������������Ŀ
			//�  Faz o calculo do tempo  previsto  em Hora/Minutos  �
			//�������������������������������������������������������
			nMinPrev  := Mod(nHoraPrev,60)
			nHoraPrev := Int(nHoraPrev / 60)
			
			//���������������������������������������������������Ŀ
			//�  Faz o calculo do tempo  parado  em Hora/Minutos  �
			//�����������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �R130Cab1  � Autor � Wandreley Goncalves   � Data � 23.12.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Monta a primeira linha do cabecalho                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � R130Cab1()												  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � QMTR130													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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