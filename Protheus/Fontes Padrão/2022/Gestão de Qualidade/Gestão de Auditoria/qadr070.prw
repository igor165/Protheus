#Include "QADR070.CH"
#Include "PROTHEUS.CH"


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QADR070  � Autor � Leandro S. Sabino     � Data � 19/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Emiss�o da Rela��o dos Departamentos		                  ���
�������������������������������������������������������������������������Ĵ��
���Obs:      � (Versao Relatorio Personalizavel) 		                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADR070	                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/
Function QADR070()
Local oReport
Private cPerg	:= "QAD070"

If TRepInUse()
	Pergunte(cPerg,.F.) 
    oReport := ReportDef()
    oReport:PrintDialog()
Else
	QADR070R3() //Executa vers�o anterior do fonte
EndIf
              
Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ReportDef()   � Autor � Leandro Sabino   � Data � 19.05.06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Montar a secao				                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportDef()				                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADR070                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()
Local oReport 
Local oSection1 
Local oSection2 
Local oCell
Local aOrdem    := {}
Local oTotaliz

Aadd( aOrdem, STR0008 )//'Codigo Departamento' 
Aadd( aOrdem, STR0009 )//'Filial Usuario + Usuario Responsavel' 

oReport   := TReport():New("QADR070" ,OemToAnsi(STR0001),"QAD070",{|oReport| RF070Imp(oReport)},OemToAnsi(STR0003)+OemToAnsi(STR0004))
//"Relacao de Departamentos"##"Ira imprimir os dados referentes aos Departamentos,"##"de acordo com a configuracao do usuario."

oSection1 := TRSection():New(oReport,STR0013,{"QAD"},aOrdem) //"Ira imprimir os dados referentes aos Departamentos," //"Departamento"   
TRCell():New(oSection1,"QAD_CUSTO" ,"QAD",,,15)
TRCell():New(oSection1,"QAD_DESC"  ,"QAD",,,30)
TRCell():New(oSection1,"QAD_STATUS","QAD")
TRCell():New(oSection1,"QAD_FILMAT","QAD",,,4)
TRCell():New(oSection1,"QAD_MAT"   ,"QAD")


oTotaliz  := TRFunction():New(oSection1:Cell("QAD_CUSTO"),"COUNT_1" ,"COUNT",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)

oTotal := TRSection():New(oReport,STR0014,{},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/) // "Totalizador"    
oTotal:SetHeaderSection()
TRCell():New(oTotal,OemToAnsi(STR0011),"   ",OemToAnsi(STR0012),"@E 99,999,999",20,/*lPixel*/,/*{|| code-block de impressao }*/) //Campo##"Total de Registros Impressos"

Return oReport



/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � RF070Imp      � Autor � Leandro Sabino   � Data � 19.05.06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Imprimir os campos do relatorio                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � RF070Imp(ExpO1)   	     	                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADR070                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function RF070Imp(oReport)               
Local oSection   := oReport:Section(1)
Local oSection2  := oReport:Section(1):Section(1)

DbSelectArea("QAD")

If oSection:nOrder == 1
	dbSetOrder(1)
	DbSeek(xFilial()+MV_PAR01,.T.)
	cInicio  := "QAD->QAD_FILIAL+QAD->QAD_CUSTO"
	cFim	 := xFilial("QAD")+AllTrim(MV_PAR02)
Else
	dbSetOrder(2)
	DbSeek(MV_PAR01,.T.)
	cInicio  := "QAD->QAD_FILMAT+QAD->QAD_CUSTO
	cFim	 := xFilial("QAD")+AllTrim(MV_PAR02)
Endif

oSection:Init()

While QAD->(!Eof()) .And. &(cInicio) <= cFim
	If oReport:Cancel()
		Exit
	EndIf
	oSection:PrintLine()               
	DbSelectArea("QAD")
    dbSKip()
End

/*������������������������Ŀ
//�Impressao do totalizador�
//��������������������������*/
oReport:Section(2):Init()
oReport:Section(2):Cell(OemToAnsi(STR0011)):SetValue(oReport:Section(1):GetFunction("COUNT_1"):ReportValue())//Campo
oReport:Section(2):PrintLine()     
oReport:Section(2):Finish()
oSection:Finish()

Return



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QADR070  � Autor � Paulo Emidio de Barros� Data �15/09/2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Emiss�o da Rela��o dos Departamentos						  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QADR070(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
���				 �		  � 	 �										  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QADR070R3()
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
Local CbCont
Local cabec1
Local cabec2
Local cabec3
Local wnrel
Local tamanho := "M"
Local limite  := 132
Local titulo  := OemToAnsi(STR0001) //"Relacao de Departamentos"
Local cDesc1  := OemToAnsi(STR0002) //"Emissao do Cadastro de Departamentos"
Local cDesc2  := OemToAnsi(STR0003) //"Ira imprimir os dados referentes aos Departamentos,"
Local cDesc3  := OemToAnsi(STR0004) //"de acordo com a configuracao do usuario."
Local aOrd    := {}

Private aReturn  := { OemToAnsi(STR0005), 1,OemToAnsi(STR0006), 2, 2, 1, "",1 }  //"Zebrado" ### "Administracao"
Private aLinha   := { }
Private nomeprog := "QADR070"
Private nLastKey := 0

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape    �
//����������������������������������������������������������������
cbcont   := 0
cabec1   := OemToAnsi(STR0007) //"Relacao do Cadastro de Departamentos"
cabec2   := Replicate("-",limite)
cabec3   := " "
cString  := "QAD"
aOrd     := {OemToAnsi(STR0008),OemToAnsi(STR0009)} //"Codigo Departamento" ### "Filial Usuario+Usuario Responsavel"
wnrel    := "QADR070"

Private aParDef := {}

wnrel := SetPrint(cString,wnrel,"ParamDef(cAlias)",@Titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,,tamanho)

If nLastKey = 27
    Set Filter To
    Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Set Filter To
    Return
Endif

RptStatus({|lEnd|QadR070Imp(@lEnd,Cabec1,Cabec2,Cabec3,limite,tamanho,cbCont,wnrel)},Titulo)

Return(NIL)
 
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QadR070Imp� Autor � Paulo Emidio de Barros� Data �15/09/2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada do Relatorio                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADR070                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function QadR070Imp(lEnd,Cabec1,Cabec2,Cabec3,limite,tamanho,cbCont,wnrel)
li    := 80
m_pag := 1
cbtxt := Space(10)

//��������������������������������������������������������������Ŀ
//� Monta Array para identificacao dos campos dos arquivos       �
//����������������������������������������������������������������
If Len(aReturn) > 8
	Mont_Dic(cString)
Else
	Mont_Array(cString)
Endif

ImpCadast(Cabec1,Cabec2,Cabec3,NomeProg,Tamanho,Limite,cString,@lEnd)

If li != 80
	Roda(cbcont,cbtxt,"M")
Endif

DbSelectArea("QAD")
Set Filter To

If aReturn[5] = 1
	Set Printer To 
	DbCommitAll()
	OurSpool(wnrel)
Endif

Ms_Flush()

Return(NIL)
