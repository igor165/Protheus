#include "Ofior510.ch"
#include "Protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � OFIOR510 � Autor � Andre                 � Data � 09/03/04 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Lista de pecas substituidas com estoque positivo           ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function OFIOR510

Local oReport
Private cStr   := ""

If FindFunction("TRepInUse") .And. TRepInUse()
	Pergunte("OFR510",.f.)
	oReport := ReportDef()
	oReport:PrintDialog()
Else
	OR510R3() // Executa vers�o anterior do fonte
Endif

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ReportDef� Autor � ANDRE                 � Data � 23/02/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Relatorio usando o TReport                                 ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Oficina                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ReportDef()

Local oReport 
Local oSection1 
Local oCell

oReport := TReport():New("OFIOR510",OemToAnsi(STR0007),"OFR510",{|oReport| OR510Imp(oReport)})//Lista de pecas substituidas com estoque positivo

oSection1 := TRSection():New(oReport,OemToAnsi("Secao 1"),{})
TRCell():New(oSection1,"",,"","@!",220,, {|| cStr } )

Return oReport

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � OR510Imp � Autor � ANDRE                 � Data � 23/02/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Executa a impressao do relatorio do TReport                ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Oficina                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function OR510Imp(oReport)

Local oSection1 := oReport:Section(1)
Local nTotAnt := 0
Local nTotNov := 0
Local nQtdAnt := 0
Local nQtdNov := 0

dbSelectArea("SB1")
dbSetOrder(7)

dbSelectArea("SB2")
dbSetOrder(1)

dbSelectArea("VE9")
dbSetOrder(1)
dbSeek(xFilial("VE9"))

oReport:SetMeter(RecCount())
oSection1:Init(.f.)
                   // boby - FNC 29222 - 17/12
Cabec1 := STR0004  //"Grupo Item  Codigo Antigo                 Descricao                        Qtdade     Codigo Novo                 Qtdade"
cStr   := cabec1
oSection1:PrintLine()

cStr := repl("-",125)
oSection1:PrintLine()

While !EOF()

   if VE9->VE9_DATSUB < mv_par02 .or. VE9->VE9_DATSUB > mv_par03              //boby - FNC 29222 - 17/12
      dbSkip()
      Loop
   Endif

   SB1->(dbSeek(xFilial("SB1")+VE9->VE9_GRUITE+VE9->VE9_ITEANT))
   SB2->(dbSeek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD))
   nQtdAnt := SaldoSB2()
   
   SB1->(dbSeek(xFilial("SB1")+VE9->VE9_GRUITE+VE9->VE9_ITENOV))
   SB2->(dbSeek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD))
   nQtdNov := SaldoSB2()

   lImp := .f.
   if mv_par01 == 2
      if nQtdAnt > 0 .or. nQtdNov > 0
         lImp := .t.
      Endif
   Else
      if nQtdAnt > 0
         lImp := .t.
      Endif
   Endif   
      
   if lImp
      cStr := VE9->VE9_GRUITE+"        "+VE9->VE9_ITEANT+"   "+Posicione("SB1",1,xFilial("SB1")+VE9->VE9_ITEANT,"SB1->B1_DESC")+"   "+Transform(nQtdAnt,"@E 999,999")+"     "+;
		VE9->VE9_ITENOV+" "+Transform(nQtdNov,"@E 999,999")
		nTotAnt += nQtdAnt
		nTotNov += nQtdNov
		oSection1:PrintLine()
	Endif	

   dbSelectArea("VE9")
   dbSkip()
EndDo

If mv_par04 == 2
   cStr := "----------------------------------------"
	oSection1:PrintLine()
   cStr := STR0005 + Transform(nTotAnt,"@E 999,999")  //"Total Pecas substituidas...: "
	oSection1:PrintLine()
   cStr := STR0006 + Transform(nTotNov,"@E 999,999")  //"Total Pecas novas..........: "
	oSection1:PrintLine()
   cStr := "----------------------------------------"
	oSection1:PrintLine()
EndIf

oSection1:Finish()

Return Nil


/*
����������������������������������������������������������������������
����������������������������������������������������������������������
������������������������������������������������������������������Ŀ��
���Fun��o    � OFIOR510 � Autor �  Thiago        � Data � 21/06/02 ���
������������������������������������������������������������������Ĵ��
���Descri�ao � Demonstrativo de Metas de Vendas                    |��
�������������������������������������������������������������������ٱ�
����������������������������������������������������������������������
����������������������������������������������������������������������
*/
Function OR510R3

//��������������������������������������������������������������Ŀ
//� Definicao das variaveis                                      �
//����������������������������������������������������������������
LOCAL Tamanho  := "G"
LOCAL Titulo   := STR0007  //Lista de pecas substituidas com estoque positivo
LOCAL cDesc1   := ""
LOCAL cDesc2   := ""
LOCAL cDesc3   := ""
LOCAL cString  := "VE9"
LOCAL cNomeRel := "OFIOR510"

//��������������������������������������������������������������Ŀ
//� Variaveis tipo Private padrao de todos os relatorios         �
//����������������������������������������������������������������
PRIVATE aReturn:= { OemToAnsi(STR0002), 1,OemToAnsi(STR0003), 1, 2, 1, "",1 }  //"Zebrado","Administracao"
PRIVATE nLastKey := 0 ,cPerg := "OFR510"

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01     // Mostra saldo pecas novas?                    �
//� mv_par02     // Data inicio                                  �
//� mv_par03     // Data final                                   �
//� mv_par04     // Totaliza?                                    �
//����������������������������������������������������������������
Pergunte(cPerg,.F.)

//��������������������������������������������������������������Ŀ
//� Envia controle para a funcao SETPRINT                        �
//����������������������������������������������������������������
cNomeRel:=SetPrint(cString,cNomeRel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.F.,Tamanho)

If nLastKey == 27
	Set Filter to
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Set Filter to
	Return
Endif

RptStatus({|lEnd| C510Imp(@lEnd,cNomeRel,cString,tamanho,titulo)},titulo)

Return NIL

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � C510Imp  � Autor � Andre                 � Data � 09/03/03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Chamada do Relatorio                                       ���
�������������������������������������������������������������������������Ĵ��
���Uso       � OFIOR510                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function C510Imp(lEnd,cNomeRel,cString,Tamanho,Titulo)

//��������������������������������������������������������������Ŀ
//� Variaveis locais exclusivas deste programa                   �
//����������������������������������������������������������������
LOCAL lImp    := .f.
LOCAL nQtdNov := 0
LOCAL nQtdAnt := 0
LOCAL nTotNov := 0
LOCAL nTotAnt := 0

//��������������������������������������������������������������Ŀ
//� Contadores de linha e pagina                                 �
//����������������������������������������������������������������
PRIVATE li := 80 ,m_pag := 1

//�������������������������������������������������������������������Ŀ
//� Inicializa os codigos de caracter Comprimido/Normal da impressora �
//���������������������������������������������������������������������
PRIVATE nTipo  := IIF(aReturn[4]==1,15,18)

//��������������������������������������������������������������Ŀ
//� Monta os Cabecalhos                                          �
//����������������������������������������������������������������
				  // boby alinhado o cabecalho - FNC 29222 - 17/12
                  //           1         2         3         4         5         6         7         8         9         10        11        12        13
                  // 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
Cabec1 := STR0004 //"Grupo Item  Codigo Antigo                 Descricao                        Qtdade     Codigo Novo                 Qtdade"
Cabec2 := ""

//��������������������������������������������������������������Ŀ
//� Redireciona as ordens a serem lidas                          �
//����������������������������������������������������������������
dbSelectArea("VE9")
dbSetOrder(1)

dbSelectArea("SB1")
dbSetOrder(7)

dbSelectArea("SB2")
dbSetOrder(1)

//��������������������������������������������������������������Ŀ
//� Inicializa variaveis para controlar cursor de progressao     �
//����������������������������������������������������������������
dbSelectArea("VE9")
dbSetOrder(1)
dbSeek(xFilial("VE9"))
SetRegua(LastRec())

While !EOF()
   if VE9->VE9_DATSUB < mv_par02 .or. VE9->VE9_DATSUB > mv_par03
      dbSkip()
      Loop
   Endif
   
   if li > 55
      Cabec(Titulo,Cabec1,Cabec2,cNomeRel,Tamanho,nTipo)
   Endif

   SB1->(dbSeek(xFilial("SB1")+VE9->VE9_GRUITE+VE9->VE9_ITEANT))
   SB2->(dbSeek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD))
   nQtdAnt := SaldoSB2()
   
   SB1->(dbSeek(xFilial("SB1")+VE9->VE9_GRUITE+VE9->VE9_ITENOV))
   SB2->(dbSeek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD))
   nQtdNov := SaldoSB2()

   lImp := .f.
   if mv_par01 == 2
      if nQtdAnt > 0 .or. nQtdNov > 0
         lImp := .t.
      Endif
   Else
      if nQtdAnt > 0
         lImp := .t.
      Endif
   Endif   
      
   if lImp
     	@ li,000 PSay VE9->VE9_GRUITE
		@ li,012 PSay VE9->VE9_ITEANT
		@ li,042 PSay Posicione("SB1",1,xFilial("SB1")+VE9->VE9_ITEANT,"SB1->B1_DESC")
		@ li,075 PSay Transform(nQtdAnt,"@E 999,999")
		@ li,086 PSay VE9->VE9_ITENOV
		@ li,114 PSay Transform(nQtdNov,"@E 999,999")
		nTotAnt += nQtdAnt
		nTotNov += nQtdNov
		li++
	Endif	

   dbSelectArea("VE9")
   dbSkip()
EndDo

If mv_par04 == 2
	li+=2
	If li > 55
		Cabec(titulo,cabec1,cabec2,cNomeRel,Tamanho,nTipo)
	EndIf
	@ li,000 PSay "----------------------------------------"
	li++
	@ li,000 PSay STR0005 + Transform(nTotAnt,"@E 999,999")  //"Total Pecas substituidas...: "
	li++
	@ li,000 PSay STR0006 + Transform(nTotNov,"@E 999,999")  //"Total Pecas novas..........: "
EndIf

//��������������������������������������������������������������Ŀ
//� Restauras as ordens principais dos arquivos envolvidos       �
//����������������������������������������������������������������
dbSelectArea("VE9")
dbSetOrder(1)

dbSelectArea("SB1")
dbSetOrder(1)

dbSelectArea("SB2")
dbSetOrder(1)

//��������������������������������������������������������������Ŀ
//� Devolve a condicao original do arquivo principal             �
//����������������������������������������������������������������
dbSelectArea(cString)
dbSetOrder(1)
Set Filter To

If aReturn[5] == 1
	Set Printer To
	dbCommitAll()
	OurSpool(cNomeRel)
Endif

MS_FLUSH()

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � VldPerg  � Autor � Andre                 � Data � 09/03/03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Verifica se existe as perguntas no SX1                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       � OFIOR510                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
Static Function VldPerg()

LOCAL i,j
LOCAL cAlias  := Alias()
LOCAL aPerg   := {}

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/VaR14/Def04/Cnt04/Var05/Def05/Cnt05
aAdd(aPerg,{cPerg,"01","Saldo Pecas Novas?","","","mv_ch1","N",1,0,0,"C","","mv_par01","0=Nao","","","","","1=Sim","","","","","","","",""})
aAdd(aPerg,{cPerg,"02","Data Inicial"      ,"","","mv_ch2","D",8,0,0,"G","","mv_par02",""     ,"","","","",""     ,"","","","","","","",""})
aAdd(aPerg,{cPerg,"03","Data Final"        ,"","","mv_ch3","D",8,0,0,"G","","mv_par03",""     ,"","","","",""     ,"","","","","","","",""})
aAdd(aPerg,{cPerg,"04","Totaliza?"         ,"","","mv_ch4","N",1,0,0,"C","","mv_par04","0=Nao","","","","","1=Sim","","","","","","","",""})

For i:=1 to Len(aPerg)
    If !dbSeek(cPerg+aPerg[i,2])
        RecLock("SX1",.T.)
        For j:=1 to FCount()
            If j <= Len(aPerg[i])
                FieldPut(j,aPerg[i,j])
            Endif
        Next
        MsUnlock()
    Endif
Next

dbSelectArea(cAlias)

Return
*/
