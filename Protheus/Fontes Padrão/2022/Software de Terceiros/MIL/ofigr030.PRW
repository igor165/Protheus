#INCLUDE "OFIgr030.ch"

#INCLUDE "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �OFIGR030  � Autor � Ricardo Farinelli  � Data �  05/07/01   ���
�������������������������������������������������������������������������͹��
���Descricao � Relatorio de Reclamacoes nao Transmitidas (Scania)         ���
�������������������������������������������������������������������������͹��
���Uso       � Gestao de Concessionarias                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function OFIGR030()

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������

Local aOrd           := {}
Local cDesc1         := STR0001 // //"Este programa tem como objetivo imprimir a posicao de "
Local cDesc2         := STR0002 // //"das Reclamacoes nao Transmitidas. (Scania)"
Local cDesc3         := ""
Local cPict          := ""
Local imprime        := .T.
Local wnrel          := "OFIGR030"
Local cString        := "VG8"
Local cIndice        := ""
Local cChave         := ""
Local cCondicao      := ""
Local nIndice 		   := 0
Local cMontadora     := ""

Private titulo       := STR0003 // //"Relclamacoes nao Transmitidas - Scania"
Private nLin         := 80
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 080
Private tamanho      := "P"
Private Cabec1       := STR0004 // //" [Nro.OS] [Dt.Abe] [Ch.I] [Chassi do Veiculo------] [Modelo-------------------]"
Private Cabec2       := STR0005 // //"          [Dt.Abe] [Ano]  [Nr.RR] [Dt.Lib] [Vlr Pec.] [Vlr Srv.]"
Private nTipo        := 18
Private aReturn      := {STR0006, 1,STR0007, 1, 2, 1, "", 1}    //### //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private cPerg        := "OGR030"
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01

//ValidPerg()

pergunte(cPerg,.F.)

wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)

DbSelectArea("VG8")

cMontadora := Fg_Marca("SCANIA",,.F.) // Traz o codigo de montadora padrao da Volkswagem
cIndice    := CriaTrab(nil,.F.)

cCondicao += "VG8_CODMAR=='"+cMontadora+"' .and. Empty(VG8_RRCNEW) .and. Empty(VG8_EXCLUI) .and. VG8_TRANSM=='N' .and. VO1->(dbseek(xFilial('VO1')+VG8->VG8_NUMOSV))" 

If !Empty(MV_PAR01)
  cCondicao += ".and. DTOS(VO1->VO1_DATABE)>='"+DTOS(MV_PAR01)+"'"
Endif
  
If !Empty(MV_PAR02)
  cCondicao += ".and. DTOS(VO1->VO1_DATABE) <='"+DTOS(MV_PAR02)+"'"
Endif

cChave := "VG8_FILIAL+VG8_CODMAR+VG8_NUMOSV+DTOS(VG8_ABEGAR)"

IndRegua("VG8",cIndice,cChave,,cCondicao,STR0008) // //"Aguarde Selecionando Registro para Impressao"

DbSelectArea("VG8")
nIndice := RetIndex("VG8")
#IFNDEF TOP
   dbSetIndex(cIndice+ordBagExt())
#ENDIF
dbSetOrder(nIndice+1)

RptStatus({|lEnd| OFIG030IMP(@lEnd,wnrel,cString)},Titulo)

DbSelectArea("VG8")
RetIndex()

#IFNDEF TOP
   If File(cIndice+OrdBagExt())
      fErase(cIndice+OrdBagExt())
   Endif
#ENDIF

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    �OFIG030IMP� Autor � Ricardo Farinelli  � Data �  06/07/01   ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao auxiliar para a impressao do relatorio              ���
�������������������������������������������������������������������������͹��
���Uso       � Gestao de Concessionarias                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function OFIG030IMP(lEnd,wnrel,cString)

Local aTotais  := {} // Vetor totalizado
Local cNumos   := ""
Local nWnk     := 0
aTotais := Array(1,4)
For nwnk := 1 To len(aTotais[1])
  aTotais[1,nwnk] := 0
Next

//�������������������������������������������������Ŀ
//�Posicao 1 - Total da OS - pecas                  �
//�Posicao 2 - Total da OS - servicos               �
//�Posicao 3 - Total geral - pecas                  �
//�Posicao 4 - Total geral - servicos               �
//���������������������������������������������������

/*
//��������������������������������������������������������������������������������������������������������
//�MV_PAR01 = Data Inicial - Data de inicio ou branco para desde o comeco                                �
//�MV_PAR02 = Data Final - Data final para o escopo do relatorio                                         �
//��������������������������������������������������������������������������������������������������������
*/

DbselectArea("VG8")

SetRegua(RecCount())

Titulo +=STR0009+dToc(MV_PAR01) //" de "
Titulo +=STR0010+dToc(MV_PAR02) //" a "

If nLin > 58 //imprime cabecalho quando relatorio em branco
   Cabec(Titulo,Cabec1,Cabec2,wnrel,Tamanho,nTipo)
   nLin := 9
Endif

DbSeek(xFilial("VG8"))
Do While VG8->VG8_FILIAL == xFilial("VG8") .and. !VG8->(Eof())

  cNumos := VG8->(VG8_FILIAL+VG8_CODMAR+VG8_NUMOSV)

  If lAbortPrint .or. lEnd
    @nLin,00 PSAY STR0009 // //"*** CANCELADO PELO OPERADOR ***"
    Exit
  Endif

  If nLin > 58
    Cabec(Titulo,Cabec1,Cabec2,wnrel,Tamanho,nTipo)
    nLin := 9
  Endif

  VV1->(DbSetOrder(1))
  VV1->(Dbseek(xFilial("VV1")+VG8->VG8_CHAINT))
  VO1->(DbSetOrder(1))                                                               	
  VO1->(Dbseek(xFilial("VO1")+VG8->VG8_NUMOSV))

  @ nLin,001 PSAY VO1->VO1_NUMOSV
  @ nLin,010 PSAY VO1->VO1_DATABE
  @ nLin,019 PSAY VO1->VO1_CHAINT
  @ nLin,026 PSAY VV1->VV1_CHASSI
  @ nLin,053 PSAY Substr(VV1->VV1_MODVEI,1,27)
  nLin++
  If nLin > 58
    Cabec(Titulo,Cabec1,Cabec2,wnrel,Tamanho,nTipo)
    nLin := 9
  Endif
  // zera variaveis de total da OS
  For nwnk := 1 To 2
    aTotais[1,nwnk] := 0
  Next

  Do While VG8->(VG8_FILIAL+VG8_CODMAR+VG8_NUMOSV) == cNumos .and. !VG8->(Eof())
	  aTotais[1,1] += VG8->VG8_VALITE
		aTotais[1,2] += VG8->VG8_VALSER	  
		aTotais[1,3] += VG8->VG8_VALITE
	  aTotais[1,4] += VG8->VG8_VALSER	  

    @ nLin,010 PSAY VG8->VG8_ABEGAR
    @ nLin,019 PSAY VG8->VG8_ANORRC
    @ nLin,026 PSAY VG8->VG8_NUMRRC
	  @ nLin,034 PSAY VG8->VG8_DATDIS
	  @ nLin,043 PSAY Transform(VG8->VG8_VALITE,"@E 999,999.99")
	  @ nLin,054 PSAY Transform(VG8->VG8_VALSER,"@E 999,999.99")
	  nLin++
	  If nLin > 58
	    Cabec(Titulo,Cabec1,Cabec2,wnrel,Tamanho,nTipo)
	    nLin := 9
	  Endif
    VG8->(dbskip())
    If VG8->VG8_NUMOSV<>Right(cNumos,8)
		  @ nLin,035 PSAY STR0010 // //"Total.: "
  	  @ nLin,043 PSAY Transform(aTotais[1,1],"@E 999,999.99")
	    @ nLin,054 PSAY Transform(aTotais[1,2],"@E 999,999.99")
		  nLin++
		  If nLin > 58
	  	  Cabec(Titulo,Cabec1,Cabec2,wnrel,Tamanho,nTipo)
	    	nLin := 9
		  Endif
		  For nwnk := 1 to 2
			  aTotais[1,nwnk] := 0
		  Next 
    Endif
  Enddo
Enddo
@ nLin,022 PSAY STR0011 // //"Total do Relatorio.: "
@ nLin,043 PSAY Transform(aTotais[1,3],"@E 999,999.99")
@ nLin,054 PSAY Transform(aTotais[1,4],"@E 999,999.99")

//���������������������������������������������������������������������Ŀ
//� Finaliza a execucao do relatorio...                                 �
//�����������������������������������������������������������������������

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

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    �VALIDPERG � Autor � Ricardo Farinelli  � Data �  05/07/01   ���
�������������������������������������������������������������������������͹��
���Descri��o � Verifica a existencia das perguntas criando-as caso seja   ���
���          � necessario (caso nao existam).                             ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
/*
Static Function ValidPerg

Local _sAlias := Alias()
Local aRegs := {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

aAdd(aRegs,{cPerg,"01",STR0012,"","","mv_ch1","D", 08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})  //"Data Inicial      ?"
aAdd(aRegs,{cPerg,"02",STR0013,"","","mv_ch2","D", 08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""}) //"Data Final        ?"

For i:=1 to Len(aRegs)
    If !dbSeek(cPerg+aRegs[i,2])
        RecLock("SX1",.T.)
        For j:=1 to FCount()
            If j <= Len(aRegs[i])
                FieldPut(j,aRegs[i,j])
            Endif
        Next
        MsUnlock()
    Endif
Next

dbSelectArea(_sAlias)

Return
*/
