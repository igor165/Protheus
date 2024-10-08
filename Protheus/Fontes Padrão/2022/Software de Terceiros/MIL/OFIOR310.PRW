#INCLUDE "PROTHEUS.CH"
#INCLUDE "OFIOR310.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �OFIOR310  � Autor �Valdir F. Silva     � Data �  28/02/02   ���
�������������������������������������������������������������������������͹��
���Descricao � Emissao do relatorio de controle de vendas perdidas        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Gestao de concessionarias - SIGAOFI                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function OFIOR310
Local oReport
Private cPerg := "OFR310"
If FindFunction("TRepInUse") .And. TRepInUse()
	pergunte(cPerg,.F.)
   oReport := ReportDef()
   oReport:PrintDialog()
Else
   Return OFR310R3() // Executa vers�o anterior do fonte
EndIf
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

oReport := TReport():New("OFIOR310",OemToAnsi(STR0008),"OFR310",{|oReport| OFIR310IMP(,,,,oReport,oSection1,.T.)})//Controle de Vendas Perdidas

oSection1 := TRSection():New(oReport,OemToAnsi("Secao 1"),{"VE6","VE7","SA3"})
oSection1:lReadOnly := .T.

TRCell():New(oSection1,"VE6_NUMOSV","VE6",STR0009,"@!",TamSx3("VE6_NUMOSV")[1])  		   		//Doc
TRCell():New(oSection1,"A3_NOME"   ,"SA3",STR0010,"@!",20,,{|| Substr(A3_NOME,1,20) })			//Vendedor
TRCell():New(oSection1,"VE6_GRUITE","VE6",STR0011,"@!",TamSx3("VE6_GRUITE")[1])   				//Grupo
TRCell():New(oSection1,"VE6_CODITE","VE6",STR0012,"@!",TamSx3("VE6_CODITE")[1])    				//Cod Item
TRCell():New(oSection1,"VE6_QTDITE","VE6",STR0013,"999999",TamSx3("VE6_QTDITE")[1]) 			//Qtd
TRCell():New(oSection1,"VE6_VALPEC","VE6",STR0014,"@E 9,999,999.99",TamSx3("VE6_VALPEC")[1]) 	//Vlr
TRCell():New(oSection1,"VE6_CODMOT","VE6",STR0015,"@!",TamSx3("VE6_CODMOT")[1])					//Mot
TRCell():New(oSection1,"VE7_DESMOT","VE7",STR0016,"@!",20,,{|| Substr(VE7_DESMOT,1,20) })		//Descricao

Return oReport

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �OFR310R3  �Autor  �Fabio               � Data �  06/20/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function OFR310R3()

Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         := STR0003 //"Relatorio de Vendas perdidas"
Local titulo         := STR0003 //"Relatorio de Vendas perdidas"
Local nLin           := 80
Local Cabec1         := STR0004 //"Doc.-----Vendedor---------------------------Grupo-Peca--------------------------Qtd---------Valor-Motivo"
Local aOrd := {}
Private lEnd         := .F.
Private CbTxt        := ""
Private limite       := 132
Private tamanho      := "M"
Private nomeprog     := "OFIOR310"
Private nTipo        := 15
Private aReturn      := { STR0005, 1, STR0006, 1, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey     := 0
//Private cbtxt        := Space(10)
Private cPerg        := "OFR310"
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "OFIOR310"
Private M->VE6_INDREG:="1"
dbSelectArea("VE6")
dbSetOrder(1)

Pergunte(cPerg,.F.)

//���������������������������������������������������������������������Ŀ
//� Monta a interface padrao com o usuario...                           �
//�����������������������������������������������������������������������

wnrel := SetPrint("VE6",NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,"VE6")

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)

RptStatus({|| OFIR310IMP(Cabec1,"",Titulo,nLin) },Titulo)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    �OFIR310IMP� Autor � Valdir F. Silva    � Data �  28/02/02   ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS ���
���          � monta a janela com a regua de processamento.               ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function OFIR310IMP(Cabec1,Cabec2,Titulo,nLin,oReport,oSection1,lReport)

Private lAbortPrint  := .F.
                 
Default lReport := .f.

DbSelectArea("VAI")
DbSetOrder(4)
DbSelectArea("SA3")
DbSetOrder(1)

dbSelectArea("VE6")
dbSetOrder(1)

DbSeek(xFilial("VE6")+"1")

If !lReport
	SetRegua(RecCount())
Else
	oReport:SetMeter(VO6->(LastRec()))
EndIf	

While VE6->(!EOF()) .and. VE6->VE6_INDREG == "1" .and. VE6->VE6_DATREG >= MV_PAR01 .and. VE6->VE6_DATREG <= MV_PAR02
   If lAbortPrint
	   If !lReport
         @nLin,00 PSAY STR0007 //"*** CANCELADO PELO OPERADOR ***"
      EndIf   
      Exit
   Endif
      
   If ValType(VE6->VE6_GRUITE) == ValType(MV_PAR05) .and. ValType(VE6->VE6_GRUITE) == ValType(MV_PAR06)
	   If VE6->VE6_GRUITE < MV_PAR05 .or. VE6->VE6_GRUITE > MV_PAR06
		   VE6->(dbSkip())
		   Loop
	   EndIf
   EndIf

   If ValType(VE6->VE6_CODMOT) == ValType(MV_PAR03) .and. ValType(VE6->VE6_CODMOT) == ValType(MV_PAR04)
	   If VE6->VE6_CODMOT < MV_PAR03 .or. VE6->VE6_CODMOT > MV_PAR04
		   VE6->(dbSkip())
		   Loop	   
	   EndIf
   EndIf
	
	If !lReport
	   If nLin > 55
	      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	      nLin := 8
	   Endif
   Endif

	VAI->(DbSeek(xFilial("VAI")+VE6->VE6_CODUSU))
	SA3->(DbSeek(xFilial("SA3")+VAI->VAI_CODVEN))
   VE7->(DbSeek(xFilial("VE7")+VE6->VE6_INDREG+VE6->VE6_CODMOT))
         
	If !lReport
	
	   @nLin,000 PSAY Iif(!Empty(VE6->VE6_NUMOSV),VE6->VE6_NUMOSV,VE6->VE6_NUMORC)
	   @nLin,009 PSAY Left(SA3->A3_NOME,34)
	   @nLin,044 PSAY VE6->VE6_GRUITE+"-"+VE6->VE6_CODITE
	   @nLin,077 PSAY Transform(VE6->VE6_QTDITE,"999999")
	   @nLin,085 PSAY Transform(VE6->VE6_VALPEC,"@E 9,999,999.99")   
	   @nLin,098 PSAY VE6->VE6_CODMOT+"-"+VE7->VE7_DESMOT
	
	   nLin := nLin + 1
	     
	Else
	
	   oReport:IncMeter()
		If oReport:Cancel()
			Exit
		EndIf
		    
//		If oReport:PageBreak()
//			oSection1:PrintHeader()
			oReport:Section(1):Init()
			oReport:Section(1):PrintLine()
//		EndIf

	EndIf   
	   
   If !lReport
      IncRegua()
   EndIf
   
   VE6->(dbSkip())

EndDo

If !lReport

	If nLin # 80
		Roda(,,tamanho)
	EndIf      

	SET DEVICE TO SCREEN
	
	//���������������������������������������������������������������������Ŀ
	//� Se impressao em disco, chama o gerenciador de impressao...          �
	//�����������������������������������������������������������������������
	
	If aReturn[5]==1
	   dbCommitAll()
	   SET PRINTER TO
	   OurSpool(wnrel)
	Endif
	
	MS_FLUSH()

Else

	oSection1:Finish()
		
EndIf      

Return
