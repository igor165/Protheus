#INCLUDE "HSPAHACD.CH"
#INCLUDE "Protheus.CH"
#INCLUDE "TopConn.CH"  

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHACD  � Autor � Heimdall Castro    � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Descricao �Visualiza��o das telas dos cadastros do SUS                 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���                                '	    
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

Function HSPAHACD(aAlias, cTit)
Private cTitulo := cTit
                                                           	
Private aRotina := {{OemtoAnsi(STR0001), "axPesqui" , 1, 01},;//"Pesquisar"
                    {OemtoAnsi(STR0002), "HS_ACD", 2, 02} }  //"Visualizar"

mBrowse(06, 01, 22, 75, aAlias[1])

Return (Nil)   



Function HS_ACD(cAlias, nReg, nOpc)
 
 Local nOpcA   := 0          
 Local aSize  	:= {}, aObjects := {}, aInfo := {}, aPObjs := {}, aPGDs := {}, oFolGD
// Local nOpc 	:= 0
 
 Private aTela    := {}
 Private aGets    := {}
 Private aHeader  := {}
 Private aCols    := {}
 Private nUsado   := 0
 Private oAlias, oGJ8
 Private aCGJ8 := {}, aHGJ8 := {}, nUGJ8 := 0, nLGJ8 := 0
                            
 RegToMemory(aAlias[1], .F.)
 
 If (Len(aAlias) > 1)
  nLGJ8 := HS_BDados("GJ8", @aHGJ8, @aCGJ8, @nUGJ8, 1, M->GJ7_CODSER, "GJ8->GJ8_CODSER == '" + M->GJ7_CODSER + "'",,,,,)// "GA8_CODPRO/GA8_DESPRO")
 EndIf

 aSize := MsAdvSize(.T.)
 aObjects := {}
 AAdd( aObjects, { 100, 100, .T., .T. } )
 
 If (Len(aAlias) > 1)
  aObjects := {}
  AAdd( aObjects, { 100, 050, .T., .T. } )
  AAdd( aObjects, { 100, 050, .T., .T. } )
 EndIf 
 
 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )
 

 DEFINE MSDIALOG oDlg TITLE OemToAnsi(cTitulo) From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd
  
 oAlias := MsMGet():New(aAlias[1], nReg, nOpc,,,,, {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]},,,,,, oDlg)
 oAlias:oBox:align:= CONTROL_ALIGN_ALLCLIENT   
 
 If(Len(aAlias) > 1)
 
  oGJ8 := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], nOpc,,,,,,,,,, oDlg, aHGJ8, aCGJ8)
  oGJ8:oBrowse:Align := CONTROL_ALIGN_BOTTOM                                                                               
 
 EndIf
 
 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, IIF(Obrigatorio(aGets, aTela), oDlg:End(), nOpcA == 0)}, ;
                                                   {|| nOpcA := 0, oDlg:End()})

Return (Nil)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |HSPACDSC  � Autor � Heimdall Castro    � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Descricao �Visualiza��o da tela de cadastro do Servi�oXClassifica��o   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

Function HSPACDSC()

Private aAlias := {"GJ7","GJ8"}
 
HSPAHACD({aAlias[1]}, STR0003) //"Servi�o\Classifica��o"

Return (Nil)     

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |HSPACDHL  � Autor � Heimdall Castro    � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Descricao �Visualiza��o da tela de cadastro do Habilita��o             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

Function HSPACDHL()
                       
Private aAlias := {"GJ1"}
 
HSPAHACD({aAlias[1]}, STR0004) //"Habiliata��o"

Return (Nil)               

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |HSPACDEC  � Autor � Heimdall Castro    � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Descricao �Visualiza��o da tela de cadastro do Especialidade do Leito  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/                                         

Function HSPACDEL()                                             

Private aAlias := {"GJ3"}
 
HSPAHACD({aAlias[1]}, STR0005) //"Especilidade do Leito"

Return (Nil)          

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |HSPACDMD  � Autor � Heimdall Castro    � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Descricao �Visualiza��o da tela de cadastro de Modalidade              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

Function HSPACDMD()

Private aAlias := {"GJ5"}
 
HSPAHACD({aAlias[1]}, STR0006) //"Modalidade"

Return (Nil)       
                          
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |HSPACDIR  � Autor � Heimdall Castro    � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Descricao �Visualiza��o da tela de cadastro de Instrumento de Registro ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/  

Function HSPACDIR()

Private aAlias := {"GJA"}
 
HSPAHACD({aAlias[1]}, STR0007) //"Instrumento de Registro"

Return (Nil)  

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |HSPACDGR  � Autor � Heimdall Castro    � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Descricao �Visualiza��o da tela de cadastro de Grupo                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/  

Function HSPACDGR()

Private aAlias := {"GJS"}
 
HSPAHACD({aAlias[1]}, STR0008) //"Grupo de Procedimento"

Return (Nil)  

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |HSPACDSG  � Autor � Heimdall Castro    � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Descricao �Visualiza��o da tela de cadastro de Subgrupo                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/  

Function HSPACDSG()

Private aAlias := {"GJC"}
 
HSPAHACD({aAlias[1]}, STR0009) //"Subgrupo de Procedimento"

Return (Nil)  

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |HSPACDFO  � Autor � Heimdall Castro    � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Descricao �Visualiza��o da tela de cadastro de Forma de Organiza��o    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/  

Function HSPACDFO()

Private aAlias := {"GJD"}
 
HSPAHACD({aAlias[1]}, STR0010) //"Forma de Organiza��o"

Return (Nil)       
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |HSPACDFO  � Autor � Luiz Pereira S. Jr.� Data �  08/10/08   ���
�������������������������������������������������������������������������͹��
���Descricao �Visualiza��o da tela de cadastro de Forma de Organiza��o    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/  

Function HSPACDCB()

Private aAlias := {"GH1"}
 
HSPAHACD({aAlias[1]}, "C.B.O. SUS") //"CBO SUS"

Return (Nil)       
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |HSPACDFO  � Autor � Sueli C. Santos    � Data �  09/03/09   ���
�������������������������������������������������������������������������͹��
���Descricao �Visualiza��o da tela de cadastro de Detalhe                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/  

Function HSPACDDT()

Private aAlias := {"GLV"}
 
HSPAHACD({aAlias[1]},STR0011) //"Detalhe"

Return (Nil)       

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |HSPACDFO  � Autor � Sueli C. Santos    � Data �  09/03/09   ���
�������������������������������������������������������������������������͹��
���Descricao �Visualiza��o da tela de cadastro de  Procedimento X Detalhe ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/  

Function HSPACDPR()

Private aAlias := {"GLZ"}
 
HSPAHACD({aAlias[1]},STR0012) //"Procedimento X Detalhe"

Return (Nil)    

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |HSPACDFO  � Autor � Sueli C. Santos    � Data �  09/03/09   ���
�������������������������������������������������������������������������͹��
���Descricao �Visualiza��o da tela de cadastro de Detalhe                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/  

Function HSPACNAE()

Private aAlias := {"GR1"}
 
HSPAHACD({aAlias[1]},STR0013) //"Detalhe"

Return (Nil)
