#INCLUDE "PROTHEUS.CH"
#INCLUDE "FATA520.CH" 

#DEFINE NTAMCOD 2

Static cVendIgn		:= Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FATA520   �Autor  �Vendas CRM          � Data �  08/10/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Exibicao da amarracao entre vendedores e contas             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �FATA520                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Fata520()

Private aRotina		:= MenuDef()
Private cCadastro	:= STR0014	//"Contas de vendedores"

DbSelectArea("SX2")
DbSetOrder(1)

mBrowse(,,,,"ADL")

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft520Proc �Autor  �Vendas CRM          � Data �  07/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Processa a base de clientes, suspects e prospects de cada   ���
���          �vendedor, dentro dos parametros.                            ���
�������������������������������������������������������������������������͹��
���Parametros�ExpL1    - Flag para interromper o processamento            ���
���          �ExpC2    - Codigo do vendedor inicial para processamento    ���
���          �ExpC3    - Codigo do vendedor final para processamento      ���
�������������������������������������������������������������������������͹��
���Uso       �FATA520                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ft520Proc(lEnd,cVendDe,cVendAte)

Local aArea	   		:= GetArea()				// Armazena posicionamento atual
Local aAreaSA3 		:= SA3->(GetArea())		// Armazena posicionamento da tabela SA3
Local aRecnos  		:= {}						// Lista com os recnos que serao deletados
Local cFilADL  		:= xFilial("ADL")			// Filial para a tabela ADL
Local cFilAD1  		:= xFilial("AD1")			// Filial para a tabela AD1
Local cFilAD2  		:= xFilial("AD2")			// Filial para a tabela AD2
Local cFilSA3		:= xFilial("SA3")			// Filial para a tabela SA3
Local cFilACH		:= xFilial("ACH")			// Filial para a tabela ACH
Local nX			:= 0     					// Auxiliar de loop
Local aPDFields	 	:= {"A3_NOME"}
Local lPDObfuscate	:= .F.
Local cNomeVend		:= ""

Default lEnd		:= .F.

//��������������������������������Ŀ
//�Se a nova workarea estiver ativa�
//����������������������������������
If !TcGetdb() $ "POSTGRES/INFORMIX" .And. !RddName() $ "CTREE"
	Return Ft520Proc2(lEnd, cVendDe, cVendAte)
EndIf

//��������������������������������������Ŀ
//�Recupera lista de vendedores ignorados�
//����������������������������������������
If cVendIgn == NIL
	cVendIgn	:= SuperGetMv("MV_FATVIGN",,"")
EndIf

DbSelectArea("AD1")
DbSetOrder(2)	//AD1_FILIAL+AD1_VEND+DTOS(AD1_DTINI)

DbSelectArea("AD2")
DbSetOrder(2)	//AD2_FILIAL+AD2_VEND+AD2_NROPOR+AD2_REVISA

DbSelectArea("SA3")

nX := RecCount()
ProcRegua(nX)

//������������������������������������������������������Ŀ
//�Se o reprocessamento for completo, limpa a ADL via SQL�
//�para agilizar o processo                              �
//��������������������������������������������������������
If Empty(cVendDe) .AND. ("ZZZZZZ" $ AllTrim(Upper(cVendAte)))
	Ft520Limpa(.T.)
EndIf

//������������������������������Ŀ
//�Reprocessamento dos vendedores�
//��������������������������������
DbSetOrder(1) //A3_FILIAL+A3_COD
DbSeek(cFilSA3+cVendDe,.T.)


FTPDLoad(Nil,Nil,aPDFields)    
lPDObfuscate := FTPDIsObfuscate("A3_NOME")
If lPDObfuscate
	cNomeVend := FTPDObfuscate(SA3->A3_NOME)
EndIf

While !SA3->(Eof()) 			.AND.;
	SA3->A3_FILIAL	== cFilSA3	.AND.;
	SA3->A3_COD		<= cVendAte

	If !lPDObfuscate
		cNomeVend := AllTrim(SA3->A3_NOME)
	EndIf 
	IncProc(STR0008 + AllTrim(SA3->A3_COD) + " - " + cNomeVend) //"Processando vendedor "
	
	//�������������������
	//�Descarta ignorado�
	//�������������������
	If AllTrim(SA3->A3_COD) $ cVendIgn
		SA3->(DbSkip())
		Loop
	EndIf
	
	//�������������������������������Ŀ
	//�Tratamento para o botao cancela�
	//���������������������������������
	If lEnd .And. (lEnd := ApMsgNoYes(STR0009,STR0010)) //"Deseja cancelar a execu��o do processo?"##"Interromper"
		Exit
	EndIf
	                
	ADL->(DbSetOrder(4)) //ADL_FILIAL+ADL_VEND+ADL_FILENT+ADL_ENTIDA+ADL_CODENT+ADL_LOJENT
	
	//��������������������������Ŀ
	//�Apaga registros existentes�
	//����������������������������
	If ADL->(DbSeek(cFilADL+SA3->A3_COD))

		aRecnos	:= {}	             	

		While !ADL->(Eof()) 			.AND.;
			ADL->ADL_FILIAL	== cFilADL	.AND.;
			ADL->ADL_VEND	== SA3->A3_COD
			
			AAdd(aRecnos,ADL->(Recno()))
			ADL->(DbSkip())
			
		End
		
		Begin Transaction
		For nX := 1 to Len(aRecnos)
			ADL->(DbGoTo(aRecnos[nX]))
			RecLock("ADL",.F.)
			DbDelete()
			MsUnLock()
		Next nX

		End Transaction
		
	EndIf
	
	ADL->(DbSetOrder(1))	//ADL_FILIAL+ADL_CODOPO+ADL_VEND
	
	//����������������������������������������Ŀ
	//�Recria registros das entidades com a ADL�
	//������������������������������������������	

	//Recria vinculos com Suspects
	DbSelectArea("ACH")
	DbSetOrder(5)
	DbSeek(xFilial("ACH")+SA3->A3_COD)
	
	While !ACH->(Eof()) 				.AND.;
		ACH->ACH_FILIAL	== cFilACH 		.AND.;
		ACH->ACH_VEND	== SA3->A3_COD
		
		If Empty(ACH->ACH_CODPRO)
			RecLock("ADL",.T.)
			Replace ADL_FILIAL	With cFilADL
			Replace ADL_VEND	With SA3->A3_COD
			Replace ADL_FILENT	With cFilACH
			Replace ADL_ENTIDA	With "ACH"
			Replace ADL_CODENT	With ACH->ACH_CODIGO
			Replace ADL_LOJENT	With ACH->ACH_LOJA
			
			Replace ADL_NVLSTR	With SA3->A3_NVLSTR
			
			For nX := SA3->A3_NIVEL to 1 Step -1
				Replace &("ADL_NIVE"+StrZero(nX,2))	 With Left(SA3->A3_NVLSTR,nX*NTAMCOD)
			Next      
			
			MsUnLock()
		EndIf
		
		ACH->(DbSkip())

	End
 	
 	//Recria vinculos com Prospects
 	Ft520RpSUS()                  
 	
 	//Recria vinculos com Clientes
 	Ft520RpSA1()

	//��������������������������Ŀ
	//�Leitura do cabecalho (AD1)�
	//����������������������������
	AD1->(DbSetOrder(2))	//AD1_FILIAL+AD1_VEND+DTOS(AD1_DTINI)
	AD1->(DbSeek(cFilAD1+SA3->A3_COD))
	
	While !AD1->(Eof())				.AND.;
		AD1->AD1_FILIAL	== cFilAD1	.AND.;
		AD1->AD1_VEND	== SA3->A3_COD
		
		If ADL->(!DbSeek(cFilADL+AD1->AD1_NROPOR+SA3->A3_COD))
			
			//��������������������������Ŀ
			//�Insere registro como conta�
			//����������������������������
			If !Empty(AD1->AD1_PROSPE)
				Ft520InsOp(	3	   			, AD1->AD1_VEND		, "SUS"		, AD1->AD1_PROSPE	,;
			 				AD1->AD1_LOJPRO	, AD1->(AD1_NROPOR+AD1_REVISA)	)
			Else
				Ft520InsOp(	3	   			, AD1->AD1_VEND		, "SA1"		, AD1->AD1_CODCLI	,;
			 				AD1->AD1_LOJCLI	, AD1->(AD1_NROPOR+AD1_REVISA)	)
			End 
			
			If !Empty(AD1->AD1_NUMORC) .AND. ADL->(DbSeek(cFilADL+AD1->AD1_NROPOR+AD1->AD1_VEND))
	 	
		 		DbSelectArea("ADL")
		 		RecLock("ADL",.F.)
		 		ADL->ADL_CODORC	:= AD1->AD1_NUMORC
		 		MsUnLock()
		 		DbSelectArea("AD1")
	 	
		 	EndIf

		EndIf
		
		AD1->(DbSkip()) 
		
	End
	
	//���������������������Ŀ
	//�Leitura do time (AD2)�
	//�����������������������
	AD1->(DbSetOrder(1)) //AD1_FILIAL+AD1_NROPOR+AD1_REVISA
	AD2->(DbSeek(cFilAD2+SA3->A3_COD))
	
	While !AD2->(Eof())				.AND.;
		AD2->AD2_FILIAL	== cFilAD2	.AND.;
		AD2->AD2_VEND	== SA3->A3_COD
		
		If AD1->(DbSeek(cFilAD1+AD2->AD2_NROPOR+AD2->AD2_REVISA))	.AND.;
			ADL->(!DbSeek(cFilADL+AD1->AD1_NROPOR+AD2->AD2_VEND))
			
			//��������������������������Ŀ
			//�Insere registro como conta�
			//����������������������������
			If !Empty(AD1->AD1_PROSPE)
				Ft520InsOp(	3	   			, AD2->AD2_VEND		, "SUS"		, AD1->AD1_PROSPE	,;
			 				AD1->AD1_LOJPRO	, AD1->(AD1_NROPOR+AD1_REVISA)	)
			Else
				Ft520InsOp(	3	   			, AD2->AD2_VEND		, "SA1"		, AD1->AD1_CODCLI	,;
			 				AD1->AD1_LOJCLI	, AD1->(AD1_NROPOR+AD1_REVISA)	)
			End

		 	If !Empty(AD1->AD1_NUMORC) .AND. ADL->(DbSeek(cFilADL+AD1->AD1_NROPOR+AD2->AD2_VEND))
		 	
		 		DbSelectArea("ADL")
		 		RecLock("ADL",.F.)
		 		ADL->ADL_CODORC	:= AD1->AD1_NUMORC
		 		MsUnLock()
		 	
		 	EndIf                                     
			 	
		EndIf
	
		AD2->(DbSkip()) 
	
	End	
	
	SA3->(DbSkip())
	
End

FTPDLogUser('FT520PROC')

//Finaliza o gerenciamento dos campos com prote��o de dados.
FTPDUnLoad()

RestArea(aAreaSA3)
RestArea(aArea)


Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft520InsOp�Autor  �Vendas CRM          � Data �  21/12/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Insere vinculo entre entidade e vendedor a partir da oportu-���
���          �nidade                                                      ��� 
�������������������������������������������������������������������������͹��
���Parametros�ExpN1 - Numero da operacao (3-Inclusao,4-Alteracao,etc.)    ���
���          �ExpC2 - Codigo do vendedor                                  ���
���          �ExpC3 - Alias da entidade                                   ���
���          �ExpC4 - Codigo da entidade                                  ���
���          �ExpC5 - Loja da entidade                                    ���
���          �ExpC6 - Codigo da oportunidade/proposta/orcamento           ���
�������������������������������������������������������������������������͹��
���Uso       �FATA520                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ft520InsOp(	nOper	, cVendedor	, cEntidade	, cCodigo	,;
		 				cLoja	, cChave	)
Local lRet	:= Ft520Ins(	nOper	, cVendedor	, cEntidade	, cCodigo	,;
		  	   				cLoja	, 1			, cChave	, cChave	)
Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft520InsOr�Autor  �Vendas CRM          � Data �  21/12/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Insere vinculo entre entidade e vendedor a partir do orca-  ���
���          �mento                                                       ��� 
�������������������������������������������������������������������������͹��
���Parametros�ExpN1 - Numero da operacao (3-Inclusao,4-Alteracao,etc.)    ���
���          �ExpC2 - Codigo da entidade                                  ���
���          �ExpC3 - Loja da entidade                                    ���
���          �ExpC4 - Codigo da proposta/orcamento                        ���
���          �ExpC5 - Codigo da oportunidade                              ���
�������������������������������������������������������������������������͹��
���Uso       �FATA520                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ft520InsOr(nOper	, cCodigo	, cLoja		, cChave	,;
					cOportu	)

Local lRet		:= .T.

//���������������������������������������������������������Ŀ
//�Somente inclui relacionamento se o orcamento foi gerado a�
//�partir da oportunidade de vendas                         �
//�����������������������������������������������������������
If IsInCallStack("FATA300")
	lRet	:=  Ft520Ins(	nOper	, M->AD1_VEND	, "SA1"		, cCodigo	,;
			  				cLoja	, 2				, cChave	, cOportu	)
EndIf

Return lRet
		 				
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft520InsPr�Autor  �Vendas CRM          � Data �  21/12/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Insere vinculo entre entidade e vendedor a partir da propos-���
���          �ta                                                          ���   
�������������������������������������������������������������������������͹��
���Parametros�ExpN1 - Numero da operacao (3-Inclusao,4-Alteracao,etc.)    ���
���          �ExpC2 - Codigo do vendedor                                  ���
���          �ExpC3 - Alias da entidade                                   ���
���          �ExpC4 - Codigo da entidade                                  ���
���          �ExpC5 - Loja da entidade                                    ���
���          �ExpC6 - Codigo da oportunidade/proposta/orcamento           ���
�������������������������������������������������������������������������͹��
���Uso       �FATA520                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ft520InsPr(	nOper	, cVendedor	, cEntidade	, cCodigo	,;
		 				cLoja	, cChave	, cOportu	)
Local lRet	:= Ft520Ins(	nOper	, cVendedor	, cEntidade	, cCodigo	,;
		  					cLoja	, 3			, cChave	, cOportu	)
Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft520AltEn�Autor  �Microsiga           � Data �  10/15/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Alteracao da entidade no controle de contas.                ���
�������������������������������������������������������������������������͹��
���Parametros�ExpN1 - Numero da operacao (3-Inclusao,4-Alteracao,etc.)    ���
���          �ExpC2 - Codigo do vendedor                                  ���
���          �ExpC3 - Alias da entidade                                   ���
���          �ExpC4 - Codigo da entidade                                  ���
���          �ExpC5 - Loja da entidade                                    ���
�������������������������������������������������������������������������͹��
���Uso       �FATA520                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ft520AltEn(nOper	, cVendedor	, cEntidade	, cCodigo	,;
		 			cLoja	)

Local lRet :=	Ft520InEnt(	nOper	, cVendedor	, cEntidade	, cCodigo	,;
		 			  		cLoja	) 

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft520Ins  �Autor  �Vendas CRM          � Data �  12/21/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Insere/Atualiza os dados de controle de contas do vendedor  ���
���          �na tabela ADL                                               ��� 
�������������������������������������������������������������������������͹��
���Parametros�ExpN1 - Numero da operacao (3-Inclusao,4-Alteracao,etc.)    ���
���          �ExpC2 - Codigo do vendedor                                  ���
���          �ExpC3 - Alias da entidade                                   ���
���          �ExpC4 - Codigo da entidade                                  ���
���          �ExpC5 - Loja da entidade                                    ���
���          �ExpN6 - Opcao que indica se e orcamento(2) ou proposta(3)   ���
���          �ExpC7 - Proposta/orcamento                                  ���
���          �ExpC8 - Codigo da oportunidade                              ���
�������������������������������������������������������������������������͹��
���Uso       �FATA520                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Ft520Ins(	nOper	, cVendedor	, cEntidade	, cCodigo	,;
		 			  		cLoja	, nOpcao	, cChave	, cOportu	)

Local aArea		:= GetArea() 			// Armazena o posicionamento atual
Local aAreaADL	:= ADL->(GetArea())	// Armazena o posiciomanento da tabela ADL
Local aAreaSA3	:= SA3->(GetArea())	// Armazena o posiciomanento da tabela ADL
Local cFilADL	:= xFilial("ADL")		// Codigo de filial da tabela ADL
Local lRet		:= .T.					// Retorno da funcao 
Local aEntDel	:= {}					// Lista de relacionamentos a eliminar para a entidade
Local aRecDel	:= {}					// Lista de relacionamentos a serem eliminados antes da gravacao
Local lFirstRec	:= .F.					// Indica se sera gravado o primeiro registro
Local cFilEnt	:= ""					// Filial da entidade validada      
Local nX		:= 0					// Auxiliar de loop   

//��������������������������������������Ŀ
//�Recupera lista de vendedores ignorados�
//����������������������������������������
If cVendIgn == NIL
	cVendIgn	:= SuperGetMv("MV_FATVIGN",,"")
EndIf

If AllTrim(cVendedor) $ cVendIgn
	RestArea(aArea)
	Return lRet
EndIf

//�����������������Ŀ
//�Valida o vendedor�
//�������������������
DbSelectArea("SA3")
DbSetOrder(1)
lRet		:= !Empty(cVendedor) .AND. SA3->(DbSeek(xFilial("SA3")+cVendedor))

//�����������������Ŀ
//�Valida a entidade�
//�������������������
If lRet .AND. (nOper <> 5)
	
	lRet := Ft520Valid(@cEntidade,@cCodigo,@cLoja,@aEntDel)	
	
EndIf

//�����������������Ŀ
//�Efetua a gravacao�
//�������������������
If lRet
	
	cFilEnt	:= xFilial(cEntidade)
	
	Begin Transaction
	
	DbSelectArea("ADL")
	DbSetOrder(1)

	//���������������������������������Ŀ
	//�Inclusao/Alteracao de informacoes�
	//�����������������������������������
	If nOper <> 5	
		
		//����������������������������Ŀ
		//�Remove amarracoes anteriores�
		//������������������������������ 
		ADL->(DbSetOrder(4)) //ADL_FILIAL+ADL_VEND+ADL_FILENT+ADL_ENTIDA+ADL_CODENT+ADL_LOJENT		
		If ADL->(DbSeek(cFilADL+cVendedor+cFilEnt+cEntidade+cCodigo+cLoja))
		
			While !ADL->(Eof()) .AND.;
				ADL->(ADL_FILIAL+ADL_VEND+ADL_FILENT+ADL_ENTIDA+ADL_CODENT+ADL_LOJENT) == (cFilADL+cVendedor+cFilEnt+cEntidade+cCodigo+cLoja)				
				
				//�����������������������������������������Ŀ
				//�So vai remover registros sem oportunidade�
				//�������������������������������������������
				If Empty(ADL->ADL_CODOPO)
					AAdd(aRecDel,ADL->(Recno()))
				EndIf
				
				ADL->(DbSkip())	 
					
			End
			
			For nX := 1 to Len(aRecDel)
				ADL->(DbGoTo(aRecDel[nX]))
				RecLock("ADL",.F.)
				DbDelete()
				MsUnLock()
			Next nX
		EndIf
		
		//���������������������������Ŀ
		//�Cria ou altera os registros�
		//�����������������������������
		ADL->(DbSetOrder(1)) //ADL_FILIAL+ADL_CODOPO+ADL_VEND
		lFirstRec :=  !DbSeek(cFilADL+cOportu+cVendedor)
		
		While (!ADL->(Eof())			.AND.;
			ADL->ADL_FILIAL == cFilADL	.AND.;
			ADL->ADL_CODOPO == cOportu	.AND.;
			ADL->ADL_VEND	== cVendedor).OR.;
			lFirstRec
			        
			RecLock("ADL",lFirstRec)
		
			Replace ADL->ADL_FILIAL		With cFilADL
			Replace ADL->ADL_VEND  		With cVendedor
			Replace ADL->ADL_FILENT		With cFilEnt
			Replace ADL->ADL_ENTIDA		With cEntidade
			Replace ADL->ADL_CODENT		With cCodigo
			Replace ADL->ADL_LOJENT		With cLoja
			
			Replace ADL->ADL_CODOPO		With cOportu         			
			
			Replace ADL->ADL_NVLSTR	With SA3->A3_NVLSTR
			
			For nX := SA3->A3_NIVEL to 1 Step -1
				Replace &("ADL_NIVE"+StrZero(nX,2))	 With Left(SA3->A3_NVLSTR,nX*NTAMCOD)
			Next 

			
			Do Case
				Case nOpcao == 2
					Replace ADL->ADL_CODORC		With cChave
				Case nOpcao == 3
					Replace ADL->ADL_CODPRO		With cChave
			EndCase
		
			MsUnLock() 

			If !lFirstRec
				ADL->(DbSkip())
			Else 
				lFirstRec := .F.
				Exit
			EndIf

        End

		//��������������������������������������������������������Ŀ
		//�Remove os vinculos do vendedor com suspects ou prospects�
		//�que ja viraram prospects ou clientes,nesta ordem.       �
		//����������������������������������������������������������		
		Ft520Remov(aEntDel,cVendedor,cEntidade,cCodigo,cLoja)
	
	//�������������������������������������������������Ŀ
	//�Exclusao de orcamentos, propostas e oportunidades�
	//���������������������������������������������������
	Else

		//���������������������������������������������������������������������Ŀ
		//�Deleta a amarracao do vendedor com a oportunidade/orcamento/proposta �
		//�����������������������������������������������������������������������
		ADL->(DbSetOrder(1))

		If ADL->(DbSeek(cFilADL+cOportu))

			RecLock("ADL",.F.)
			DbDelete()
			MsUnLock()

		EndIf

		//����������������������������������������������Ŀ
		//�Mantem o vinculo entre a entidade e o vendedor�
		//������������������������������������������������
		ADL->(DbSetOrder(4))//ADL_FILIAL+ADL_VEND+ADL_FILENT+ADL_ENTIDA+ADL_CODENT+ADL_LOJENT
		
		If !ADL->(DbSeek(xFilial("ADL")+cVendedor+xFilial(cEntidade)+cEntidade+cLoja))
			Ft520AltEn(	3		, cVendedor	, cEntidade	, cCodigo	,;
			 			cLoja	)
		EndIf

	EndIf
	
	End Transaction
	

EndIf  

RestArea(aAreaSA3)
RestArea(aAreaADL)
RestArea(aArea)

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft520FimOp�Autor  �Vendas CRM          � Data �  01/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Remove registros do controle de contas apos o encerramento  ���
���          �da oportunidade de vendas                                   ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 - Codigo da oportunidade finalizada                   ���
�������������������������������������������������������������������������͹��
���Uso       �FATA520                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ft520FimOp(cOport)
Return Nil 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft520FimOr�Autor  �Vendas CRM          � Data �  01/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Remove registros do controle de contas apos o encerramento  ���
���          �do orcamento.                                               ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 - Codigo do orcamento finalizado                      ���
�������������������������������������������������������������������������͹��
���Uso       �FATA520                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ft520FimOr(cOrcam)

Local aArea	:= GetArea()

DbSelectArea("ADL")
DbSetOrder(2)	//ADL_FILIAL+ADL_CODORC

If DbSeek(xFilial("ADL")+cOrcam)
	
	RecLock("ADL",.F.)
	ADL->ADL_CODORC	:= ""
	MsUnLock()
	
EndIf

RestArea(aArea)

Return Nil 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft520Total�Autor  �Vendas CRM          � Data �  01/04/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Totaliza a quantidade de suspects, prospects e clientes para���
���          �o vendedor informado                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 - Codigo do vendedor                                  ���
�������������������������������������������������������������������������͹��
���Uso       �FATA520                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ft520Total(cVendedor)
Return Ft520Tota2(cVendedor) 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft520Limpa�Autor  �Vendas CRM          � Data �  01/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Remove registros deletados (somente em ambiente SQL).       ���
�������������������������������������������������������������������������͹��
���Parametros�ExpL1 - Indica se todos os registros devem ser apagados(ZAP)���
�������������������������������������������������������������������������͹��
���Uso       �FATA520                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Ft520Limpa(lDelTodos)

Local cQuery	:= ""	// Query enviada ao banco de dados

Default lDelTodos	:= .F.

//�������������������������������������������������������������Ŀ
//�Apaga registros deletados quando for utilizado banco de dados�
//���������������������������������������������������������������

cQuery	:= "DELETE FROM " + RetSqlName("ADL") 

If !lDelTodos
	
	cQuery	+= " WHERE "

	If TcSrvType() != "AS/400"
		cQuery	+= " D_E_L_E_T_ = '*' "
	Else
		cQuery	+= " @DELETED@ = '*' "
	EndIf

EndIf

TcSqlExec(cQuery)


Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MenuDef   �Autor  �Vendas CRM          � Data �  08/10/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Geracao do menu funcional                                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �FATA520                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()

Local aRotina	:={	{STR0015,"AxPesqui",0,1} ,;		//"Pesquisar"
					{STR0016,"AxVisual",0,2} ,;		//"Visualizar"
					{STR0017,"Ft520Repro",0,3} }	//"Reprocessar"

Return aRotina

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft520Valid�Autor  �Vendas CRM          � Data �  15/10/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida a entidade, verificando seus estagios.               ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 - Alias da entidade                                   ���
���          �ExpC2 - Codigo da entidade                                  ���
���          �ExpC3 - Loja da entidade                                    ���
���          �ExpC4 - Lista de registros a serem apagados na ADL          ���
�������������������������������������������������������������������������͹��
���Uso       �FATA520                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ft520Valid(cEntidade,cCodigo,cLoja,aEntDel)

Local aArea		:= GetArea()			//Armazena o posicionamento atual
Local lRet 		:= .T.					//Retorno da funcao
Local cFilEnt	:= xFilial(cEntidade)	//Filial da entidade validada

DbSelectArea(cEntidade)
DbSetOrder(1)

lRet := DbSeek(cFilEnt+cCodigo+cLoja)

//��������������������������������������������������Ŀ
//�Verifica se ha prospect para o suspect selecionado�
//����������������������������������������������������
If (lRet) .AND. (cEntidade == "ACH") .AND. !Empty(ACH->ACH_CODPRO)

	SUS->(DbSetOrder(1)) 

	If SUS->(DbSeek(xFilial("SUS")+ACH->ACH_CODPRO+ACH->ACH_LOJPRO))
	
		cEntidade	:= "SUS"
		cFilEnt		:= xFilial(cEntidade)
		cCodigo		:= ACH->ACH_CODPRO
		cLoja		:= ACH->ACH_LOJPRO
		lRet		:= SUS->(DbSeek(cFilEnt+cCodigo+cLoja))

		//�����������������������������������������������������Ŀ
		//�Armazena codigo do suspect para remover vinculo com o�
		//�vendedor                                             �
		//�������������������������������������������������������
		AAdd(aEntDel,{"ACH",ACH->ACH_CODIGO,ACH->ACH_LOJA})

	EndIf
	
EndIf

//������������������������������������������������Ŀ
//�Verifica se ha cliente para o prospect utilizado�
//��������������������������������������������������
If (lRet) .AND. (cEntidade == "SUS") .AND. !Empty(SUS->US_CODCLI)

	SA1->(DbSetOrder(1)) 

	If SA1->(DbSeek(xFilial("SA1")+SUS->US_CODCLI+SUS->US_LOJACLI))

		cEntidade	:= "SA1" 
		cFilEnt		:= xFilial(cEntidade)
		cCodigo		:= SUS->US_CODCLI
		cLoja		:= SUS->US_LOJACLI

		//�����������������������������������������������������Ŀ
		//�Armazena codigo do suspect para remover vinculo com o�
		//�vendedor                                             �
		//�������������������������������������������������������
		AAdd(aEntDel,{"SUS",SUS->US_COD,SUS->US_LOJA})

	EndIf

//������������������������������������������������Ŀ
//�Verifica se ha cliente para o prospect utilizado�
//��������������������������������������������������
ElseIf (lRet) .AND. (cEntidade == "SA1") .AND. !Empty(cCodigo)
	SA1->(DbSetOrder(1)) 
	If SA1->(DbSeek(xFilial("SA1") + cCodigo + cLoja ))
		cEntidade	:= "SA1" 
		cFilEnt		:= xFilial(cEntidade)
	EndIf

ElseIf (lRet) .AND. (cEntidade == "SUS")  

	//�����������������������������������������������������Ŀ
	//�Armazena codigo do suspect para remover vinculo com o�
	//�vendedor                                             �
	//�������������������������������������������������������
	ACH->(DbSetOrder(4)) //ACH_FILIAL+ACH_CODPRO+ACH_LOJPRO
	
	If ACH->(DbSeek(xFilial("ACH")+SUS->US_COD+SUS->US_LOJA))
		AAdd(aEntDel,{"ACH",ACH->ACH_CODIGO,ACH->ACH_LOJA})
	EndIf 
	
EndIf

RestArea(aArea)

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft520InEnt�Autor  �Vendas CRM          � Data �  15/10/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Manutencao da amarracao entre entidade e controle de contas ���
�������������������������������������������������������������������������͹��
���Parametros�ExpN1 - Numero da operacao (3-Inclusao,4-Alteracao,etc.)    ���
���          �ExpC2 - Codigo do vendedor                                  ���
���          �ExpC3 - Alias da entidade                                   ���
���          �ExpC4 - Codigo da entidade                                  ���
���          �ExpC5 - Loja da entidade                                    ���
�������������������������������������������������������������������������͹��
���Uso       �FATA520                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Ft520InEnt(	nOper	, cVendedor	, cEntidade	, cCodigo	,;
		 			  		cLoja	)
		 			  		
Local lRet		:= .T.		 			  		
Local aArea		:= GetArea()
Local aEntDel	:= {} 
Local lNewRec	:= .F.
Local cFilEnt	:= ""
Local nX		:= 0

//��������������������������������������Ŀ
//�Recupera lista de vendedores ignorados�
//����������������������������������������
If cVendIgn == NIL
	cVendIgn	:= SuperGetMv("MV_FATVIGN",,"")
EndIf

If AllTrim(cVendedor) $ cVendIgn
	RestArea(aArea)
	Return lRet
EndIf

//�����������������Ŀ
//�Valida o vendedor�
//�������������������
DbSelectArea("SA3")
DbSetOrder(1)
lRet		:= !Empty(cVendedor) .AND. SA3->(DbSeek(xFilial("SA3")+cVendedor))

If lRet
	
	If nOper <> 5
	
		If Ft520Valid(@cEntidade,@cCodigo,@cLoja,@aEntDel) 
		
			cFilEnt	:= xFilial(cEntidade)
			
			Begin Transaction
		
			DbSelectArea("ADL")
			DbSetOrder(5) //ADL_FILIAL+ADL_FILENT+ADL_ENTIDA+ADL_CODENT+ADL_LOJENT
		
			lNewRec := ADL->(DbSeek(xFilial("ADL")+cFilEnt+cEntidade+cCodigo+cLoja))
			
			RecLock("ADL",!lNewRec)
		
			Replace ADL->ADL_FILIAL		With xFilial("ADL")
			Replace ADL->ADL_VEND  		With cVendedor
			Replace ADL->ADL_FILENT		With cFilEnt
			Replace ADL->ADL_ENTIDA		With cEntidade
			Replace ADL->ADL_CODENT		With cCodigo
			Replace ADL->ADL_LOJENT		With cLoja
			
			Replace ADL->ADL_NVLSTR	With SA3->A3_NVLSTR   

			For nX := SA3->A3_NIVEL to 1 Step -1
				Replace &("ADL_NIVE"+StrZero(nX,2))	 With Left(SA3->A3_NVLSTR,nX*NTAMCOD)
			Next 


			
			MsUnLock()
			
			End Transaction

		EndIf
	
	Else 
		
		DbSelectArea("ADL")
		DbSetOrder(5) //ADL_FILIAL+ADL_FILENT+ADL_ENTIDA+ADL_CODENT+ADL_LOJENT
	
		cFilEnt	:= xFilial(cEntidade)
	
		If ADL->(DbSeek(xFilial("ADL")+cFilEnt+cEntidade+cCodigo+cLoja))
			
			AAdd(aEntDel,{cEntidade,cCodigo,cLoja})
			
		EndIf
		
	EndIf
	
	//��������������������������������������������������������Ŀ
	//�Remove os vinculos do vendedor com suspects ou prospects�
	//�que ja viraram prospects ou clientes,nesta ordem.       �
	//����������������������������������������������������������		
	Ft520Remov(aEntDel,cVendedor,cEntidade,cCodigo,cLoja)

Else

	//����������������������������������������������������������Ŀ
	//�Se o vendedor esta em branco, o cadastro teve o codigo do �
	//�vendedor limpo. Neste caso, a amarracao deve ser desfeita.�
	//������������������������������������������������������������	
	cFilEnt	:= xFilial(cEntidade)
	DbSelectArea(cEntidade)
	DbSetOrder(1)
	lRet := DbSeek(cFilEnt+cCodigo+cLoja)
	
	If lRet
	
		DbSelectArea("ADL")
		DbSetOrder(5) //ADL_FILIAL+ADL_FILENT+ADL_ENTIDA+ADL_CODENT+ADL_LOJENT
		
		If ADL->(DbSeek(xFilial("ADL")+cFilEnt+cEntidade+cCodigo+cLoja))
			RecLock("ADL",.F.)
			DbDelete()
			MsUnLock()
		EndIf
		
	EndIf
	
EndIf

//Ft520Limpa()

RestArea(aArea)

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft520Remov�Autor  �Vendas CRM          � Data �  15/10/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Atualiza os registros da ADL cuja entidade passou para outro���
���          �estagio.                                                    ���
�������������������������������������������������������������������������͹��
���Uso       �FATA520                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Ft520Remov(aEntDel,cVendedor,cEntidade,cCodigo,cLoja)

Local aArea		:= GetArea()			// Armazena o posicionamento atual
Local aRecEnt	:= {}					// Recnos dos registros de entidades relacionados
Local nX		:= 0					// Auxiliar de loop
Local nY		:= 0					// Auxiliar de loop
Local cFilADL	:= xFilial("ADL") 		// Filial do ADL
Local cFilTmp	:= ""					// Filial da tabela utilizada

ADL->(DbSetOrder(4))	//ADL_FILIAL+ADL_VEND+ADL_FILENT+ADL_ENTIDA+ADL_CODENT+ADL_LOJENT
						
For nX := 1 to Len(aEntDel)       

	cFilTmp	:= xFilial(aEntDel[nX][1])
	
	If ADL->(DbSeek(cFilADL+cVendedor+cFilTmp+aEntDel[nX][1]+aEntDel[nX][2]+aEntDel[nX][3]))
	
		//���������������������������������Ŀ
		//�Armazena os registros da entidade�
		//�����������������������������������
		While !Eof()					  		.AND.;
			ADL->ADL_FILIAL	== cFilADL	  		.AND.;
			ADL->ADL_VEND	== cVendedor  		.AND.;
			ADL->ADL_FILENT	== cFilTmp	   		.AND.;
			ADL->ADL_ENTIDA	== aEntDel[nX][1]	.AND.; 
			ADL->ADL_CODENT	== aEntDel[nX][2]	.AND.;
			ADL->ADL_LOJENT	== aEntDel[nX][3]
			
			AAdd(aRecEnt,ADL->(Recno()))

			ADL->(DbSkip())

		End 
		
		//������������������������������������������������������������Ŀ
		//�Apaga os registros de amarracao ou atualiza os registros    �
		//�onde sao vinculadas as oportunidades, propostas e orcamentos�
		//��������������������������������������������������������������
		For nY := 1 to Len(aRecEnt)  
		
			ADL->(DbGoTo(aRecEnt[nY]))
		
			RecLock("ADL",.F.)
		
			If Empty(ADL->(ADL_CODOPO+ADL_CODORC+ADL_CODPRO))
				DbDelete()
			Else
				Replace ADL->ADL_FILENT		With cFilTmp
				Replace ADL->ADL_ENTIDA		With cEntidade
				Replace ADL->ADL_CODENT		With cCodigo
				Replace ADL->ADL_LOJENT		With cLoja
			EndIf
		
			MsUnLock()

		Next nY
		
	EndIf 
	
Next nX

RestArea(aArea)

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FT520RpSUS�Autor  �Vendas CRM          � Data �  21/01/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Reprocessa os prospects para criacao do vinculo com os      ���
���          �vendedores na tabela ADL                                    ���
�������������������������������������������������������������������������͹��
���Uso       �FATA520                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Ft520RpSUS()

Local aArea		:= GetArea()
Local aAreaSUS	:= SUS->(GetArea())
Local aAreaADL	:= ADL->(GetArea())
Local cFilSUS	:= xFilial("SUS")  
Local cAliasSus	:= ""


Local cQuery	:= ""
                                       
cAliasSUS	:= GetNextAlias()

cQuery	:= "SELECT US_FILIAL,US_COD,US_LOJA,US_VEND"
cQuery	+= " FROM " + RetSqlName("SUS")
cQuery	+= " WHERE US_VEND = '" + SA3->A3_COD + "'" 
cQuery	+= " AND US_FILIAL = '" + cFilSUS + "'"
cQuery	+= " AND D_E_L_E_T_ = ''"

cQuery	:= ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSUS,.F.,.T.)
dbGoTop()


While !(cAliasSus)->(Eof()) 				.AND.;
	(cAliasSus)->US_FILIAL	== cFilSUS 		.AND.;
	(cAliasSus)->US_VEND	== SA3->A3_COD
	
	Ft520InEnt(	3	   		   			, SA3->A3_COD		, "SUS"		, (cAliasSus)->US_COD	,;
				(cAliasSus)->US_LOJA	)
				
	(cAliasSus)->(DbSkip())

End

(cAliasSus)->(DbCloseArea())

RestArea(aAreaSUS)
RestArea(aAreaADL)
RestArea(aArea)

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FT520RpSUS�Autor  �Vendas CRM          � Data �  21/01/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Reprocessa os prospects para criacao do vinculo com os      ���
���          �vendedores na tabela ADL                                    ���
�������������������������������������������������������������������������͹��
���Uso       �FATA520                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Ft520RpSA1()

Local aArea		:= GetArea()
Local aAreaSA1	:= SA1->(GetArea())
Local aAreaADL	:= ADL->(GetArea())
Local cFilSA1	:= xFilial("SA1")  
Local cAliasSA1	:= ""
Local cQuery	:= ""
                                       
cAliasSA1	:= GetNextAlias()

cQuery	:= "SELECT A1_FILIAL,A1_COD,A1_LOJA,A1_VEND"
cQuery	+= " FROM " + RetSqlName("SA1")
cQuery	+= " WHERE A1_VEND = '" + SA3->A3_COD + "'" 
cQuery	+= " AND A1_FILIAL = '" + cFilSA1 + "'"
cQuery	+= " AND D_E_L_E_T_ = ''"

cQuery	:= ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSA1,.F.,.T.)
dbGoTop()

While !(cAliasSA1)->(Eof()) 				.AND.;
	(cAliasSA1)->A1_FILIAL	== cFilSA1 		.AND.;
	(cAliasSA1)->A1_VEND	== SA3->A3_COD
	
	Ft520InEnt(	3	   		   			, SA3->A3_COD		, "SA1"		, (cAliasSA1)->A1_COD	,;
				(cAliasSA1)->A1_LOJA	)
				
	(cAliasSA1)->(DbSkip())

End


(cAliasSA1)->(DbCloseArea())

RestArea(aAreaSA1)
RestArea(aAreaADL)
RestArea(aArea)

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
��������������������������������������������������������������������������"��
���Programa  �FT520AltRv�Autor  �Vendas CRM          � Data �  10/06/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Atualiza a revisao da oportunidade na ADL                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �FATA520                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FT520AltRv(cCodOpor,cRevAtu)
 
Local aArea := GetArea()


Local cQuery := ""
 
cQuery := "UPDATE " + RetSqlName("ADL") + " "
cQuery += "SET ADL_CODOPO = '" +cCodOpor + cRevAtu + "' "
cQuery += " WHERE ADL_CODOPO LIKE ('" + cCodOpor + "%') AND "

If TcSrvType() != "AS/400"
	cQuery += " D_E_L_E_T_ = '' "
Else
	cQuery += " @DELETED@ = '' "
EndIf
 
TcSqlExec(cQuery)
 
 
RestArea(aArea)

Return Nil