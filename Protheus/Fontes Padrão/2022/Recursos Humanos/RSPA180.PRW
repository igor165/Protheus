#include "Protheus.ch"
#include "Rspa180.ch"

/*/
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Programa  � RSPA180  � Autor � Emerson Grassi Rocha         � Data � 16/05/01 ���
��������������������������������������������������������������������������������Ĵ��
���Descri��o � DownLoad em arquivos de Curriculo em Servidor FTP.                ���
��������������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                            ���
��������������������������������������������������������������������������������Ĵ��
���DATA      � Programador  � BOPS �Manutencao Efetuada                          ���
��������������������������������������������������������������������������������Ĵ��
���29/07/2014�Cecilia C.    �TQENN4�Incluido o fonte da 11 para a 12 e efetuada  ���
���          �              �      �a limpeza.                                   ���
��� 10/11/14 �Renan Borges  �TQUGT7 �Ajuste para realizar o Download corretamente��� 
���          �              �       �quando o caminho informado n�o possui as    ���
���          �              �       �barras, o sistema entender� como se fosse um���
���          �              �       �caminho do servidor (RootPath).             ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������*/
Function RSPA180()

Local cServer   := Alltrim(GETMV("MV_RSPFTPS"))
Local cFile		:= ""		
Local cDir		:= Alltrim(PADR(GETMV("MV_RSPDCUR"),30))
Local aFiles    := {}  
Local oButton1, oButton2, oButton3

//��������������������������������������������������������������Ŀ
//� Declara��o de arrays para dimensionar tela		                         �
//����������������������������������������������������������������
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aAdv1Size		:= {}
Local aInfo1AdvSize	:= {}
Local aObj1Size		:= {}	
Local aObj1Coords 	:= {}
Local aAdv2Size		:= {}
Local aInfo2AdvSize	:= {}
Local aObj2Size		:= {}	
Local aObj2Coords 	:= {}
Local aAdv3Size		:= {}
Local aInfo3AdvSize	:= {}
Local aObj3Size		:= {}	
Local aObj3Coords 	:= {}

Private lConnected := .F.
Private oLbx

If Subs(cDir,Len(cDir)) <> "/" .AND. Subs(cDir,Len(cDir)) <> "\"
	If IsSrvUnix()
		cDir := cDir + "/"
	Else
		cDir := cDir + "\"
	EndIf
EndIf

DoConnect(cServer, @cFile, @aFiles)

/*
��������������������������������������������������������������Ŀ
� Monta as Dimensoes dos Objetos         					   �
����������������������������������������������������������������*/
aAdvSize		:= MsAdvSize(, .T., 390)
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }					 
aAdd( aObjCoords , { 000 , 020 , .T. , .F. } )
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )

aAdv1Size    := aClone(aObjSize[1])
aInfo1AdvSize    := { aAdv1Size[2] , aAdv1Size[1] , aAdv1Size[4] , aAdv1Size[3] , 5 , 5 }
aAdd( aObj1Coords , { 100 , 000 , .T. , .T. } )
aAdd( aObj1Coords , { 040 , 000 , .F. , .T. } )
aAdd( aObj1Coords , { 100 , 000 , .T. , .T. } )
aObj1Size := MsObjSize( aInfo1AdvSize , aObj1Coords,,.T. )

aAdv2Size    := aClone(aObjSize[2])
aInfo2AdvSize    := { aAdv2Size[2] , aAdv2Size[1] , aAdv2Size[4] , aAdv2Size[3] , 5 , 5 }
aAdd( aObj2Coords , { 000 , 000 , .T. , .T. } )
aAdd( aObj2Coords , { 002 , 000 , .F. , .T. } )
aAdd( aObj2Coords , { 050 , 000 , .F. , .T. } )
aObj2Size := MsObjSize( aInfo2AdvSize , aObj2Coords,,.T. )

aAdv3Size    := aClone(aObj2Size[1])
aInfo3AdvSize    := { aAdv3Size[2] , aAdv3Size[1] , aAdv3Size[4] , aAdv3Size[3] , 5 , 5 }
aAdd( aObj3Coords , { 000 , 000 , .T. , .T., .T. } )
aObj3Size := MsObjSize( aInfo3AdvSize , aObj3Coords,,.T. ) 

DEFINE MSDIALOG oDlg TITLE STR0001 FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL //"DownLoad"
                                     
	@aObj1Size[2,1], aObj1Size[2,2] BITMAP oBitmap RESOURCE "LOGOSIGA" SIZE 200,130 Of oDlg PIXEL NOBORDER
	
	@aObj3Size[1,1]-10, aObjSize[1,2]+10 SAY STR0002 PIXEL OF oDlg //"Arquivos:"
	
	@aObj3Size[1,1], aObj3Size[1,2] LISTBOX oLbx VAR cFile ITEMS aFiles PIXEL SIZE aObj3Size[1,3],aObj3Size[1,4] OF oDlg
	
	@aObj2Size[3,1], aObj2Size[3,2] BUTTON oButton1 PROMPT "&"+STR0003 SIZE 44, 11 OF oDlg PIXEL ; //"Baixar Arq."
			ACTION DoDownLoad(cServer, cFile, cDir, aFiles, 1)

	@aObj2Size[3,1]+15, aObj2Size[3,2] BUTTON oButton1 PROMPT "&"+STR0015 SIZE 44, 11 OF oDlg PIXEL ; //"Baixar Todos"
			ACTION DoDownLoad(cServer, cFile, cDir, aFiles, 2)
	
	@aObj2Size[3,1]+30, aObj2Size[3,2] BUTTON oButton2 PROMPT "&"+STR0011 SIZE 44, 11 OF oDlg PIXEL ; //"Diretorio"
			ACTION Rs180Dir(@cDir)
			
	@aObj2Size[3,1]+45, aObj2Size[3,2] BUTTON oButton3 PROMPT "&"+STR0004 SIZE 44, 11 OF oDlg PIXEL ; //"Sair"
			ACTION (DoDisconnect(), oDlg:End())

ACTIVATE DIALOG oDlg CENTERED

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � DoConnect � Autor � Emerson Grassi Rocha � Data � 16/05/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Conecta ao Servidor FTP.                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : cServer - Nome do Servidor FTP.                    ���
���          � ExpC2 : cFile - Nome do Arquivo Selecionado para Baixar.   ���
���          � ExpA1 : aFiles - Array contendo arquivos do diretorio FTP. ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Rspa180       �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Static Function DoConnect(cServer, cFile, aFiles)

Local cUser	:= Alltrim(GetMv("MV_RSPFTPU"))
Local cSenha:= Alltrim(GETMv("MV_RSPFTPP"))

cUser 	:= IIf(Empty(cUser), Nil, cUser)
cSenha	:= IIf(Empty(cSenha), Nil, cSenha)

If lConnected
	Aviso( "", OemToAnsi(STR0005), {"OK"} )	//"Ja existe uma conexao ativa com um servidor FTP"
	Return .F.
Endif

//��������������������������������������������������������������Ŀ
//�  Vari�vel Global identificadora da exist�ncia de um FireWall �
//����������������������������������������������������������������
lFireWall := .F.

//����������������������������
//�  Conecta ao Servidor FTP �
//����������������������������
lConnected := FTPConnect(cServer,,cUser,cSenha)

If !lConnected
	Aviso( "", OemToAnsi(STR0006), {"OK"} )	//"Falha de conex�o ao servidor FTP. Verifique se os parametros MV_RSPFTP... estao configurados corretamente."
Else
	DoRefresh(@cFile,@aFiles)
Endif

Return lConnected

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � DoRefresh � Autor � Emerson Grassi Rocha � Data � 16/05/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Atualiza lista de arquivos do Servidor FTP.                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : cFile - Nome do Arquivo Selecionado para Baixar.   ���
���          � ExpA1 : aFiles - Array contendo arquivos do diretorio FTP. ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Rspa180       �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Static Function DoRefresh(cFile, aFiles)
Local aList,i

If !lConnected
	Return .F.
Endif

//��������������������������������Ŀ
//�  Informa diretorio do Servidor �
//����������������������������������
lDir 	:= FTPDirChange (GETMV("MV_RSPFTPD"))
If ! lDir
	Aviso( "", OemToAnsi(STR0013), {"OK"} )	//"Falha de conex�o. Verifique se o parametro MV_RSPFTPD esta configurado corretamente."
	Return .F.
EndIf

//�����������������������������������Ŀ
//� Lista todos arquivos do Diretorio �
//�������������������������������������
aList  	:= FTPDirectory ( "*.*" )

If Len(aList) == 0
	Aviso( "", OemToAnsi(STR0014), {"OK"} )	//"Nao existe nenhum arquivo no Servidor!"
	Return .F.
EndIf

//����������������������������������������������Ŀ
//� Armazena apenas o nome dos arquivos no array �
//������������������������������������������������
For i := 1 To Len(aList)
	aAdd(aFiles,aList[i,1])
Next i

cFile := aList[1,1]

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �DoDisconnect� Autor � Emerson Grassi Rocha � Data �16/05/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Desconecta do Servidor FTP.                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� 											                  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Rspa180       �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Static Function DoDisconnect()

If !lConnected
	Return .F.
Endif
                 
lConnected := !FTPDisconnect()

If lConnected
	Aviso( "", OemToAnsi(STR0007), {"OK"} )	//"Falha ao tentar desconectar"
Endif

Return lConnected


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � DoDownLoad� Autor � Emerson Grassi Rocha � Data � 16/05/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Atualiza lista de arquivos do Servidor FTP.                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : cServer - Nome do Servidor FTP.                    ���
���          � ExpC1 : cFile - Nome do Arquivo Selecionado para Baixar.   ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Rspa180       �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Static Function DoDownLoad(cServer,cFile,cDir,aFiles,nTipo)

Local lRet, lRet2
Local cDir2      
Local i
Local aFilesDown 	 := {}//variavel ponto entrada RSP18001, contem arquivos baixados
Local lRSP18001Block  := ExistBlock( "RSP18001")//variavel para ponto de entrada RSP18001

If !lConnected
	Aviso( "", OemToAnsi(STR0008), {"OK"} )	//"Nao conectado a um servidor FTP"
	Return .F.
Endif

If nTipo == 1	//Unico arquivo
	cDir := Alltrim(cDir)+cFile
	MsgRun(STR0018+cFile,,{||lRet := FTPDownLoad(cDir, cFile)}) // "Aguarde... Realizando Download do arquivo "
	If lRet  
	 	Aviso( "", OemToAnsi(STR0009), {"OK"} )	//"Arquivo Baixado com Sucesso."
		aAdd(aFilesDown, cFile)//adiciona arquivo baixado no array auxiliar
	Else 
		Aviso( "", OemToAnsi(STR0010), {"OK"} )	//"Arquivo Nao foi Baixado!"
	EndIf                      
	
Else			//Varios Arquivos
	lRet2 := .T.
	For i := 1 to Len(aFiles)
		cDir2 	:= Alltrim(cDir)+aFiles[i]
		MsgRun(STR0018+aFiles[i],,{||lRet := FTPDownLoad(cDir2,aFiles[i])}) // "Aguarde... Realizando Download do arquivo "
		If !lRet
			lRet2 := .F.
		Else
			aAdd(aFilesDown, aFiles[i])//adiciona arquivos baixados com sucesso no array auxiliar		
		EndIf
	Next i

	If lRet2  
	 	Aviso( "", OemToAnsi(STR0016), {"OK"} )	//"Arquivos Baixados com Sucesso."
	Else 
		Aviso( "", OemToAnsi(STR0017), {"OK"} )	//"Um ou mais Arquivos Nao foram Baixados!"
	EndIf                      
EndIf
 
//Se nTipo=1, executa PE se conseguiu baixar o XML com sucesso (lRet=.T.)
//Se nTipo=2, executa PE se conseguiu baixar algum dos XMLs (aFilesDown>0)
IF ( nTipo == 1 .And. lRet ) .Or. ( nTipo == 2 .And. ( Len(aFilesDown)>0 ) ) 
	/*��������������������������������������������������������������Ŀ
	� Ponto de Entrada para exclusao de XMLs		               �
	����������������������������������������������������������������*/
	IF (  lRSP18001Block )
			ExecBlock("RSP18001",.F.,.F.,{cServer,cFile,cDir,aFiles,aFilesDown,nTipo,lRet,lRet2}) 
	EndIF
EndIF

Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � Rs180Dir  � Autor � Emerson Grassi Rocha � Data � 21/05/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Seleciona Diretorio Local para gravacao de arquivo XML.	  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : cDir - Nome do Diretorio Padrao.		              ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Rspa180       �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Static Function Rs180Dir(cDir)

Local nPos		:= 0
Local nPos1		:= 0
Local nPos2		:= 0

nPos1 := AT("\",cDir)+1		//Padrao
nPos2 := AT("/",cDir)+1		//Linux

nPos := Max(nPos1,nPos2)

If nPos < 4
	cDir := Alltrim(Subs(cDir,nPos,Len(cDir)))
EndIf

If Subs(cDir,Len(cDir)) <> "/" .AND. Subs(cDir,Len(cDir)) <> "\"
	If IsSrvUnix()
		cDir := cDir + "/"
	Else
		cDir := cDir + "\"
	EndIf
EndIf

cDir:= cGetFile(,OemToAnsi(STR0012),0,"SERVIDOR\"+cDir,.T.,GETF_RETDIRECTORY) //"Selecione um Diretorio"
If Empty(cDir)
	Return .F.
EndIf     

Return .T.
