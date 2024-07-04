#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'LOJA750.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA750   �Autor  �Leandro Nogueira    � Data �  04/10/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Avisos de disponibilidade de produto			              ���
�������������������������������������������������������������������������͹��
���Uso       �SIGALOJA                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
/*/{Protheus.doc} LOJA750
Avisos de disponibilidade de produto	
@author  Leandro Nogueira
@version P11 R5
@since   04/10/2010
@return  NIL
/*/
Function LOJA750()
Local nOpca := 0  	//Codigo da operacao
Local aSays:={}   	//Array com says
Local aButtons:={} 	//Array com botoes

//���������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                    �
//� mv_par01            // Filial De ?  					�
//� mv_par02            // Filial At� ?                		�
//� mv_par03            // Loja de ?                        �
//� mv_par04            // Loja at� ?                   	�
//� mv_par05            // Vendedor de ?                   	�
//� mv_par06            // Vendedor at� ?                	�
//� mv_par07            // Cliente de ?       				�
//� mv_par08            // Cliente at� ?             		�
//� mv_par09            // Produto de?             			�
//� mv_par10            // Produto at�?                    	�
//� mv_par11            // Data venda de?                  	�
//� mv_par12            // Data venda at� ?o) 				�
//�����������������������������������������������������������


//������������������������������������������Ŀ
//�Rotina disponivel a partir do Release 11.5�
//��������������������������������������������
If !GetRpoRelease("R5")   
	Return NIL
Endif


#IFDEF TOP
	Pergunte("LOJC750",.F.)
	AADD(aSays,OemToAnsi(STR0001)) //"  Este programa tem como objetivo enviar aviso de disponibilidade do produto de uma venda perdida."
	AADD(aSays,OemToAnsi(STR0002)) //"Ser�o considerados :"                                             
	AADD(aSays,"")                                              
	AADD(aSays,OemToAnsi( STR0003 ))//"A venda deve ter sido perdida por indisponibilidade do produto em estoque." 
	AADD(aSays,OemToAnsi( STR0004 ))//"O movimento de venda perdida deve estar com a op��o de envio de aviso habilitada."                                                                                                                                                                                                                                                                                                                                                                                                                                 
	AADD(aSays,OemToAnsi( STR0005 ))//"O aviso de disponibilidade do produto da venda perdida n�o deve estar expirado"
	AADD(aSays,OemToAnsi( STR0006 ))//"O produto n�o vendido deve estar disponivel em estoque"
			
	AADD(aButtons, { 5,.T.,{|| Pergunte("LOJC750",.T. ) } } )
	AADD(aButtons, { 1,.T.,{|o| nOpca:= 1, If( .T., o:oWnd:End(), nOpca:=0 ) }} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
	FormBatch(STR0007, aSays, aButtons ,,300,600)// "Aviso de disponibilidade do produto"
	
	
	If nOpca == 1
		//DESMARCA MARK
		cQuery := "UPDATE " + RetSqlName("MBR")
  		cQuery += " SET MBR_OK = ''"
		cQuery += "  WHERE D_E_L_E_T_ = '' AND MBR_DTENAV = ''"	
		TcSqlExec(cQuery)			
		//Pesquisa os avisos de disponibilidade de produto que poderao ser enviados
		Processa( { |lEnd| LC750Proc() }) 
	EndIf
	
#ENDIF
Return NIL


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LC750Proc �Autor  �Leandro Nogueira    � Data �  04/10/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Pesquisa o produtos aoptos para envio do aviso              ���
�������������������������������������������������������������������������͹��
���Uso       �SIGALOJA                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
/*/{Protheus.doc} LC750Proc 
Pesquisa o produtos aoptos para envio do aviso     
@author  Leandro Nogueira
@version P11 R5
@since   04/10/2010
@return  NIL
/*/
Function LC750Proc ()

Local oBrowse  
Local cQuery	:= "" 							//Query
Local cCond		:= "" 							//Condicao  
Local nExpira 	:= SuperGetMv("MV_LJEXAV",,0) 	//Determina em quantos dias o aviso de disponibilidade do produto para o cliente ir� expirar
Local nMinEst	:= SuperGetMv("MV_LJESTAV",,30)//Valor m�nimo dispon�vel em estoque exigido (par�metro com valor default igual a 30.)

oMark:= FWMarkBrowse():New()
oMark:SetAlias('MBR')
oMark:SetDescription(STR0007) //"Aviso de disponibilidade do produto"                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
oMark:SetFieldMark( 'MBR_OK' )


//��������������Ŀ
//�Filtros Fixos �
//����������������   
oMark:AddFilter("MOTIVO",		"MBR_MOTIVO ='" + "002" + "'",.T.,.T.)
oMark:AddFilter("AVISO",		"MBR_AVDISP = 'T'",.T.,.T.)
oMark:AddFilter("DATA_AVISO",	"MBR_DTENAV = ''",.T.,.T.)
oMark:AddFilter("ESTOQUE",		"(B2_QATU-B2_RESERVA) > " + Str(nMinEst),.T.,.T.,"SB2")

//���������������������������Ŀ
//�Filtros - Pergunte LOJC750 �
//�����������������������������     

//FILIAL    
If Empty(MV_PAR01)
	oMark:AddFilter("FILIAL","MBR_FILIAL >=''",.T.,.T.) 
Else
	oMark:AddFilter("FILIAL","MBR_FILIAL >='"+ AllTrim(MV_PAR01) +"'",.T.,.T.) 
Endif

If !Empty(MV_PAR02)
	oMark:AddFilter("FILIAL","MBR_FILIAL <='"+ AllTrim(MV_PAR02) +"'",.T.,.T.) 
Endif

//LOJA
If Empty(MV_PAR03)   
	oMark:AddFilter("LOJA","MBR_LOJA >=''",.T.,.T.) 
Else
	oMark:AddFilter("LOJA","MBR_LOJA >='"+ AllTrim(MV_PAR03) +"'",.T.,.T.) 
Endif  

If !Empty(MV_PAR04)
	oMark:AddFilter("LOJA","MBR_LOJA <='"+ AllTrim(MV_PAR04) +"'",.T.,.T.) 
Endif

 
//VENDEDOR
If Empty(MV_PAR05)   
	oMark:AddFilter("VENDEDOR","MBR_VEND >=''",.T.,.T.) 
Else
	oMark:AddFilter("VENDEDOR","MBR_VEND >='"+ AllTrim(MV_PAR05) +"'",.T.,.T.) 
Endif  

If !Empty(MV_PAR06)
	oMark:AddFilter("VENDEDOR","MBR_VEND <='"+ AllTrim(MV_PAR06) +"'",.T.,.T.) 
Endif

//CLIENTE
If Empty(MV_PAR07)   
	oMark:AddFilter("CLIENTE","MBR_CODCLI >=''",.T.,.T.) 
Else
	oMark:AddFilter("CLIENTE","MBR_CODCLI >='"+ AllTrim(MV_PAR07) +"'",.T.,.T.) 
Endif  

If !Empty(MV_PAR08)
	oMark:AddFilter("CLIENTE","MBR_CODCLI <='"+ AllTrim(MV_PAR08) +"'",.T.,.T.) 
Endif

//PRODUTO   
If Empty(MV_PAR09)   
	oMark:AddFilter("PRODUTO","MBR_PROD >=''",.T.,.T.) 
Else
	oMark:AddFilter("PRODUTO","MBR_PROD >='"+ AllTrim(MV_PAR09) +"'",.T.,.T.) 
Endif  

If !Empty(MV_PAR10)
	oMark:AddFilter("PRODUTO","MBR_PROD <='"+ AllTrim(MV_PAR10) +"'",.T.,.T.) 
Endif


//DATA DA VENDA 

oMark:AddFilter("EXPIRA",		"MBR_EMISSA " + " >= '"+DtoS(dDataBase - nExpira)+"'",.T.,.T.)

If !Empty(MV_PAR11)   
	oMark:AddFilter("DATA_INICIO","MBR_EMISSA >= '"+ Dtos(MV_PAR11) +"'",.T.,.T.)
Endif 

If !Empty(MV_PAR12)	
	oMark:AddFilter("DATA_FIM","MBR_EMISSA <= '"+ Dtos(MV_PAR12) +"'",.T.,.T.)
Endif

oMark:Activate()

Return NIL



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MenuDef   �Autor  �Leandro Nogueira    � Data �  04/10/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Menu da rotina de aviso de disponibilidade do produto       ���
�������������������������������������������������������������������������͹��
���Uso       �SIGALOJA                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
/*/{Protheus.doc} MenuDef    
Menu da rotina de aviso de disponibilidade do produto

@author  Leandro Nogueira
@version P11 R5
@since   04/10/2010
@return  aRotina - Op��es do aRotina
/*/
Static Function MenuDef()

Local aRotina 	:= {}
Local cOldAlias := Alias()

ADD OPTION aRotina TITLE STR0008 ACTION 'LA750Conf()' OPERATION 2 ACCESS 0 //"Enviar aviso de disponibilidade"
	
Return aRotina


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ModelDef  �Autor  �Leandro Nogueira    � Data �  23/09/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Modelo de dados											  ���
�������������������������������������������������������������������������͹��
���Uso       �SIGALOJA                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
/*/{Protheus.doc} ModelDef
Modelo de dados
@author  	Leandro Nogueira
@version 	P11 R5
@since   	23/09/2010
@return  	oModel - Modelo de dados
/*/
Static Function ModelDef()  

Local oStruAVI 	:= FWFormStruct( 1, 'MBR') 			// Estrutura do Modelo de Dados
Local oModel	:= MPFormModel ():New('LOJA750')	// Modelo de Dados

//���������������������������������
//�Definicoes do modelo de dados  �
//���������������������������������

oModel:AddFields( 'MBRMASTER',, oStruAVI)   
oModel:SetDescription( STR0007 )//"Aviso de disponibilidade do produto"
oModel:GetModel('MBRMASTER'):SetDescription(STR0009 )   // 'Dados do Movimento de Venda Perdida'

Return oModel

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ViewDef   �Autor  �Leandro Nogueira    � Data �  23/09/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �View de dados  											  ���
�������������������������������������������������������������������������͹��
���Uso       �SIGALOJA                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
/*/{Protheus.doc} VIEWDef
@author  	Leandro Nogueira
@version 	P11 R5
@since   	24/09/2010
@return  	oView - View de dados
/*/

Static Function ViewDef()
Local oModel 	:= FWLoadModel("LOJA750")
Local oView  	:= FWFormView():New()
Local oStru     := FWFormStruct(2,"AVI")

oView:SetModel(oModel)
oView:AddGrid('VIEW_AVI' ,oStru,'AVIMASTER')       

Return oView


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LA750Conf �Autor  �Leandro Nogueira    � Data �  13/10/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Tela para confirmar o envio do e-mail de aviso.			  ���
�������������������������������������������������������������������������͹��
���Uso       �SIGALOJA                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
/*/{Protheus.doc} LA750Conf  
Tela para confirmar o envio do e-mail de aviso.	
@author  	Leandro Nogueira
@version 	P11 R5
@since   	13/10/2010
@return  	NIL
/*/
Function LA750Conf ()          

Local aArea   	:= GetArea()
Local cMarca   	:= oMark:Mark() 
Local cQuery    := ''
Local cTmp      := ''
Local oDlgAviso	:= NIL														//Objeto para criacao da tela
Local aDestinos	:= {}														//Destinatarios do e-mail.
Local cAssunto	:= SuperGetMv("MV_LJAVSUB",,STR0010)  						//Assunto do e-mail //"Aviso: Produto Disponivel"
Local cMemoTop 	:= SuperGetMv("MV_LJAVTOP",,"") 							//Conteudo do cabe�alho do e-mail de aviso de disponibilidade de produto.
Local cMemoBod 	:= SuperGetMv("MV_LJAVBOD",,"") 							//Conteudo do corpo do e-mail de aviso de disponibilidade de produto.
Local cMemoBot 	:= SuperGetMv("MV_LJAVBOT",,"") 							//Conteudo do rodap� do e-mail de aviso de disponibilidade de produto.

If Empty(AllTrim(cAssunto))
	cAssunto	:= Space(60)
Endif	

cQuery := "SELECT COUNT(*) QTD FROM " + RetSqlName( 'MBR' )
cQuery += " WHERE MBR_OK = '" + cMarca + "' "
cQuery += "   AND D_E_L_E_T_ = ' ' "

cTmp := GetNextAlias()
dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cTmp, .T., .F. )

If (cTmp)->QTD  <= 0
	ApMsgInfo( STR0011 )//"Nenhum registro foi marcado !"
	(cTmp)->( dbCloseArea() )
	RestArea( aArea )
	Return Nil
Else
	(cTmp)->( dbCloseArea() )
	RestArea( aArea )
		
	cQuery := "SELECT A1_EMAIL,B1_DESC," + RetSqlName( 'MBR' ) + ".R_E_C_N_O_ " 
	cQuery += " FROM " + RetSqlName( 'MBR' )+ ","+ RetSqlName( 'SB1' )+ ","+ RetSqlName( 'SA1' )
	cQuery += " WHERE MBR_OK = '" + cMarca + "' "                 
	cQuery += " AND A1_COD = MBR_CODCLI "
	cQuery += " AND B1_COD = MBR_PROD "
	cQuery += " AND " + RetSqlName( 'MBR' ) + ".D_E_L_E_T_ = ' ' "
	cQuery += " AND " + RetSqlName( 'SA1' ) + ".D_E_L_E_T_ = ' ' "
	cQuery += " AND " + RetSqlName( 'SB1' ) + ".D_E_L_E_T_ = ' ' "

	cTmp := GetNextAlias()
	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cTmp, .T., .F. )
	
	
	//������������������������������������Ŀ
	//� Array aDestinos                    �
	//� [1] E-mail do destinat�rio         �
	//� [2] Descricao do Produto		   �
	//� [3] RECNO						   �
	//��������������������������������������
	While !(cTmp)->(Eof())
		AADD(aDestinos,{(cTmp)->A1_EMAIL,;
						(cTmp)->B1_DESC,;					
						(cTmp)->R_E_C_N_O_})
		(cTmp)->(DbSkip())
	End
	
EndIf


//�����������������������������������������������������Ŀ
//� Define a tela para confirmacao do conteudo do e-mail�
//�������������������������������������������������������
DEFINE MSDIALOG oDlgAviso TITLE STR0012 FROM 0,0 TO 480,800 OF oMainWnd PIXEL //"E-mail de aviso de disponibilidade do produto"


//Conteudo
@ 1,1 GROUP oGroup TO 220,195 LABEL STR0013 OF oDlgAviso PIXEL //"Conte�do do e-mail"

@ 10, 3 SAY STR0014 SIZE 40,08 OF oGroup PIXEL //"Assunto"

@ 18, 3 MSGET cAssunto PICTURE "@!" SIZE 190, 10 OF oGroup PIXEL    

@ 32, 3 SAY STR0015 SIZE 40,08 OF oGroup PIXEL //"Cabe�alho"
oMemoTop:= tMultiget():New(40,3,{|u|if(Pcount()>0,cMemoTop:=u,cMemoTop)} ,oDlgAviso,190,28,,,,,,.T.,,,,,,,/*Valid*/,,,,.T.)
oMemoTop:lWordWrap:= .T.

@ 68, 3 SAY STR0016 SIZE 40,08 OF oGroup PIXEL //"Corpo"
oMemoBod:= tMultiget():New(76,3,{|u|if(Pcount()>0,cMemoBod:=u,cMemoBod)} ,oDlgAviso,190,80,,,,,,.T.,,,,,,,/*Valid*/,,,,.T.)
oMemoBod:lWordWrap:= .T.

// Rodape
@ 160, 3 SAY STR0017 SIZE 40,08 OF oGroup PIXEL //"Rodap�"
oMemoBot:= tMultiget():New(168,3,{|u|if(Pcount()>0,cMemoBot:=u,cMemoBot)} ,oDlgAviso,190,50,,,,,,.T.,,,,,,,/*Valid*/,,,,.T.)
oMemoBot:lWordWrap:= .T.

@ 1,200 GROUP oGroup TO 220,400 LABEL STR0018 OF oDlgAviso PIXEL //"Visualiza��o"

oSay:= TSay():New(8,205,{||STR0014+ " : " + cAssunto +CHR(13)+CHR(10)+;//"Assunto"
							cMemoTop+CHR(13)+CHR(10)+;
							cMemoBod+CHR(13)+CHR(10)+;
							STR0019+CHR(13)+CHR(10)+;//"AQUI SERA EXIBIDO O NOME DO PRODUTO"
							cMemoBot},oGroup,,,,,,.T.,CLR_RED,CLR_WHITE,190,300)

ACTIVATE DIALOG oDlgAviso CENTERED ON INIT EnchoiceBar( oDlgAviso, { || ( LA750Env(aDestinos,cAssunto,cMemoTop,cMemoBod,cMemoBot) , oDlgAviso:End() ) }, { || ( oDlgAviso:End() ) })


Return Nil  


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LA750Env  �Autor  �Leandro Nogueira    � Data �  13/10/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Envio o e-mail para os clientes selecionados.				  ���
�������������������������������������������������������������������������͹��
���Uso       �SIGALOJA                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

/*/{Protheus.doc} LA750Env
Envio o e-mail para os clientes selecionados.
@author  	Leandro Nogueira
@version 	P11 R5
@since   	13/10/2010
@return  	lResulFim
/*/

Function LA750Env (aDestinos,cAssunto,cMemoTop,cMemoBod,cMemoBot)
Local lRet		:= .F.
Local nX 		:=  0   
Local cMsg		:= ""
Local cServer  	:= AllTrim(SuperGetMv("MV_RELSERV"))
Local cEmail   	:= AllTrim(SuperGetMv("MV_RELACNT"))
Local cPass    	:= AllTrim(SuperGetMv("MV_RELPSW"))
Local cPassAut  := AllTrim(SuperGetMv("MV_RELAPSW"))
Local lRelauth 	:= SuperGetMv("MV_RELAUTH")
Local lResulConn:= .T.
Local lResulSend:= .T.
Local lResulFim := .F. 
Local lResult	:= .T.
Local cError 	:= ""

Default aDestinos := {}
Default cAssunto := ""
Default cMemoTop := ""
Default cMemoBod := ""
Default cMemoBot := ""

lRet := MsgYesNo(STR0020, STR0021) // "Confirma o envio do e-mail de aviso de disponibilidade para os clientes selecionados ?", "Aten��o"

If lRet
		For nX := 1 To Len(aDestinos)
			If !Empty(aDestinos[nX][1])	

				cMsg:=cMemoTop+CHR(13)+CHR(10)+;
						cMemoBod+CHR(13)+CHR(10)+;
						aDestinos[nX][2]+CHR(13)+CHR(10)+;
						cMemoBot
				
				//���������������������������Ŀ
				//�CONEXAO COM O SERVIDOR SMTP�
				//�����������������������������
				
				CONNECT SMTP SERVER cServer ACCOUNT cEmail PASSWORD cPass RESULT lResulConn			             
                
                
				If !lResulConn
				   GET MAIL ERROR cError				  
				   MsgAlert(STR0022+cError)//"Falha na conexao : "				   
				   Return(.F.)
				Endif			 
				

				//������������������������Ŀ
				//�AUTENTICACAO (OPICIONAL)�
				//��������������������������
				If lRelauth
       				lResult := MailAuth(Alltrim(cEmail), Alltrim(cPassAut))
   					//Se nao conseguiu fazer a Autenticacao usando o E-mail completo, 
   					//tenta fazer a autenticacao usando apenas o nome de usuario do E-mail
					If !lResult
						nA := At("@",cEmail)
						cUser	:= If(nA>0,Subs(cEmail,1,nA-1),cEmail)
						lResult := MailAuth(Alltrim(cUser), Alltrim(cPassAut))
					Endif

				Endif

				
				//��������������Ŀ
				//�ENVIA O EMAIL �
				//����������������
				If lResult 
					SEND MAIL FROM cEmail TO aDestinos[nX][1] SUBJECT cAssunto BODY cMsg RESULT lResulSend				
					
					If !lResulSend
	   					GET MAIL ERROR cError	  
	  		        	MsgAlert(STR0023 + CHR(13)+CHR(10)+;//"Falha no Envio do e-mail "
	  		        				STR0024 + cError + CHR(13)+CHR(10)+; //"Erro :"
	  		        				STR0025 + aDestinos[nX][1])//"Destinat�rio :"
       				Endif				
				EndIf 
				
				
				//����������������������Ŀ
				//�DESCONECTA DO SERVIDOR�
				//������������������������				
				DISCONNECT SMTP SERVER
				
				
				lResulFim := lResulSend
				If lResulSend 					
			 		LA750GrvEn(aDestinos[nX][3])			 					 					 					 		
			   	Endif
				
			EndIf
		Next nX	
EndIf

If lResulFim
	MsgInfo(STR0026)//"E-mail enviado com sucesso !"	
Else
	MsgAlert(STR0027)//"Um ou mais e-mails n�o foram enviados. Verifique !"
EndIf

Return lResulFim



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LA750GrvEn�Autor  �Leandro Nogueira    � Data �  14/10/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Grava a confirma��o do envio de e-mail					  ���
�������������������������������������������������������������������������͹��
���Uso       �SIGALOJA                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
/*/{Protheus.doc} LA750GrvEn
Grava a confirma��o do envio de e-mail
@author  	Leandro Nogueira
@version 	P11 R5
@since   	14/10/2010
@return  	lRetorno
/*/
Function LA750GrvEn (nRecno)

Local lRetorno 	:= .F.						//Retorno do metodo
Local cQuery	:= ""						//Query que sera executada     

Default nRecno	:= 1

//������������������������������������Ŀ
//� Array aDestinos                    �
//� [1] E-mail do destinat�rio         �
//� [2] Descricao do Produto		   �
//� [3] RECNO						   �
//��������������������������������������

//Monta a query
cQuery := "UPDATE " + RetSqlName("MBR")
cQuery += " SET MBR_DTENAV = '" + Dtos(dDataBase) + "'"
cQuery += " WHERE R_E_C_N_O_ = " + Str(nRecno)

If TcSqlExec(cQuery) >= 0
	lRetorno := .T.	     
EndIf

Return lRetorno     
