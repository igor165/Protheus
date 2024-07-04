#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "GPER807.ch"

/*/
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������ͻ��
���Programa  � GPER807    � Autor � Ademar Fernandes     � Data �  04/03/10   ���
�����������������������������������������������������������������������������͹��
���Descricao � Relatorio de Conferencia do PDT Peru                           ���
���          �                                                                ���
�����������������������������������������������������������������������������͹��
���Uso       � Localizacao Peru                                               ���
�����������������������������������������������������������������������������͹��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                 ���
�����������������������������������������������������������������������������͹��
���Programador � Data   � FNC      � Motivo da Alteracao                      ���
�����������������������������������������������������������������������������͹��
���Leandro Dr. �16/03/12�    TEPNM0�Inclusao de help nos perguntes.           ���
���            �        �          �                                          ���
���Jonathan Glz�07/05/15�PCREQ-4256�Se elimina funcion ValidPerg la cual      ���
���            �        �          �realiza la modificacion a diccionario de  ���
���            �        �          �datos(SX1) por motivo de adecuacion nueva ���
���            �        �          �estructura de SXs para V12                ���
���            �        �          �                                          ���
�����������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
/*/
Function GPER807()
//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
Local cDesc1    := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2    := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3    := STR0007	//"Relatorio de Conferencia do PDT Peru"
Local cPict     := ""
Local Titulo    := STR0007	//"Relatorio de Conferencia do PDT Peru"
Local nLin		  := 80
Local Cabec1	  := STR0011	//"Nome do arquivo: "
Local Cabec2	  := ""
Local imprime	  := .T.
Local aOrd 	  := {}
Local cPerg 	  := "GPR807"

Private lEnd        := .F.
Private lAbortPrint := .F.
Private Limite      := 220
Private Tamanho     := "G"
Private nomeprog    := "GPER807" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo       := 15
Private aReturn     := { STR0003, 1, STR0004, 2, 2, 1, "", 1}	 //"Zebrado"###"Administracao"
Private nLastKey    := 0
Private cbtxt       := Space(10)
Private cbcont      := 00
Private CONTFL      := 01
Private m_pag       := 01
Private wnrel       := "GPER807" // Coloque aqui o nome do arquivo usado para impressao em disco

Private cString := "SRA"

dbSelectArea("SRA")
dbSetOrder(1)

Pergunte(cPerg,.F.)

//���������������������������������������������������������������������Ŀ
//� Monta a interface padrao com o usuario...                           �
//�����������������������������������������������������������������������
wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)
If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)
If nLastKey == 27
	Return
Endif

/*
Parametros da Rotina
MV_PAR01 - Data Base das Informacoes
MV_PAR02 - Diretorio a ser gravado os arquivos
*/
cAno	:= mv_par01
cDir	:= Alltrim(mv_par02)+"\"
cDir	:= StrTran(cDir,"\\","\")
cFiles	:= cDir+"*.*"
aFiles	:= Directory(cFiles)

//���������������������������������������������������������������������Ŀ
//� Inicializa a regua de processamento                                 �
//�����������������������������������������������������������������������
If Len(aFiles) > 0
	Processa({|| RunCont(Titulo,Cabec1,Cabec2,nLin,cDir,aFiles) },STR0006)	//"Aguarde, Processando ..."
EndIf

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
���Fun��o    � RUNCONT  � Autor � AP5 IDE            � Data �  09/03/10   ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao auxiliar chamada pela PROCESSA.  A funcao PROCESSA  ���
���          � monta a janela com a regua de processamento.               ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function RunCont(Titulo,Cabec1,Cabec2,nLin,cDir,aFiles)

Local nX
Local nTamFile, nTamLin, cBuffer, nBtLidos

Private nHdl    := 0
Private cEOL    := "CHR(13)+CHR(10)"

If Empty(cEOL)
	cEOL := CHR(13)+CHR(10)
Else
	cEOL := Trim(cEOL)
	cEOL := &cEOL
Endif

For nX := 1 to Len(aFiles)

	nHdl := fOpen(cDir+aFiles[nX,01],0)

	If nHdl == -1
		MsgAlert(STR0009+aFiles[nX,01]+STR0010,STR0008)	//"O arquivo de nome "###" n�o pode ser aberto! Verifique os parametros."###"Aten��o!"
		Return
	Endif

	//���������������������������������������������������������������������Ŀ
	//� Carrega o arquivo 1 vez pra saber o tamanho das linhas              �
	//�����������������������������������������������������������������������
	nTamFile := fSeek(nHdl,0,2)
	fSeek(nHdl,0,0)	//Posiciona no inicio do arquivo
	nTamLin  := 1000+Len(cEOL)
	cBuffer  := Space(nTamLin)
	nBtLidos := fRead(nHdl,@cBuffer,nTamLin) // Leitura da primeira linha do arquivo texto

	//���������������������������������������������������������������������Ŀ
	//� Carrega o arquivo outra vez para executar a impressao               �
	//�����������������������������������������������������������������������
	fSeek(nHdl,0,0)	//Posiciona no inicio do arquivo
	nTamLin  := AT(cEOL,cBuffer) + Len(cEOL) - 1
	cBuffer  := Space(nTamLin)
	nBtLidos := fRead(nHdl,@cBuffer,nTamLin) // Leitura da primeira linha do arquivo texto

	nLin := 80
	Cabec1 := STR0011 + aFiles[nX,01]	//"Nome do arquivo: "
	ProcRegua(nTamFile) // Numero de registros a processar

	While nBtLidos >= nTamLin

		//���������������������������������������������������������������������Ŀ
		//� Incrementa a regua                                                  �
		//�����������������������������������������������������������������������
		IncProc()

		//���������������������������������������������������������������������Ŀ
		//� Verifica o cancelamento pelo usuario...                             �
		//�����������������������������������������������������������������������
		If lAbortPrint
			@nLin,001 PSAY STR0005 //"*** CANCELADO PELO OPERADOR ***"
			Return
		Endif

		If nLin > 70 // Salto de P�gina. Neste caso o formulario tem 70 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
		Endif

		@nLin,001 PSAY cBuffer

		nLin += 1

		//���������������������������������������������������������������������Ŀ
		//� Leitura da proxima linha do arquivo texto.                          �
		//�����������������������������������������������������������������������
		nBtLidos := fRead(nHdl,@cBuffer,nTamLin) // Leitura da proxima linha do arquivo texto

		dbSkip()
	EndDo

	//���������������������������������������������������������������������Ŀ
	//� O arquivo texto deve ser fechado, bem como o dialogo criado na fun- �
	//� cao anterior.                                                       �
	//�����������������������������������������������������������������������
	fClose(nHdl)

Next nX

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � GetDir   �Autor  � Ademar Fernandes   � Data � 16/01/2010  ���
�������������������������������������������������������������������������͹��
���Desc.     � Usado na funcao principal                                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Localizacao Peru                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GetDir()
Local cDirPesq
Local cCpo     := readvar()

cDirPesq := cGetFile( STR0012,STR0013,,"C:\",.T.,GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_RETDIRECTORY)	//"Arquivo Texto"###"Ler do Diretorio"
If Len(cDirPesq) = 0
	cDirPesq := "C:\"
EndIf
&(cCpo) := cDirPesq
Return(.T.)
