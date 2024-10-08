#INCLUDE "HSPAHP32.ch"
#include "protheus.CH"  
#include "MSOLE.CH" 
#Include "Fileio.ch"
#include "colors.CH"
#Define F_BLOCK 512
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHP32  � Autor � Jos� Orfeu                �  02/09/2002 ���
�������������������������������������������������������������������������͹��
���Descricao � Digita��o de Modelos                                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HSPAHP32()
 Private bCampo   := { |nCPO| Field(nCPO) }
 Define  FONT oFont NAME "Arial" BOLD
 Private oTik   := LoadBitmap( GetResources(), "LBTIK" )
 Private oNo    := LoadBitmap( GetResources(), "LBNO" )
 nReg := 0
 aGets := {}  // matriz que contem os campos que vao receber digitacao na enchoice
 aTela := {}  // matriz que contem os campos que vao aparecer na enchoice
 SetPrvt("wVar")
 Private aTELA[0][0],aGETS[0], oCodBar
 Private M->GBX_FLGATE  := "1"
 cSavI := 0
 SetPrvt("AROTINA,CCADASTRO,CALIAS")
 SetPrvt("NOPCE,NOPCG,NUSADO")
 SetPrvt("CTITULO,CALIASENCHOICE,CLINOK,CTUDOK,CFIELDOK")
 SetPrvt("NREG,NOPC")

 aRotina := {{OemtoAnsi(STR0001), "axPesqui"    , 0, 1}, ; //"Pesquisar" //"Pesquisar"
             {OemtoAnsi(STR0002), "FS_MODELO(2)", 0, 2}}   //"Selecionar"

 cCadastro := OemToAnsi(STR0003) //"Modelos de Exames"

 dbSelectArea("GA7")

 mBrowse(06, 01, 22, 75, "GA7",,,,,,)
Return(Nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FS_Modelo        � Autor �  Jos� Roberto   � Data 02/09/2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Digita��o do Modelo do Exame                               ���
���          �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FS_Modelo()
 Local cDirMode := AllTrim(GetMV("MV_DIRMODE"))           
 Local cArqPadr := ""
 Private oWord

 Define  FONT oFont NAME "Arial" BOLD          

 If SubStr(cDirMode, Len(cDirMode), 1) == "\"
  cDirMode := SubStr(cDirMode, 1, Len(cDirMode) - 1)
 EndIf

 cType := "MODELOS	     | *.DOT"
 cTexto  := ""
 cFOpen  := cDirMode + "\" + AllTrim(GA7->GA7_CODPRO) + ".DOC"
 cArqPadr := cDirMode + "\ExamPadr.Doc"
 
 If !File(cFOpen)            
  _CopyFile(cArqPadr, cFOpen)
 EndIf
   
 OpenWord(@oWord,cFOpen)
Return(Nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �OpenWord    � Autor � Cristina Ogura      � Data � 19.04.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Trata as variaveis de abertura quando utiliza o Word     	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �Especifico                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Static Function OpenWord(oWord,cFOpen)
 cExame     := SPACE(20)
 cData      := SPACE(10)
 cHora      := SPACE(05)
 cPaciente  := SPACE(50)
 cIdade     := SPACE(03)
 cSexo      := SPACE(10)
 cConvenio  := SPACE(30)
 cMedico    := SPACE(40)
 cDescricao := space(01)
                         
 //-- Fecha o Documento	
 OLE_CloseLink(oWord) 			  
   
 //Inicializa o Ole com o MS-Word 97 ( 8.0 )	
 oWord := OLE_CreateLink('TMsOleWord97')		
 
 OLE_OpenFile(oWord, cFOpen)       

 OLE_SetDocumentVar(oWord, cExame	 , cExame)
 OLE_SetDocumentVar(oWord, cData	 , cData)
 OLE_SetDocumentVar(oWord, cHora	 , cHora)
 OLE_SetDocumentVar(oWord, cPaciente , cPaciente)
 OLE_SetDocumentVar(oWord, cIdade	 , cIdade)
 OLE_SetDocumentVar(oWord, cSexo	 , cSexo)  
 OLE_SetDocumentVar(oWord, cConvenio , cConvenio)
 OLE_SetDocumentVar(oWord, cMedico 	 , cMedico)
 OLE_SetDocumentVar(oWord, cDescricao, cDescricao)
Return(.T.)
               
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CloseWord   � Autor � Cristina Ogura      � Data � 19.04.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Trata as variaveis de fechamento quando se utiliza o Word	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �Especifico                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
/*
Static Function CloseWord(oWord)
 //--Atualiza Variaveis
 OLE_UpDateFields(oWord)

 //-- Imprime as variaveis				
 OLE_PrintFile(oWord, "ALL",,, 1) 

 //-- Fecha o Documento	
 OLE_CloseLink(oWord) 			
Return(Nil)
*/