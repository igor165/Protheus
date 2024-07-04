#INCLUDE "FIR085CS.ch"
#include "SIGAWIN.CH"        // incluido pelo assistente de conversao do AP5 IDE em 09/09/99

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � FIR085CS	� Autor � Paulo Augusto         � Data � 26/10/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Programa de impressao dos comprovantes de retencao de cargas���
���Descri��o �Sociales (SUSS) especifico para a Argentina RG4052          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � FIR085CS()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function FIR085CS()        // incluido pelo assistente de conversao do AP5 IDE em 09/09/99

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

Local cPerg:="FIR85S"

SetPrvt("CSTRING")
SetPrvt("LIMITE,TITULO,CDESC1")
SetPrvt("CDESC2,CDESC3,CNATUREZA,ARETURN,NOMEPROG,NLASTKEY")
SetPrvt("LCONTINUA,NLIN,WNREL")
SetPrvt("CORDPAGO,NTOTALRET,NTOTBASE,NROCOPIA,PAGOTIPOANT")
SetPrvt("NOPC")
SetPrvt("I,J")
Private tamanho:="P"
Private nDifColCC:= 0

//+-------------------------------------------------------------------------+
//� Verifica las preguntas seleccionadas, busca el padron de las Retenciones�
//+-------------------------------------------------------------------------+


Pergunte(cPerg,.T.)               // Pregunta en SX1

cString:="SFE"
//+--------------------------------------------------------------+
//� Variables utilizadas para parametros                         �
//� mv_par01             // De la orden ?                        �
//� mv_par02             // Hasta la orden ?                     � 
//+--------------------------------------------------------------+

limite :=80
titulo :=PADC(STR0001 ,74) //"Emissao do Certificado de Retencao de Encargos Sociales "
cDesc1 :=PADC(STR0002,74) //"Sera solicitado o Intervalo de Ordenes de Pago para "
cDesc2 :=PADC(STR0003,74) //"a emissao dos Certificados de Retencao de de Encargos Sociais ."
cDesc3 :=""
cNatureza:="" 
aReturn := { OemToAnsi(STR0004), 1,OemToAnsi(STR0005), 1, 2, 1,"",1 } //"Especial"###"Administracao"
nomeprog:="FIR085CS" 
nLastKey:= 0 
lContinua := .T.
nLin:=31
wnrel    := "FIR085CS"


//+--------------------------------------------------------------+
//� Envia control a funcion SETPRINT                             �
//+--------------------------------------------------------------+
wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.,"",.T.)

If nLastKey == 27
   Return
Endif

//+--------------------------------------------------------------+
//� Verifica Posicion del Formulario en la Impresora             �          
//+--------------------------------------------------------------+
SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif 

	
//+--------------------------------------------------------------+
//� Inicio de Procesamiento de la retencion                      �
//+--------------------------------------------------------------+
RptStatus({|| RptDetail()})
Return

/*
���������������������������������������������������������������������������
�����������������������������������������������������������������������Ŀ��
���Fun��o	 �RptDetail� Autor � Paulo Augusto        � Data � 26/11/05 ���
�����������������������������������������������������������������������Ĵ��
���Descri��o � Rotina de Impressao                                      ���
�����������������������������������������������������������������������Ĵ��
���Sintaxe e � RptDetail()          				   				    ���
�����������������������������������������������������������������������Ĵ��
���Parametros�                                                          ���
���			 �                                                          ���
�����������������������������������������������������������������������Ĵ��
��� Uso		 � FIR085CS 											    ���
������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������
���������������������������������������������������������������������������
*/


Static Function RptDetail()


SetRegua(Val(mv_par02)-Val(mv_par01))
dbSelectArea("SFE")              
dbSetOrder(2)                  // Orden de pago + tipo de impuesto (I|B|G)
dbSeek(xFilial("SFE")+mv_par01+"U",.T.)

//+-----------------------------------------------------------+
//� Inicializa  Rutina de impresion                           �
//+-----------------------------------------------------------+

nLargura:=080
@ 0,0 PSay AvalImp(80)



While !Eof() .and. SFE->FE_FILIAL == xFilial("SFE");
   	.and. SFE->FE_ORDPAGO <= mv_par02 ;
	.and. lContinua
	If FE_TIPO#"U"
    	dbSkip()
        Loop
  	Endif
    cOrdPAGO := SFE->FE_ORDPAGO
    NTOTALret  :=0
    ntotbase :=0
       
    IF lAbortPrint
    	@ 00,01 PSAY STR0006 //"** CANCELADO PELO OPERADOR **"
	    lContinua := .F.
        Exit
  	Endif

	NroCopIA:=1

   	dbSelectArea("SFE")               
    dbSetOrder(2)    // Colocar en Orden de OP+tipo
	dbSeek(xFilial("SFE")+cOrdPAGO+"U",.T.)
	
    pagotipoant:=cOrdPago+"U"
	Nlin:=1
	While !Eof() .and. SFE->FE_FILIAL == xFilial("SFE");
                 .and. SFE->FE_ordPAGO+FE_tipo == pAGOtipoant;
                 .and. lContinua 
       
       	If SFE->FE_NROCERT <> "NORET"
	       	IF lAbortPrint
	           	@ 00,01 PSAY STR0006 //"** CANCELADO PELO OPERADOR **"
	           	lContinua := .F.
	   	       	Exit
	       	 Endif
			    
	        cOrdPago := SFE->FE_ORDPAGO   
	    
	   	    aAreaSFE:=SFE->(GetArea())
			IncRegua()
			Nlin:=FI85DtAgen(Nlin)
			Nlin:= FI85DtSuj (Nlin)
			Nlin:=FI85DtRet(Nlin)
	    EndIf
	        
	 	DbSelectArea("SFE")
		dbSkip()
	End
	
End

Set Device To Screen
If aReturn[5] == 1
   Set Printer TO
   dbcommitAll()
   ourspool(wnrel)
Endif
MS_FLUSH()


Return()

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �VerImp    � Autor � Paulo AUgusto         � Data � 26/11/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica a impressao                                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � VERIMP()                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FIR085CS 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
/*
Static Function VerImp()

nLin:= 0                
If aReturn[5]==2

   nOpc       := 1
	
   While .T.
      SetPrc(0,0)
      dbCommitAll()

      @ nLin ,000 PSAY " "
      @ nLin ,004 PSAY "*"
      @ nLin ,022 PSAY "."
      Do Case
         Case nOpc==1
            lContinua:=.T.
            Exit
         Case nOpc==2
            Loop
         Case nOpc==3
            lContinua:=.F.
            Return
      EndCase
   End
Endif
Return
  */

/*
����������������������������������������������������������������������������
������������������������������������������������������������������������Ŀ��
���Fun��o	 �FI85DtAgen �  Autor � Paulo Augusto      � Data � 26/10/05 ���
������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina de Impressao dos dados do fornecedor da retencao   ���
������������������������������������������������������������������������Ĵ��
���Sintaxe e � FI85DtRet(nLim)      									 ���
������������������������������������������������������������������������Ĵ��
���Parametros� nLim - NUmero da linha de impressao.  					 ���
������������������������������������������������������������������������Ĵ��
��� Uso		 � FIR085CS 												 ���
�������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������
����������������������������������������������������������������������������
*/

Function FI85DtAgen(nLim)

Local nLinha:=Nlin + 1
Local aAreaSFE:=SFE->(GetArea())		        

@nLinha,000 PSAY " _______________________________________________________________________________ "
nLinha:= nLinha + 1
@nLinha,000 PSAY STR0007  //"|COMPROVANTE DE RETENCAO DE ENCARGOS SOCIAIS "
@nLinha,080 PSAY "|
nLinha:= nLinha + 1
@nLinha,000 PSAY "|_______________________________________________________________________________|"
nLinha:= nLinha + 1                                                                                     
@nLinha,000 PSAY "|
@nLinha,080 PSAY "|
nLinha:= nLinha + 1
@nLinha,000 PSAY STR0015 + SFE->FE_NROCERT + Space(25) +  STR0016  + Dtoc(SFE->FE_EMISSAO)//+tipo de comprobante
@nLinha,080 PSAY "|
nLinha:= nLinha + 1	
@nLinha,000 PSAY "|_______________________________________________________________________________|"
nLinha:= nLinha + 1	        
@nLinha,000 PSAY STR0008    //"|DATOS DO AGENTE DE RETENCAO:"
@nLinha,080 PSAY "|
@nLinha:= nLinha + 1
@nLinha,000 PSAY "|_______________________________________________________________________________|"
nLinha:= nLinha + 1                                                                                     
@nLinha,000 PSAY "|
@nLinha,080 PSAY "|
nLinha:= nLinha + 1              
@nLinha,000 PSAY STR0017 +  SM0->M0_NOMECOM
@nLinha,080 PSAY "|
nLinha:= nLinha + 1                                                                                     
@nLinha,000 PSAY "|
@nLinha,080 PSAY "|
nLinha:= nLinha + 1 
@nLinha,000 PSAY STR0009+ Transform( SM0->M0_CGC,PesqPict("SA2","A2_CGC")) //"|Numero de C.U.I.T. : "
@nLinha,080 PSAY "|
nLinha:= nLinha + 1                                                                                     
@nLinha,000 PSAY "|
@nLinha,080 PSAY "|
nLinha:= nLinha + 1 
@nLinha,000 PSAY STR0018 + SM0->M0_ENDCOB
@nLinha,080 PSAY "|
nLinha:= nLinha + 1 
@nLinha,000 PSAY STR0010+ SM0->M0_CIDCOB //"|Municipio: "
@nLinha,080 PSAY "|
nLinha:= nLinha + 1 
@nLinha,000 PSAY STR0019+ SM0->M0_CEPCOB	        
@nLinha,080 PSAY "|
nLinha:= nLinha + 1                                                                                     
@nLinha,000 PSAY "|
@nLinha,080 PSAY "|

SFE->(RestArea(aAreaSFE))

Return(nLinha)
      

/*
�����������������������������������������������������������������������������
������������������������������������������������������������������������Ŀ��
���Fun��o	 �FI85DtSuj� Autor � Paulo Augusto         � Data � 26/10/05 ���
������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina de Impressao dos dados da empresa da retencao      ���
������������������������������������������������������������������������Ĵ��
���Sintaxe e � FI85DtRet(nLim)      									 ���
������������������������������������������������������������������������Ĵ��
���Parametros� nLim - NUmero da linha de impressao.  					 ���
������������������������������������������������������������������������Ĵ��
��� Uso		 � FIR085CS 												 ���
�������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������
����������������������������������������������������������������������������
*/

Function FI85DtSuj(Nlin)                        

Local nLinha := Nlin + 1 
Local aAreaSFE:=SFE->(GetArea())		        

@nLinha,000 PSAY "|_______________________________________________________________________________|"
nLinha:= nLinha + 1 
@nLinha,000 PSAY STR0011   //"|DADOS DO SUJEITO RETIDO:"
@nLinha,080 PSAY "|
nLinha:= nLinha + 1                           
@nLinha,000 PSAY "|_______________________________________________________________________________|"
nLinha:= nLinha + 1                                                                                     
@nLinha,000 PSAY "|
@nLinha,080 PSAY "|
nLinha:= nLinha + 1 					        
dbSelectArea("SA2")
DbSetOrder(1)
dbSeek( xFilial("SA2") + SFE->FE_FORNECE + SFE->FE_LOJA) 
@nLinha,000 PSAY STR0017+  SA2->A2_NOME
@nLinha,080 PSAY "|
nLinha:= nLinha + 1                                                                                     
@nLinha,000 PSAY "|
@nLinha,080 PSAY "|
nLinha:= nLinha + 1 
@nLinha,000 PSAY STR0009 + Transform( SA2->A2_CGC,PesqPict("SA2","A2_CGC")) //"|Numero de C.U.I.T. : "
@nLinha,080 PSAY "|
nLinha:= nLinha + 1                                                                                     
@nLinha,000 PSAY "|
@nLinha,080 PSAY "|
nLinha:= nLinha + 1 
@nLinha,000 PSAY STR0018 + SA2->A2_END
@nLinha,080 PSAY "|
nLinha:= nLinha + 1 
@nLinha,000 PSAY STR0010 + SA2->A2_MUN //"|Municipio: "
@nLinha,080 PSAY "|
nLinha:= nLinha + 1 
@nLinha,000 PSAY STR0019 + SA2->A2_CEP  
@nLinha,080 PSAY "|
nLinha:= nLinha + 1                                                                                     
@nLinha,000 PSAY "|
@nLinha,080 PSAY "|
SFE->(RestArea(aAreaSFE))
Return(nLinha)						        


/*
�����������������������������������������������������������������������������
������������������������������������������������������������������������Ŀ��
���Fun��o	 �FI85DtRet� Autor � Paulo Augusto         � Data � 26/10/05 ���
������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina de Impressao dos dadosa da retencao                ���
������������������������������������������������������������������������Ĵ��
���Sintaxe e � FI85DtRet(nLim)      									 ���
������������������������������������������������������������������������Ĵ��
���Parametros� nLim - NUmero da linha de impressao.  					 ���
������������������������������������������������������������������������Ĵ��
��� Uso		 � FIR085CS 												 ���
�������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������
����������������������������������������������������������������������������
*/

Function FI85DtRet(Nlin)
Local nLinha:=Nlin + 1
Local aAreaSFE:=SFE->(GetArea())		        
Local nI :=1


@nLinha,000 PSAY "|_______________________________________________________________________________|"
nLinha:=nLinha+ 1
@nLinha,000 PSAY STR0012 //"|DADOS DA RETENCAO PRATICADA:   "
@nLinha,080 PSAY "|
nLinha:= nLinha + 1 
@nLinha,000 PSAY "|_______________________________________________________________________________|"
nLinha:= nLinha + 1                                                                                     
@nLinha,000 PSAY "|
@nLinha,080 PSAY "|
nLinha:= nLinha + 1 
@nLinha,000 PSAY STR0020 +cOrdPago
@nLinha,080 PSAY "|
nLinha:= nLinha + 1                                                                                     
@nLinha,000 PSAY "|
@nLinha,080 PSAY "|
nLinha:= nLinha + 1 
 
dbSelectArea("SF1")
DbSetOrder(1)
dbSeek( xFilial("SF1")+(SFE->FE_NFISCAL +SFE->FE_SERIE + SFE->FE_FORNECE + SFE->FE_LOJA))
If cPaisLoc == "ARG"
	DbSelectArea("SX5")
	DbSetOrder(1)
	DbSeek(xFilial("SX5") + "ZG" + SF1->F1_ZONGEO )
	@nLinha,000 PSAY STR0013 + Alltrim(X5Descri())  //"|Zona Geografica:"
	@nLinha,080 PSAY "|
	nLinha:= nLinha + 1 
	@nLinha,000 PSAY "|
	@nLinha,080 PSAY "|                 
	nLinha:= nLinha + 1 

	DbSeek(xFilial("SX5") + "CO" + SF1->F1_CONCOBR)
	@nLinha,000 PSAY STR0021 + Alltrim(X5Descri()) 
	@nLinha,080 PSAY "|
	nLinha:= nLinha + 1                                                                                     
	@nLinha,000 PSAY "|
	@nLinha,080 PSAY "|
	nLinha:= nLinha + 1 
EndIf	
@nLinha,000 PSAY STR0014 +  Transform(SFE->FE_ALIQ ,"@E 999.99") //"|Aliquota Aplicada: "
@nLinha,080 PSAY "|
nLinha:= nLinha + 1                                                                                     
@nLinha,000 PSAY "|
@nLinha,080 PSAY "|
nLinha:= nLinha + 1 
@nLinha,000 PSAY STR0022+ Transform(SFE->FE_VALBASE ,"@E 999,999,999,999.99")
@nLinha,080 PSAY "|
nLinha:= nLinha + 1                                                                                     
@nLinha,000 PSAY "|
@nLinha,080 PSAY "|
nLinha:= nLinha + 1 
@nLinha,000 PSAY STR0023 + Transform(SFE->FE_RETENC,"@E 999,999,999,999.99")
@nLinha,080 PSAY "|
nLinha:= nLinha + 1                                                                                     
@nLinha,000 PSAY "|
@nLinha,080 PSAY "|
nLinha:= nLinha + 1 
@nLinha,000 PSAY "|_______________________________________________________________________________|"   
nLinha:= nLinha + 1                                                                                     
For nI:=1 to 3
	@nLinha,000 PSAY "|
	@nLinha,080 PSAY "|
	nLinha:= nLinha + 1                                                                                     
Next
@nLinha,000 PSAY "|
@nLinha,50 PSAY "_____________________________"
@nLinha,080 PSAY "|
nLinha:= nLinha + 1                                                                                     
For nI:=1 to 2
	@nLinha,000 PSAY "|
	@nLinha,080 PSAY "|
	nLinha:= nLinha + 1                                                                                     
Next
@nLinha,000 PSAY "|
@nLinha,55 PSAY STR0024
@nLinha,080 PSAY "|
nLinha:= nLinha + 1                                                                                     
For nI:=1 to 3
	@nLinha,000 PSAY "|
	@nLinha,080 PSAY "|
	nLinha:= nLinha + 1                                                                                     
Next
@nLinha,000 PSAY "|_______________________________________________________________________________|"
SFE->(RestArea(aAreaSFE))
	            
Return(nLinha)	            