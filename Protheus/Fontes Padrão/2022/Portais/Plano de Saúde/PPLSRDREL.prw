#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

#DEFINE __RELIMP GETMV("MV_RELT")
 
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
��� Programa  � getDadRel  � Autor � Totvs				� Data � 04.02.2012 ���
���������������������������������������������������������������������������Ĵ��
��� Descri��o � Retorna parte da string conforme tamanho do campo			���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
static Function getDadRel(cArqTxt,cArqRel)
LOCAL cRelato 	:= ""
LOCAL lBuffer	:= .T.
LOCAL nI		:= 0
LOCAL nH		:= 0
LOCAL cAuxRelato:= ""
LOCAL cCaracter	:= ""
//��������������������������������������������������������������������������
//� Retira da string original o conteudo ja capturado
//��������������������������������������������������������������������������
nH := FT_FUse( cArqTxt )
FT_FGotop()
//�������������������������������������������������������������������������
//� Todas as linhas se arquivos for encontrado
//�������������������������������������������������������������������������
if nH <> -1
	While ( !FT_FEof() )
		//�������������������������������������������������������������������������
		//� Estou retirando um monte de lixo que esta no arquivo plsr997
		//� (fazer tratamento poi da erro na impressao)
		//�������������������������������������������������������������������������
		cRelato := FT_FREADLN()

		For nI := 1 To Len(cRelato)

			cCaracter := SubStr(cRelato,nI,1)

			If ( ( Asc(cCaracter) >= 32 .And. Asc(cCaracter) <= 146 ) .Or. ( Asc(cCaracter) >= 192 .And. Asc(cCaracter) <= 256 ) .Or. Asc(cCaracter) == 13 .Or. Asc(cCaracter) == 10 )
				//�������������������������������������������������������������������������
				//� Na mesma linha um enter tem que ser substituido
				//�������������������������������������������������������������������������
				If Asc(cCaracter) == 13
					cCaracter := '<br>'
				EndIf

		   		cAuxRelato += cCaracter
			EndIf
		Next

		cRelato		:= cAuxRelato
		cAuxRelato	:= ""
		//�������������������������������������������������������������������������
		//� Coloca o conteudo no novo arquivo htm
		//�������������������������������������������������������������������������
		If At("RPC",cRelato) == 0
			PLSLOGFIL( StrTran(  cRelato  ," ","&nbsp;") + '<br>' ,cArqRel,lBuffer )
		EndIf

		FT_FSkip()
	EndDo
	//�������������������������������������������������������������������������
	//� Fecha o arquivo
	//�������������������������������������������������������������������������
	FT_FUse()
endIf
//��������������������������������������������������������������������������
//� Fim da Funcao
//��������������������������������������������������������������������������
Return(nH)
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
��� Programa  � setDirRel  � Autor � Totvs				� Data � 04.02.2012 ���
���������������������������������������������������������������������������Ĵ��
��� Descri��o � Se nao existe o diretorio de relatorios cria				���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function setDirRel()
LOCAL lRet := .T.

If !ExistDir(__RELIMP)

	If MakeDir( __RELIMP ) <> 0

		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Imposs�vel criar diretorio ( "+__RELIMP+" ) ", 0, 0, {})

		lRet := .F.

	EndIf
	
EndIf

Return(lRet)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PPRELBOL  �Autor  �Totvs               � Data �  20/02/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Processa boleto - SENDO GERADO EM PDF						  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function PPRELBOL()
LOCAL cMsgErro	:= ""
LOCAL aPar 	  	:= paramixb[1]
LOCAL nRecno	:= aPar:Recno
LOCAL cArqName	:= ""
//��������������������������������������������������������������������������������������������������
//� Se o diretorio nao existir cria
//��������������������������������������������������������������������������������������������������
If setDirRel()
	//��������������������������������������������������������������������������������������������������
	//� Posiciona no registro do SE1
	//��������������������������������������������������������������������������������������������������
	SE1->( DbGoTo(nRecno) )
	//�����������������������������������������������������������������������������Ŀ
	//� Variaveis utilizadas para parametros                         				�
	//� mv_par01 // Cliente de                                       				�
	//� mv_par02 // Loja ate                                        				�
	//� mv_par03 // Cliente ate                                      				�
	//� mv_par04 // Loja                                            				�
	//� mv_par05 // Operadora de                                     				�
	//� mv_par06 // Operadora ate                                    				�
	//� mv_par07 // Empresa de                                       				�
	//� mv_par08 // Empresa ate                                      				�
	//� mv_par09 // Contrato de                                      				�
	//� mv_par10 // Contrato ate                                     				�
	//� mv_par11 // Sub-Contrato de                                  				�
	//� mv_par12 // Sub-Contrato ate                                                �
	//� mv_par13 // Matricula De                                       				�
	//� mv_par14 // Matricula Ate                                                   �
	//� mv_par15 // Mes de                                          				�
	//� mv_par16 // Ano de                                           				�
	//� mv_par17 // Mes Ate                                         				�
	//� mv_par18 // Ano Ate                                          				�
	//� mv_par19 // Detalha Cobranca - Por Usuario/Por Tipo Cobranca                �
	//� mv_par20 // Gera lancamento de segunda via de boleta...                     �
	//� mv_par21 //                                                                 �
	//� mv_par22 // Imprime Primeira parte do Boleto                                �
	//� mv_par23 // Imprime Segunda  parte do Boleto                                �
	//� mv_par24 // Imprime Terceira parte do Boleto                                �
	//� mv_par25 // Imprime Quarta parte do Boleto                                  �
	//� mv_par26 // Salva Imagem Boleto no     Spoll?                               �
	//�������������������������������������������������������������������������������
	cArqName := PLSR580(NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL,;
						  NIL, NIL, NIL, NIL, NIL, NIL, 1, 1, NIL, 2, 2, 2, 2,2,;
						  .T., SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, __RELIMP)
EndIf
//��������������������������������������������������������������������������
//� Aqui estou garantindo que o PDF ja foi gerado e ja esta disponivel para download
//��������������������������������������������������������������������������
if !Empty(cArqName) .and. Findfunction('PLSCHKRP')
	PLSCHKRP(__RELIMP, cArqName)	
endIf	
//��������������������������������������������������������������������������
//� Fim da Funcao
//��������������������������������������������������������������������������
Return( { cArqName, cMsgErro } )
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MtaDados � Autor � Luciano Aparecido     � Data � 22/03/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Grava STATUS da tabela BEA e chama a funcao "PLSGSADT"     ���
���          � que ira retornar o array com os dados a serem impressos.   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � PLSR430N                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MtaDados(cTipo,cTipGui,lOldPror)
	Local aDados := {}
default cTipGui := ''
default lOldPror := .F.

//recurso de glosa	
if cTipGui == '10'
	aDados := PLSGREGL() 
	
ELSEIF cTipGui == '11'
	aDados := PLSGINT(3,lOldPror)   		
ElseIf cTipo == "3" .AND. BE4->BE4_STATUS $ "1,2,3,4,6"
		BEA->(RecLock("BE4", .F.))
		
		If BE4->BE4_STATUS == "4"
			BE4->BE4_STATUS := "1"
		EndIf

		If BE4->(FieldPos("BE4_GUIIMP")) > 0
			BE4->BE4_GUIIMP := "1"
		EndIf

		BE4->(MsUnLock())
	aDados := PLSGINT(1) 		// Funcao que monta o array com os dados da guia de Sol. Interna�ao	  		
else

	if BEA->BEA_STATUS $ "1,2,3,4,6" // ALTERACAO PARA IMPRESSAO DE USUARIOS NAO AUTORIZADOS

		BEA->(RecLock("BEA", .F.))
		
		If BEA->BEA_STATUS == "4"
			BEA->BEA_STATUS := "1"
		EndIf

		If BEA->(FieldPos("BEA_GUIIMP")) > 0
			BEA->BEA_GUIIMP := "1"
		EndIf

		BEA->(MsUnLock())
		
		If cTipo $ "1,2"
			aDados := PLSGSADT(cTipo) 	// Funcao que monta o array com os dados da guia de CONSULTA ou SP/SADT

		ElseIf cTipo == "4"
			aDados := PLSGODCO() 		// Funcao que monta o array com os dados da guia Cobranca Odonto
		EndIf
	endIf

endIf

return aDados
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PPRELIR   �Autor  �Totvs               � Data �  20/02/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Processa IR												  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function PPRELIR()
LOCAL aPar 	  	:= Paramixb[1]
LOCAL cMsgErro	:= ""
LOCAL cArq		:= "PLSR997" + CriaTrab(NIL,.F.) + ".HTM"
LOCAL cArqHTM 	:= __RELIMP + cArq
LOCAL cMatric	:= aPar:MATRIC
//�����������������������������������������������������������������������������
//� Se o diretorio nao existir cria
//�����������������������������������������������������������������������������
If setDirRel()
	//���������������������������������������������������������������������Ŀ
	//� Atualiza perguntas                                                  �
	//�����������������������������������������������������������������������
	//�����������������������������������������������������������������������������Ŀ
	//� Variaveis utilizadas para parametros                         				�
	//� mv_par01 // Operadora de                                       				�
	//� mv_par02 // Grupo de                                        				�
	//� mv_par03 // Grupo de ate                                       				�
	//� mv_par04 // Contrato de                                    					�
	//� mv_par05 // Contrato ate                                    				�
	//� mv_par06 // Sub-Contrato de                                  				�
	//� mv_par07 // Sub-Contrato ate                                                �
	//� mv_par08 // Familia de                                      				�
	//� mv_par09 // Familia ate                                     				�
	//� mv_par10 // Ano de                                           				�
	//� mv_par11 // Analitico/sintetico ?                              				�
	//�������������������������������������������������������������������������������
	BA3->(DbSetOrder(1))
	If  BA3->( MsSeek( xFilial("BA3")+Subs(cMatric,1,14) ) )
		aRet := PLSR997(BA3->BA3_CODINT,BA3->BA3_CODEMP,BA3->BA3_CODEMP, nil, 'ZZZZZZZZZZ', nil,;
						'ZZZZZZZZ',BA3->BA3_MATRIC,BA3->BA3_MATRIC,  aPar:ANO,1, .T., __RELIMP)
		//aRet[1] := .T. ou .F.
		//aRet[2] := Erro caso exista
		//aRet[3] := caminho e o Nome do arquivo com extensao \SPOOL\PLSRXXX.##R
		
		//� Verifica o retorno
		If Valtype(aRet) == "A" 
			If !aRet[1]
				cMsgErro := aRet[2]
			EndIf
			
			//� Se nao teve nenhum problema no processamento
			If Empty(cMsgErro)
				//� Nome do arquivo com extensao
				cArqRel := aRet[3]
			EndIf
		Else
			cMsgErro := 'Nenhuma informa��o foi encontrada'
		EndIf
	EndIf
EndIf

//� Aqui estou garantindo que o PDF ja foi gerado e ja esta disponivel para download
If !Empty(cArqRel) .and. Findfunction('PFileReady')
	PFileReady(__RELIMP, cArqRel, 5) 
Endif	
Return( { cArqRel, cMsgErro } )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PPRELSIN  �Autor  �Totvs               � Data �  20/02/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Processa Sinistralidade 									  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function PPRELSIN()
LOCAL aPar 	  	:= Paramixb[1]
LOCAL cMsgErro	:= ""
LOCAL cArq		:= "PLSR996" + CriaTrab(NIL,.F.) + ".HTM"
LOCAL cArqHTM 	:= __RELIMP + cArq
LOCAL cMatric	:= aPar:MATRIC
//�����������������������������������������������������������������������������
//� Se o diretorio nao existir cria
//�����������������������������������������������������������������������������
If setDirRel()
	//�����������������������������������������������������������������������������Ŀ
	//� Variaveis utilizadas para parametros                         				�
	//� mv_par01 // Operadora de                                       				�
	//� mv_par02 // Grupo de                                        				�
	//� mv_par03 // Grupo de ate                                       				�
	//� mv_par04 // Contrato de                                    					�
	//� mv_par05 // Contrato ate                                    				�
	//� mv_par06 // Versao Contrato de                                       		�
	//� mv_par07 // Versao Contrato ate                                      		�
	//� mv_par08 // Sub-Contrato de                                  				�
	//� mv_par09 // Sub-Contrato ate                                                �
	//� mv_par10 // Versao Sub-Contrato de                          				�
	//� mv_par11 // Versao Sub-Contrato                                				�
	//� mv_par12 // Familia de                                      				�
	//� mv_par13 // Familia ate                                     				�
	//� mv_par14 // Matricula De                                       				�
	//� mv_par15 // Matricula Ate                                                   �
	//� mv_par16 // Ano de                                           				�
	//� mv_par17 // Ano Ate                                          				�
	//� mv_par18 // Mes de                                          				�
	//� mv_par19 // Mes Ate                                         				�
	//� mv_par20 // Tipo ?                                          				�
	//� mv_par21 // Analitico/sintetico ?                              				�
	//�������������������������������������������������������������������������������

	//�������������������������������������������������������������������������
	//� Processa o relatorio
	//�������������������������������������������������������������������������
	BA3->( DbSetOrder(1) )
	If  BA3->(MsSeek(xFilial("BA3")+Subs(cMatric,1,14)))

		aRet := PLSR996(BA3->BA3_CODINT,BA3->BA3_CODEMP,BA3->BA3_CODEMP,BA3->BA3_CONEMP,;
						BA3->BA3_CONEMP,BA3->BA3_VERCON,BA3->BA3_VERCON,BA3->BA3_SUBCON,BA3->BA3_SUBCON,;
						BA3->BA3_VERSUB,BA3->BA3_VERSUB,BA3->BA3_MATRIC,BA3->BA3_MATRIC,NIL,'ZZ',aPar:ANO,;
						aPar:ANO,aPar:MES,aPar:MES,2,'2',.T., __RELIMP )
	EndIf
	//aRet[1] := .T. ou .F.
	//aRet[2] := Erro caso exista
	//aRet[3] := caminho e o Nome do arquivo com extensao \SPOOL\PLSR996.##R
	//�������������������������������������������������������������������������
	//� Verifica o retorno
	//�������������������������������������������������������������������������
	If !aRet[1]
		cMsgErro := aRet[2]
	EndIf
	//��������������������������������������������������������������������������
	//� Se nao teve nenhum problema no processamento
	//��������������������������������������������������������������������������
	If Empty(cMsgErro)
		//��������������������������������������������������������������������������
		//� Nome do arquivo com extensao
		//��������������������������������������������������������������������������
		cArqRel := aRet[3]
		//��������������������������������������������������������������������������
		//� Abertura do arquivo
		//��������������������������������������������������������������������������
		PLSLOGFIL( WCFTxtHtm('A') ,cArqHTM )
		//��������������������������������������������������������������������������
		//� Para ajustar o arquivo txt gerado no spool Retirar caracter especial
		//� e colocar o resultado em um arquivo htm
		//��������������������������������������������������������������������������
		if getDadRel( cArqRel ,cArqHTM) == -1
			cMsgErro := 'Arquivo de SPOOL n�o encontrado'
		endIf
		//��������������������������������������������������������������������������
		//� Abertura do arquivo htm
		//��������������������������������������������������������������������������
		PLSLOGFIL( WCFTxtHtm('F') ,cArqHTM )

	EndIf
EndIf
//��������������������������������������������������������������������������
//� Fim da Funcao
//��������������������������������������������������������������������������
Return( { cArq, cMsgErro } )
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PPRELULT  �Autor  �Totvs               � Data �  20/02/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Processa Extrato de utilizacao do usuario					  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function PPRELULT()
LOCAL aPar 	  	:= Paramixb[1]
LOCAL cMsgErro	:= ""
LOCAL cMatric	:= aPar:MATRIC
LOCAL cArqRel   :=" "

//Cria o diretorio de relatorios
setDirRel()

BA3->( DbSetOrder(1) )
If  BA3->(MsSeek(xFilial("BA3")+Subs(cMatric,1,14)))

	/*
	Variaveis utilizadas para parametros
	MV_PAR01 // Operadora de              
	MV_PAR02 // Empresa                   
	MV_PAR03 // Contrato                  
	MV_PAR04 // Sub-Contrato              
	MV_PAR05 // Familia                   
	MV_PAR06 // Matricula                 
	MV_PAR07 // Data de                   
	MV_PAR08 // Data Ate                  
	MV_PAR09 // Ano de                    
	MV_PAR10 // Mes de                    
	MV_PAR11 // Ano Ate                   
	MV_PAR12 // Mes Ate                   
	MV_PAR13 // Fase ?                    
	MV_PAR14 // Coparticipa��o ?          
	*/
	
	// Processa o relatorio
	aRet := PLSR022( BA3->BA3_CODINT,BA3->BA3_CODEMP,BA3->BA3_CONEMP,BA3->BA3_SUBCON,'',aPar:MATRIC,aPar:DTDE,aPar:DTATE,'','','ZZZZ','ZZ',.T., __RELIMP )
EndIf

//aRet[1] := .T. ou .F.
//aRet[2] := Erro caso exista
//aRet[3] := Caminho e o Nome do arquivo

// Verifica o retorno
If !aRet[1]
	cMsgErro := aRet[2]
EndIf

// Se nao teve nenhum problema no processamento
If Empty(cMsgErro)
	// Nome do arquivo com extensao
	cArqRel := aRet[3]
EndIf

//�����������������������������������������������������������������������������������
//� Aqui estou garantindo que o PDF ja foi gerado e ja esta disponivel para download
//����������������������������������������������������������������������������������� 
If !Empty(cArqRel) .and. Findfunction('PFileReady')
	PFileReady(__RELIMP, cArqRel, 5) 
Endif	
Return( { cArqRel, cMsgErro } )


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  PLSRCRIT  �Autor  �Totvs               � Data �  20/02/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Relatorio de PEG (protocolo eletronico de guias)			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
user function PPLEXE754()
LOCAL cMsgErro	:= ""
LOCAL aPar 	  	:= paramixb[1]
LOCAL cArqName	:= ""
//��������������������������������������������������������������������������������������������������
//� Se o diretorio nao existir cria
//��������������������������������������������������������������������������������������������������
If setDirRel()
	//��������������������������������������������������������������������������������������������������
	//� Imprimi capa do peg
	//��������������������������������������������������������������������������������������������������
	aRet	 := PLSR754(NIL,NIL,.t.,aPar,__RELIMP)
	cArqName := aRet[1]
	cMsgErro := aRet[2]
EndIf
//��������������������������������������������������������������������������
//� Fim da Funcao
//��������������������������������������������������������������������������
Return( { cArqName, cMsgErro } )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  PLSRCRIT  �Autor  �Totvs               � Data �  20/02/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Relatorio de PEG (protocolo eletronico de guias)			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
user function PLSRCRIT()
LOCAL cMsgErro	:= ""
LOCAL cArqName	:= ""
LOCAL cChave   	:= paramixb[1]:Sequen
//��������������������������������������������������������������������������������������������������
//� Se o diretorio nao existir cria
//��������������������������������������������������������������������������������������������������
If setDirRel()
	//��������������������������������������������������������������������������������������������������
	//� Imprimi capa do peg
	//��������������������������������������������������������������������������������������������������
	cArqName := PLSRCRIT(cChave,__RELIMP,.t.)[1]
EndIf
//��������������������������������������������������������������������������
//� Aqui estou garantindo que o PDF ja foi gerado e ja esta disponivel para download
//��������������������������������������������������������������������������
if !Empty(cArqName) .and. Findfunction('PFileReady')
	PFileReady(__RELIMP, cArqName)	
endIf	
//��������������������������������������������������������������������������
//� Fim da Funcao
//��������������������������������������������������������������������������
Return( { cArqName, cMsgErro } )
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PPRELPEG  �Autor  �Totvs               � Data �  20/02/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Relatorio de PEG (protocolo eletronico de guias)			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
user function PPRELPEG()
LOCAL cMsgErro	:= ""
LOCAL aPar 	  	:= paramixb[1]
LOCAL cChave	:= If(valtype(aPar:xmlfile)<>'U',plsintpad()+aPar:xmlfile,nil)
LOCAL nRecno	:= If(valtype(aPar:recno)  <>'U',aPar:Recno,nil)
LOCAL cArqName	:= ""
//��������������������������������������������������������������������������������������������������
//� Se o diretorio nao existir cria
//��������������������������������������������������������������������������������������������������
If setDirRel()
	//��������������������������������������������������������������������������������������������������
	//� Imprimi capa do peg
	//��������������������������������������������������������������������������������������������������
	cArqName := PLSRCPRT(cChave,__RELIMP,.t.,nRecno)[1]
EndIf
//��������������������������������������������������������������������������
//� Aqui estou garantindo que o PDF ja foi gerado e ja esta disponivel para download
//��������������������������������������������������������������������������
if !Empty(cArqName) .and. Findfunction('PLSCHKRP')
	PLSCHKRP(__RELIMP, cArqName)	
endIf	
//��������������������������������������������������������������������������
//� Fim da Funcao
//��������������������������������������������������������������������������
Return( { cArqName, cMsgErro } )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PPRELXML  �Autor  �Totvs               � Data �  20/02/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Processa Relacao de xml									  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function PPRELXML()
LOCAL aPar 	  	:= paramixb[1]
LOCAL cMsgErro	:= ""
LOCAL cArq		:= "PLSRXMLT" + AllTrim(aPar:XmlFile) + ".HTM"
LOCAL cArqHTM 	:= __RELIMP + cArq
//��������������������������������������������������������������������������������������������������
//� Se o diretorio nao existir cria
//��������������������������������������������������������������������������������������������������
If setDirRel()
	//��������������������������������������������������������������������������������������������������
	//� Processa o relatorio
	//��������������������������������������������������������������������������������������������������
	aRet := PLSRXMLT(aPar:XmlFile)
	//aRet[1] := .T. ou .F.
	//aRet[2] := Erro caso exista
	//aRet[3] := caminho e o Nome do arquivo com extensao \SPOOL\PLSRXXX.##R
	//������������������������������������������������������������������������Ŀ
	//� Verifica o retorno													   �
	//��������������������������������������������������������������������������
	If !aRet[1]
		cMsgErro := aRet[2]
	EndIf
	//��������������������������������������������������������������������������
	//� Se nao teve nenhum problema no processamento
	//��������������������������������������������������������������������������
	If Empty(cMsgErro)
		//��������������������������������������������������������������������������
		//� Nome do arquivo com extensao
		//��������������������������������������������������������������������������
		cArqRel := aRet[3]
		//��������������������������������������������������������������������������
		//� Abertura do arquivo
		//��������������������������������������������������������������������������
		PLSLOGFIL( WCFTxtHtm('A') ,cArqHTM )
		//��������������������������������������������������������������������������
		//� Para ajustar o arquivo txt gerado no spool Retirar caracter especial
		//� e colocar o resultado em um arquivo htm
		//��������������������������������������������������������������������������
		if getDadRel( cArqRel ,cArqHTM) == -1
			cMsgErro := 'Arquivo de SPOOL n�o encontrado'
		endIf
		//��������������������������������������������������������������������������
		//� Abertura do arquivo htm
		//��������������������������������������������������������������������������
		PLSLOGFIL( WCFTxtHtm('F') ,cArqHTM )
	EndIf
EndIf
//��������������������������������������������������������������������������
//� Fim da Funcao
//��������������������������������������������������������������������������
Return( { cArq , cMsgErro } )

//-------------------------------------------------------------------
/*/{Protheus.doc} PPRELRG
Impresao recurso de glosa 

@author  PLS TEAM
@version P11
@since   23.09.15
/*/
//------------------------------------------------------------------- 
User Function PPRELRG()
LOCAL aPar 	  	:= paramixb[1] // NA POSI��O 2 � PASSADO A VERS�O DA TISS 
LOCAL cMsgErro  := ' '
LOCAL cArqName	:= ""
LOCAL aArea   	:= GetArea()
LOCAL aAreaBEA  := BEA->(GetArea())
LOCAL aAreaBE4  := BE4->(GetArea())
LOCAL aAreaBD5  := BD5->(GetArea())
LOCAL nRecno	:= iif(valType(aPar)=='N',aPar,aPar:RECNO)
LOCAL cTissVer	:= "2.02.03"
LOCAL lChkFile	:= .T.
local cNumGuia	:= ''
local cTipo		:= ''
local lRet		:= .t.
local aGuiaGen	:= {}
local lWeb		:= .t.
local nLayout	:= 1

// NA POSI��O 2 � PASSADO O PARAMETRO MV_PWAITR
// INDICA SE FAZ VERIFICA��O DE ARQUIVO NA PASTA(LENTID�O)
if len(Paramixb) > 1
	lChkFile := Paramixb[2]
endIf

// NA POSI��O 3 � PASSADO A VERS�O DA TISS
if len(Paramixb) > 2
	cTissVer := Paramixb[3]
endIf

if len(Paramixb) > 3
	lWeb := Paramixb[4]
endIf

//Se o diretorio nao existir cria
if lWeb
	lRet := setDirRel()
endIf	

if lRet
	//Recurso de glosa
	if PLSALIASEXI("B4D") .and. valType(nRecno) == 'N'
		
		B4D->(dbGoTo(nRecno))

		if B4D->B4D_STATUS == '0'
			cMsgErro := 'Para impress�o necess�rio protocolar o recurso de glosa!'
			lRet 	 := .f.
		endIf
				
		if lRet	    		
			aadd(aGuiaGen, mtaDados(cTipo,'10'))
			
			if len(aGuiaGen) > 0
			
				cArqName := PLTISRGLO(aGuiaGen, nLayout,, lWeb, __RELIMP)
				cMsgErro := ''
	
			endIf			
		endIf	
	endIf
	
endIf

//Aqui estou garantindo que o PDF ja foi gerado e ja esta disponivel para download
if lRet .and. findFunction('PLSCHKRP') .and. lWeb
	if lChkFile
		PLSCHKRP(__RELIMP,cArqName)	
	endIf
endIf	

RestArea(aArea)
RestArea(aAreaBEA)
RestArea(aAreaBE4)
RestArea(aAreaBD5)

Return( { cArqName, cMsgErro } )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PPRELST   �Autor  �Totvs               � Data �  20/09/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Guia SADT em PDF											  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function PPRELST()
LOCAL aPar 	  	:= Paramixb[1] // NA POSI��O 2 � PASSADO A VERS�O DA TISS 
LOCAL cMsgErro	:= ""
LOCAL cArqName	:= ""
LOCAL aGuiaGen 	:= {}
LOCAL aArea   	:= GetArea()
LOCAL aAreaBEA  := BEA->(GetArea())
LOCAL aAreaBE4  := BE4->(GetArea())
LOCAL aAreaBD5  := BD5->(GetArea())
LOCAL cTipoGui	:= 0
LOCAL cNumGuia	:= AllTrim(StrTran(StrTran(aPar:NumAut,".",""),"-",""))
LOCAL lEntrou   := .F.
LOCAL cTissVer	:= "2.02.03"
LOCAL lChkFile	:= .T.
LOCAL nQtdProc	:= 0
LOCAL nTimeSleep:= 2000
LOCAL lImpGuiNeg:= .F. //parametro para impress�o de guia em an�lise
Local cTp 		:= aPar:TP

//********************************************************
// NA POSI��O 2 � PASSADO O PARAMETRO MV_PWAITR
// INDICA SE FAZ VERIFICA��O DE ARQUIVO NA PASTA(LENTID�O)
//******************************************************** 
If Len(Paramixb) > 1
	lChkFile := Paramixb[2]
EndIf
//********************************************
// NA POSI��O 3 � PASSADO A VERS�O DA TISS
//******************************************** 
If Len(Paramixb) > 2
	cTissVer := Paramixb[3]
EndIf

// NA POSI��O 4 � PASSADO O VALOR DO PARAMETRO MV_IGUINE
If Len(Paramixb) > 3
	lImpGuiNeg := Paramixb[4]
EndIf

//��������������������������������������������������������������������������������������������������
//� Se o diretorio nao existir cria
//��������������������������������������������������������������������������������������������������
If setDirRel()

	//impressao de guia de honorario individual
	If  !empty(cNumGuia)
		 BD5->(DbSetOrder(17))
	     If BD5->(MsSeek(xFilial("BD5")+cNumGuia)) .AND. BD5->BD5_TIPGUI == "06"
	
	     	aAdd(aGuiaGen, PLSGHONI(1))
			If Len(aGuiaGen) > 0
				If cTissVer >= "3"
					cArqName := PLSTISSG(aGuiaGen, .F.,2,nil, .T., __RELIMP)
				Endif
			Endif
	     	lEntrou := .T.
	     Endif
	Endif
	
	
	//IMPRESSAO DOS ANEXOS CLINICOS
	if !lEntrou .and. (empty(cTp) .or. cTp $ "07,08,09" )
		If PLSALIASEXI("B4A") .and. !empty(cNumGuia)
			 B4A->(DbSetOrder(1))
		     If B4A->(MsSeek(xFilial("B4A")+cNumGuia))
				aRet	 := PLS09AIma(.T.,__RELIMP)
				If aRet[1]
					cArqName := aRet[3]
				Else
					cMsgErro := aRet[2]
				Endif
				lEntrou := .T.
		     Endif
		Endif
	endif

	if  empty(cTp) .or. cTp == "11" .or. aPar:Prorrog == ".T." 
		If !lEntrou .AND. PLSALIASEXI("B4Q") .and. !empty(cNumGuia)
			 B4Q->(DbSetOrder(1))
		     If B4Q->(MsSeek(xFilial("B4Q")+cNumGuia))
		     	
		     	If B4Q->B4Q_CANCEL == '1' 
					cMsgErro := 'Guia cancelada'
					Return( { cArqName, cMsgErro } )
				
				ElseIf B4Q->B4Q_STATUS == '3' .AND. !lImpGuiNeg
					cMsgErro := 'Guia n�o autorizada'
					Return( { cArqName, cMsgErro } )
				
				ElseIf B4Q->B4Q_STATUS == '6' .AND. !lImpGuiNeg
					cMsgErro := 'Guia em an�lise'
					Return( { cArqName, cMsgErro } )
				EndIf 
		     
				aAdd(aGuiaGen, MtaDados(nil,'11'))
				
				If Len(aGuiaGen) > 0
					cArqName := (PLSTISSP(aGuiaGen, .F., 2, nil, .F., .T., __RELIMP)[3])
				Endif
		     	lEntrou := .T.

			 // Se selecionado prorrogacao, verifico se tem BQV para a internacao
			 // (antigo modelo que a prorogacao era lancada direta na solic de internacao)	
			 ElseIf aPar:Prorrog == ".T." 
			 	
				BE4->( DbSetOrder(2) )
				If BE4->( MsSeek( xFilial("BE4") + cNumGuia ) )
						
					BQV->(DbSetOrder(1))
					If !BQV->(MsSeek(xFilial("BQV")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)))
						cMsgErro := 'Guia sem prorroga��o'
						Return( { cArqName, cMsgErro } )
					EndIf
					
					aAdd(aGuiaGen, MtaDados(nil,'11',.T.))
					If Len(aGuiaGen) > 0
						cArqName := (PLSTISSP(aGuiaGen, .F., 2, nil, .F., .T., __RELIMP)[3])
					Endif
		     		lEntrou := .T.
				EndIf
			 ENDIF	
		Endif	
	endif

	If !lEntrou .and. !empty(cNumGuia) 
		
	    BEA->( DbSetOrder(1) )//BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT+DTOS(BEA_DATPRO)+BEA_HORPRO
	    If BEA->( MsSeek(xFilial("BEA") + cNumGuia) )
	    	cTipoGui := BEA->BEA_TIPO

			//��������������������������������������������������������������������������������������������������
			//� Caso a Guia for Odonto, posiciona o BD5
			//��������������������������������������������������������������������������������������������������
			If cTipoGui == "4"
				BD5->(DbSetOrder(1))
				If !BD5->(MsSeek(xFilial("BD5")+BEA->(BEA_OPEPEG+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI)))
					cMsgErro := 'Guia n�o encontrada'
					Return( { cArqName, cMsgErro } )
				EndIf
			EndIf
			
			//��������������������������������������������������������������������������������������������������
			//� Caso a Guia for Interna��o, posiciona o BE4
			//��������������������������������������������������������������������������������������������������
			If cTipoGui == "3"
				
				BE4->( DbSetOrder(2) )
				If BE4->( MsSeek( xFilial("BE4") + cNumGuia ) )
					
					If BE4->BE4_CANCEL == '1' 
						cMsgErro := 'Guia cancelada'
						Return( { cArqName, cMsgErro } )
					
					ElseIf BE4->BE4_STATUS == '3' .AND. !lImpGuiNeg
						cMsgErro := 'Guia n�o autorizada'
						Return( { cArqName, cMsgErro } )
					
					ElseIf BE4->BE4_STATUS == '6' .AND. !lImpGuiNeg
						cMsgErro := 'Guia em an�lise'
						Return( { cArqName, cMsgErro } )
					EndIf
				Else
					cMsgErro := 'Guia n�o encontrada'
					Return( { cArqName, cMsgErro } )
				EndIf
			Else
				If BEA->BEA_CANCEL == '1' 
					cMsgErro := 'Guia cancelada'
					Return( { cArqName, cMsgErro } )
				
				ElseIf BEA->BEA_STATUS == '3' .AND. !lImpGuiNeg
					cMsgErro := 'Guia n�o autorizada'
					Return( { cArqName, cMsgErro } )
				
				ElseIf (BEA->BEA_STATUS == '6' .And. !PLIBAUD(@cNumGuia)) .AND. !lImpGuiNeg
					cMsgErro := 'Guia em an�lise'
					Return( { cArqName, cMsgErro } )
				
				ElseIf BEA->BEA_LIBERA == "1" .AND. cTipoGui == "2" .AND. !PLSSALDO("",BEA->(BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT)) .And. GetNewPar("MV_PLIMSAE","0") == "0" 
					cMsgErro := 'Esta guia de solicita��o ja foi executada ou n�o possui saldo, proceda com a impress�o da guia de execu��o.'
					Return( { cArqName, cMsgErro } )
				EndIf
			EndIf 

			aAdd(aGuiaGen, MtaDados(cTipoGui)) 
				
			If Len(aGuiaGen[1]) > 0 

				If cTipoGui == "1" // CONSULTA
					If ExistBlock("PLR430CONS")
						aGuiaGen := ExecBlock("PLR430CONS",.F.,.F.,{aGuiaGen})
					EndIf
					If cTissVer <= "3.99" // TISS 3.0
						cArqName := PLSTISSD(aGuiaGen, .F.,,, .T., __RELIMP)
					Else
						cArqName := PLSTISS1(aGuiaGen, .F.,,, .T., __RELIMP) //Ajustaram a TISS 4 nessa fun��o. 
					EndIf
				ElseIf cTipoGui == "2" // SADT
					If ExistBlock("PLR430SADT")
						aGuiaGen := ExecBlock("PLR430SADT",.F.,.F.,{aGuiaGen})
					EndIf
					If cTissVer >= "3" // TISS 3.0
						cArqName := PlsTISSC(aGuiaGen, .F.,,, .T., __RELIMP)
					Else
						cArqName := PLSTISS2(aGuiaGen, .F.,,, .T., __RELIMP)
					EndIf					
					
				ElseIf cTipoGui == "3" // Interna��o
					If ExistBlock("PLR430INT")
						aGuiaGen := ExecBlock("PLR430INT",.F.,.F.,{aGuiaGen})
					EndIf
					If cTissVer >= "3" // TISS 3.0
						cArqName := PLSTISSE(aGuiaGen, .F.,,,, .T., __RELIMP,aPar:Prorrog)[3]
					Else
						cArqName := PLSTISS3(aGuiaGen, .F.,,,, .T., __RELIMP)[3]
					EndIf
				ElseIf cTipoGui == "4" // ODONTO  ---- TISS 3.0 -- Linha comentada para que a guia tiss de odonto vai pela guia correta.
						cArqName := PLSTISS9(aGuiaGen, , ,.F., .T.,__RELIMP)
				EndIf
			EndIf
		Else
			cMsgErro := 'Guia n�o encontrada!'
		EndIf
	Endif
EndIf
//��������������������������������������������������������������������������
//� Aqui estou garantindo que o PDF ja foi gerado e ja esta disponivel para download
//��������������������������������������������������������������������������
if empty(cMsgErro) .and. Findfunction('PLSCHKRP')
	If lChkFile	
		//Para at� 10 procedimentos, mant�m sempre o default da fun��o PLSCHKRP que � 2000ms (2 segundos). Acima disso, adiciona 0.1segundo para cada procedimento
		if len(aGuiaGen) > 0 .and. len(aGuiaGen[1]) > 35 .and. aGuiaGen[1][36] != NIL
			nQtdProc := len(aGuiaGen[1][36])
			
			if nQtdProc > 10		
				nTimeSleep := nQtdProc * 300
				
				if nTimeSleep > 180000
					nTimeSleep := 180000
				endif
			endif			
		endif
	
		PLSCHKRP(__RELIMP,cArqName,nTimeSleep)	
	Endif
endIf	

RestArea(aArea)
RestArea(aAreaBEA)
RestArea(aAreaBE4)
RestArea(aAreaBD5)

Return( { cArqName, cMsgErro } )
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PPRELDPM  �Autor  �Totvs               � Data �  15/01/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Relatorio de demonstrativo de pagamento medico			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
user function PPRELDPM()
LOCAL cMsgErro	:= ""
LOCAL aPar 	  	:= paramixb[1]
LOCAL cCodRda	:= aPar:Rda
LOCAL cAno		:= aPar:Ano
LOCAL cMes		:= aPar:Mes
LOCAL cArqName	:= ""
//��������������������������������������������������������������������������������������������������
//� Se o diretorio nao existir cria
//��������������������������������������������������������������������������������������������������
if setDirRel()
	//��������������������������������������������������������������������������������������������������
	//� Imprimi capa do peg
	//��������������������������������������������������������������������������������������������������
	aRet 	 := PLSRELDPM(cCodRda,cAno,cMes,.t.,__RELIMP)
	cArqName := aRet[1]
	cMsgErro := aRet[2]
endIf
	
//� Fim da Funcao
//��������������������������������������������������������������������������
return( { cArqName, cMsgErro } )
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PPRELEPM  �Autor  �Totvs               � Data �  15/01/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Relatorio de extrato de pagamento medico			  		  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
user function PPRELEPM()
LOCAL cMsgErro	:= ""
LOCAL aPar 	  	:= paramixb[1]
LOCAL cCodRda	:= aPar:Rda
LOCAL cAno		:= aPar:Ano
LOCAL cMes		:= aPar:Mes
LOCAL cArqName	:= ""
//��������������������������������������������������������������������������������������������������
//� Se o diretorio nao existir cria
//��������������������������������������������������������������������������������������������������
if setDirRel()
	//��������������������������������������������������������������������������������������������������
	//� Imprimi capa do peg
	//��������������������������������������������������������������������������������������������������
	aRet 	 := PLSRELEPM(cCodRda,cAno,cMes,.t.,__RELIMP)
	cArqName := aRet[1]
	cMsgErro := aRet[2]
endIf
//��������������������������������������������������������������������������
//� Fim da Funcao
//��������������������������������������������������������������������������
return( { cArqName, cMsgErro } )
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PPRELDAC  �Autor  �Totvs               � Data �  22/01/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Relatorio de demonstrativo de analise de conta medica		  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
user function PPRELDAC()
LOCAL cMsgErro	:= ""
LOCAL aPar 	  	:= paramixb[1]
LOCAL cCodRda	:= aPar:Rda
LOCAL cAno		:= aPar:Ano
LOCAL cMes		:= aPar:Mes
LOCAL cArqName	:= ""
//��������������������������������������������������������������������������������������������������
//� Se o diretorio nao existir cria
//��������������������������������������������������������������������������������������������������
if setDirRel()
	//��������������������������������������������������������������������������������������������������
	//� Imprimi capa do peg
	//��������������������������������������������������������������������������������������������������
	aRet 	 := PLSRELDAC(cCodRda,cAno,cMes,.t.,__RELIMP)
	cArqName := aRet[1]
	cMsgErro := aRet[2]
endIf
//��������������������������������������������������������������������������
//� Fim da Funcao
//��������������������������������������������������������������������������
return( { cArqName, cMsgErro } )
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PPRELDPO  �Autor  �Totvs               � Data �  22/01/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Relatorio de demonstrativo de pagamento odontologico		  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
user function PPRELDPO()
LOCAL cMsgErro	:= ""
LOCAL aPar 	  	:= paramixb[1]
LOCAL cCodRda	:= aPar:Rda
LOCAL cAno		:= aPar:Ano
LOCAL cMes		:= aPar:Mes
LOCAL cArqName	:= ""
//��������������������������������������������������������������������������������������������������
//� Se o diretorio nao existir cria
//��������������������������������������������������������������������������������������������������
if setDirRel()
	//��������������������������������������������������������������������������������������������������
	//� Imprimi capa do peg
	//��������������������������������������������������������������������������������������������������
	aRet 	 := PLSRELDPO(cCodRda,cAno,cMes,.t.,__RELIMP)
	cArqName := aRet[1]
	cMsgErro := aRet[2]
endIf
//��������������������������������������������������������������������������
//� Fim da Funcao
//��������������������������������������������������������������������������
return( { cArqName, cMsgErro } )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PPRELPEG  �Autor  �Totvs               � Data �  20/02/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Relatorio de PEG (protocolo eletronico de guias)			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
user function PPRELPROT()
LOCAL cMsgErro	:= ""
LOCAL aPar 	  	:= paramixb[1]
LOCAL cChave	:= If(valtype(aPar:protocolo)<>'U',aPar:protocolo,"")
LOCAL nRecno	:= If(valtype(aPar:recno)  <>'U',aPar:Recno,0)
LOCAL cArqName	:= ""    
//��������������������������������������������������������������������������������������������������
//� Se o diretorio nao existir cria
//��������������������������������������������������������������������������������������������������
If setDirRel()
	//��������������������������������������������������������������������������������������������������
	//� Imprime protocolo de reembolso do benefici�rio
	//��������������������������������������������������������������������������������������������������
	If nRecno > 0
		
		BOW->(DbGoTo(nRecno))
		cChave := BOW->BOW_PROTOC
	EndIf
	cArqName := PLSRPROT(cChave,__RELIMP,.t.)[1] // PLSRCPRT
EndIf
//��������������������������������������������������������������������������
//� Aqui estou garantindo que o PDF ja foi gerado e ja esta disponivel para download
//�������������������������������������������������������������������������� 
If !Empty(cArqName) .and. Findfunction('PFileReady')
	PFileReady(__RELIMP, cArqName)
Endif	
//��������������������������������������������������������������������������
//� Fim da Funcao
//��������������������������������������������������������������������������
Return( { cArqName, cMsgErro } ) 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PPRELDoc  �Autor  �Totvs               � Data �  11/05/2015���
�������������������������������������������������������������������������͹��
���Desc.     �Relatorio de documentos(Contrato e Aditivo)      			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
user function PPRELDoc()
LOCAL cMsgErro	:= ""
LOCAL aPar  		:= paramixb[1] 
LOCAL nRecno		:= If(valtype(aPar:recno)  <>'U',aPar:Recno,0)
LOCAL cArqName	:= "" 
LOCAL cFile   	:= ""
Local cDirDocs	:= ""
Local cDirParam	:= MsDocRmvBar( AllTrim( GetMV( "MV_DIRDOC" ) ) )
Local cDir	 	   := PLSMUDSIS( getWebDir() + getSkinPls() + "\relatorios\") 

If FindFunction( "MsMultDir" ) .And. MsMultDir() .And. ACB->(FieldPos("ACB_PATH"))>0 .And. !Empty( ACB->ACB_PATH )
	cDirDocs := Alltrim( ACB->ACB_PATH )
Else
	cDirDocs := MsDocPath()
Endif

If nRecno > 0
	B2H->(DbGoTo(nRecno))
	cArqName := B2H->B2H_PATH
	If !Empty(cArqName)
		AC9->( DbSelectArea("AC9") )
		AC9->( DbSetOrder(2) )
		
		If AC9->( MsSeek( xFilial("AC9")+"B2H"+B2H->(B2H_FILIAL+B2H_FILIAL+B2H_RDA+B2H_DOC+B2H_REV+B2H_SEQ)))
			ACB->( DbSelectArea("ACB") )
			ACB->( DbSetOrder(1) )
			If ACB->( MsSeek( xFilial("ACB")+AC9->AC9_CODOBJ))	
			
				cArqName := ALLTRIM(ACB->ACB_OBJETO)
				
				//���������������������������������������������������������������������������������������������������Ŀ
				//� Importante: O sistema n�o l� o arquivo do diretorio do banco de conhecimento, por esse motivo     �
				//� � necessario efetuar a copia para do Banco de conhecimento para o diret�rio  local especificado   �
				//�����������������������������������������������������������������������������������������������������
				__CopyFile( cDirDocs + "\" + Upper(AllTrim(ACB->ACB_OBJETO)), cDir + Upper(AllTrim(ACB->ACB_OBJETO)))
				
				If !Empty(cArqName) .And. !Empty(cDir)
					PFileReady(cDirDocs + "\", Upper(cArqName))//Tem que ser em maisculo para padronizar e poder localizar o arquivo
				Endif
			Endif			
       Endif
    Endif   	

Endif	

//��������������������������������������������������������������������������
//� Fim da Funcao
//��������������������������������������������������������������������������
Return( { cArqName, cMsgErro } ) 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �  �Autor  � Oscar Zanin              � Data � 16/11/2015    ���
�������������������������������������������������������������������������͹��
���Desc.     �PLSQUIT - Declara��o anual de quita��o de d�bitos no Portal ��� 
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
user function PLSQUIT(lAuto,aParam)
Local cMsgErro	:= ""
Local aRet		:= {}

Default aDados	:= {}	
Default lAuto	:= .F.


If lAuto
	aDados	:= { aParam[1,1], aParam[1,2], aParam[1,3], aParam[1,4], aParam[1,5], aParam[1,6] }
Else
	aPar	:= paramixb[1]
	aDados	:= { aPar:Tipo, aPar:CodEmp, aPar:NumCon, aPar:SubCon, aPar:Matric, aPar:Ano }
Endif	

Private cArqName:= "quitacao.pdf" //Private para ser chamada dentro da fun��o do relat�rio e receber o valor real do nome

//��������������������������������������������������������������������������������������������������
//� Se o diretorio nao existir cria
//��������������������������������������������������������������������������������������������������
If setDirRel()

	If 	!lAuto .and. Val(aPar:Ano)>= year(Msdate()) // n�o podemos imprimir do ano corrente ou superior
		cArqName	:= ""  
		cMsgErro := 'Somente poder� ser impresso anos anteriores !'
	Else
		If findFunction("U_PLSQTDEB")
			//Executa relat�rio
			aRet 	:= A772Acao(aDados, .T., __RELIMP)
			If ValType(aRet) == "A"
				cArqName:= aRet[3]
			Endif	
		Else
			cMsgErro := 'Funcionalidade n�o habilitada'
		EndIf
	Endif	
EndIf

//��������������������������������������������������������������������������
//� Aqui estou garantindo que o PDF ja foi gerado e ja esta disponivel para download
//�������������������������������������������������������������������������� 
If !Empty(cArqName) .and. Findfunction('PFileReady')
	PFileReady(__RELIMP, cArqName)
Endif	

Return( { cArqName, cMsgErro } ) 
//-------------------------------------------------------------------
/*/{Protheus.doc} PPLSREPA
Estatistica de partos

@author  PLS TEAM
@version P11
@since   13.10.15
/*/
//------------------------------------------------------------------- 
user function PPLSREPA()
LOCAL aPar 	  	:= paramixb[1]
LOCAL cCodOpe	:= aPar:Operac
LOCAL cRdaHos	:= aPar:RdaHos
LOCAL cRdaMed	:= aPar:RdaMed
local cMsgErro	:= ""
local cArqName	:= ""

if setDirRel()
	aRet	 := PLSRELEP(cCodOpe,cRdaHos,cRdaMed,.t.,__RELIMP)
	cArqName := aRet[1]
	cMsgErro := aRet[2]
endIf

return( { cArqName, cMsgErro } )
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PPRELRCT  �Autor  �Roberto               � Data �  29/10/2015���
�������������������������������������������������������������������������͹��
���Desc.     �Relatorio de documentos(Receita)      			  		  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
user function PPRELRCT()
LOCAL cMsgErro	:= ""
LOCAL aPar  		:= paramixb[1] 
LOCAL cArqName	:= "" 
LOCAL cFile   	:= ""
Local cDirDocs	:= ""

if setDirRel()
	cArqName := PALSTRWeb(aPar:Protocolo)
endif

//��������������������������������������������������������������������������
//� Fim da Funcao
//��������������������������������������������������������������������������
Return( { cArqName, cMsgErro } )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSIMPBEN �Autor  � F�bio S. dos Santos� Data �  01/12/2015 ���
�������������������������������������������������������������������������͹��
���Desc.     � Relatorio de Solicita��o de Benefici�rios.				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function PLSIMPBEN()
Local cMsgErro	:= ""
Local aPar 	  	:= paramixb[1]
Local nRecno	:= If(valtype(aPar:recno) <> 'U',aPar:Recno,0)
Local cArqName	:= ""    
Local aRet		:= {}
//��������������������������������������������������������������������������������������������������
//� Se o diretorio nao existir cria
//��������������������������������������������������������������������������������������������������
If setDirRel()
	//��������������������������������������������������������������������������������������������������
	//� Imprime Solicita��o de Benefici�rios
	//��������������������������������������������������������������������������������������������������
	If nRecno > 0
		
		BBA->(DbGoTo(nRecno))
		If ExistBlock("PLSR956U")
			aRet := ExecBlock("PLSR956U",.F.,.F.,{nRecno,.T.,__RELIMP})
		Else
			aRet := PLSR956(nRecno,.T.,__RELIMP)
		EndIf
		 	 
		cArqName := aRet[1]
		cMsgErro := aRet[2]
	EndIf
	
EndIf

//��������������������������������������������������������������������������
//� Fim da Funcao
//��������������������������������������������������������������������������
Return( { cArqName, cMsgErro } ) 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PPRELGUI  �Autor  �Totvs               � Data �  02/12/15   ���
�������������������������������������������������������������������������͹��
���Desc.     �Ipress�o de guias TISS em branco							  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
user function PPRELGUI() //02-12
LOCAL cMsgErro	:= ""
LOCAL aPar 	  	:= paramixb[1]
LOCAL cTipoGui	:= If(valtype(aPar:Tipo)<>'U',aPar:Tipo,"")
LOCAL nQtd		:= If(valtype(aPar:recno)  <>'U',aPar:Recno,0)
LOCAL cArqName	:= ""    

//��������������������������������������������������������������������������������������������������
//� Se o diretorio nao existir cria
//��������������������������������������������������������������������������������������������������
If setDirRel()

	//��������������������������������������������������������������������������������������������������
	//� Imprime o tipo de guia selecionada
	//��������������������������������������������������������������������������������������������������
	cArqName := PLIMPGUIB(ALLTRIM(cTipoGui),nQtd,.T.) 
EndIf

//�����������������������������������������������������������������������������������
//� Aqui estou garantindo que o PDF ja foi gerado e ja esta disponivel para download
//����������������������������������������������������������������������������������� 
If !Empty(cArqName) .and. Findfunction('PFileReady')
	PFileReady(__RELIMP, cArqName)
Endif	

//��������������������������������������������������������������������������
//� Fim da Funcao
//��������������������������������������������������������������������������
return( { cArqName, cMsgErro } )


/*
�����������������������������������������������������������������������������
���Programa  �PPRELRBANL  �Autor  �Renan Martins       � Data �  11/2015  ���
�������������������������������������������������������������������������͹��
���Desc.     �Relat�rio de An�lise de Reembolso.						  ���
�����������������������������������������������������������������������������
*/
User Function PPRELRBANL()
LOCAL cMsgErro	:= ""
LOCAL aPar 	  	:= paramixb[1]
LOCAL cArqName	:= ""
LOCAL cNumero	:= aPar:ChaveGen
//��������������������������������������������������������������������������������������������������
//� Se o diretorio nao existir cria
//��������������������������������������������������������������������������������������������������
If setDirRel()
	//��������������������������������������������������������������������������������������������������
	//� Imprimi capa do peg
	//��������������������������������������������������������������������������������������������������
	aRet	 := U_PLSR788(.T.,aPar,__RELIMP, cNumero)
	cArqName := aRet[1]
	cMsgErro := aRet[2]
EndIf

//�����������������������������������������������������������������������������������
//� Aqui estou garantindo que o PDF ja foi gerado e ja esta disponivel para download
//����������������������������������������������������������������������������������� 
If !Empty(cArqName) .and. Findfunction('PFileReady')
	PFileReady(__RELIMP, cArqName)
Endif	

//��������������������������������������������������������������������������
//� Fim da Funcao
//��������������������������������������������������������������������������
Return( { cArqName, cMsgErro } )



/*
�����������������������������������������������������������������������������
���Programa  �PPRELEXTUTI  �Autor  �Renan Martins    � Data �  11/2015    ���
�������������������������������������������������������������������������͹��
���Desc.     �Extrato de utiliza��o 									  ���
�����������������������������������������������������������������������������
*/
User Function PPRELEXTUTI()
LOCAL cMsgErro	:= ""
LOCAL aPar 	  	:= paramixb[1]
LOCAL cArqName	:= ""
LOCAL cNumero	:= aPar:ChaveGen
//��������������������������������������������������������������������������������������������������
//� Se o diretorio nao existir cria
//��������������������������������������������������������������������������������������������������
If setDirRel()
	//��������������������������������������������������������������������������������������������������
	//� Imprimi capa do peg
	//��������������������������������������������������������������������������������������������������
	aRet	 := U_PLSR789(.T.,aPar,__RELIMP, cNumero)
	cArqName := aRet[1]
	cMsgErro := aRet[2]
EndIf

//�����������������������������������������������������������������������������������
//� Aqui estou garantindo que o PDF ja foi gerado e ja esta disponivel para download
//����������������������������������������������������������������������������������� 
If !Empty(cArqName) .and. Findfunction('PFileReady')
	PFileReady(__RELIMP, cArqName)
Endif	

//��������������������������������������������������������������������������
//� Fim da Funcao
//��������������������������������������������������������������������������
Return( { cArqName, cMsgErro } )
//-------------------------------------------------------------------
/*/{Protheus.doc} PPLSRECB
Carteirinha do beneficiario

@author  PLS TEAM
@version P11
@since   13.10.15
/*/
//------------------------------------------------------------------- 
user function PPLSRECB()
LOCAL aPar 	  	:= paramixb[1]
LOCAL cMatric	:= aPar:Matric
local cMsgErro	:= ""
local cArqName	:= ""

if setDirRel()

	if existBlock("PLRRN360")
		aRet 	 := execBlock("PLRRN360",.F.,.F.,{cMatric,{},.t.,__RELIMP})
		cArqName := aRet[1]
		cMsgErro := aRet[2]
	endIf
	
endIf

return( { cArqName, cMsgErro } )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PPREEFINA  �Autor  �Totvs               � Data �  02/12/15  ���
�������������������������������������������������������������������������͹��
���Desc.     �Impres�o do relat�rio de exttrato financeiro				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
user function PPREEFINA()
LOCAL cMsgErro	:= ""
LOCAL aPar 	  	:= paramixb[1]
Local aDados	:= { aPar:dtDe, aPar:dtAte, aPar:matric, aPar:tipo, aPar:tp}
LOCAL cArqName	:= ""

//��������������������������������������������������������������������������������������������������
//� Se o diretorio nao existir cria
//��������������������������������������������������������������������������������������������������
If setDirRel()

	//��������������������������������������������������������������������������������������������������
	//� Imprime extrato financeiro
	//��������������������������������������������������������������������������������������������������
	cArqName := U_PLSR001(.T.,aDados,__RELIMP) 
EndIf

//�����������������������������������������������������������������������������������
//� Aqui estou garantindo que o PDF ja foi gerado e ja esta disponivel para download
//����������������������������������������������������������������������������������� 
If !Empty(cArqName) .and. Findfunction('PFileReady')
	PFileReady(__RELIMP, cArqName)
Endif	

//��������������������������������������������������������������������������
//� Fim da Funcao
//��������������������������������������������������������������������������
return( { cArqName, Iif(Empty(cArqName),cMsgErro,"") } ) 

