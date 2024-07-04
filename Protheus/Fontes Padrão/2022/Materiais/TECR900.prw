#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TECR900.CH"



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TECR900  �Autor  �TOTVS		         � Data �  05/04/14   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina principal para gera��o dos arquivos GESP Xml	      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                	                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function TECR900()

Local aArea 		:= GetArea()
Local cDirArq 		:= SuperGetMV("MV_TECXML",,"c:\XML Gesp")
Local cDirDia		:= "" 
Local cArqPessoa	:= "Pessoas.xml"
Local cArqPS		:= "PostosDeServicos.xml"
Local cArqArmas		:= "Armas.xml"
Local lContinua		:= .T.


//Verifica se o nome do arquivo foi preenchido
If !Empty(cDirArq)

	//Verifica se o diret�rio informado no par�metro MV_TECXML  existe.
	If VldDirPar(cDirArq)
		
		//Variavel recebe o diret�rio com a data 
		cDirDia := cDirArq+"\"+GetDDirDia()   
		
		//Verifica se existe o diret�rio com data existe. Sen�o existir ser� criado.
		If CriaDirDia(cDirDia)

			//Verifica se o arquivo existe o arquivo pessoa.xml. Se existir ser� excluido para a cria��o do novo
			If File(cDirDia+"\"+cArqPessoa)
				lContinua := ExclArq(cDirDia+"\"+cArqPessoa)
			EndIf


			//Verifica se o arquivo existe o arquivo pessoa.xml. Se existir ser� excluido para a cria��o do novo
			If File(cDirDia+"\"+cArqPS)
				lContinua := ExclArq(cDirDia+"\"+cArqPS)
			EndIf

			//Verifica se o arquivo existe o arquivo pessoa.xml. Se existir ser� excluido para a cria��o do novo
			If File(cDirDia+"\"+cArqArmas)
				lContinua := ExclArq(cDirDia+"\"+cArqArmas)
			EndIf

			
			If lContinua  

				//Chama a rotina para gravar o arquivo pessoa.xml
				LjMsgRun(STR0005+cArqPessoa,STR0008,{||GXMLPessoa(cDirDia+"\"+cArqPessoa)})//"Gerando arquivo: "			
				
				//Chama a rotina para gravar o arquivo postosdeservico.xml
				LjMsgRun(STR0005+cArqPS,STR0008,{||GXMLPS(cDirDia+"\"+cArqPS)})//"Gerando arquivo: "			

				//Chama a rotina para gravar o arquivo Armas.xml
				LjMsgRun(STR0005+cArqArmas,STR0008,{||GXMLArmas(cDirDia+"\"+cArqArmas)})//"Gerando arquivo: "							
                
				Aviso(STR0006,STR0008,{STR0009},2) //Processamento##Finaliza��o do processamento##OK
			Endif
		EndIf
	EndIf
		
Else
	HELP(" ",1,"PARAMVAZIO",,STR0001,4,2)
Endif



Restarea(aArea)
Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GXMLPessoa  �Autor  �TOTVS		     � Data �  05/04/2014 ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina utilizada para gravar os dados do arquivo 			  ���
���          �pessoa.xml				           				  		  ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                              	          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GXMLPessoa(cArq)

Local aArea 	:= Getarea()
Local cTextoAux	:= ""
Local cArqTmp	:= GetNextAlias()

Default cArq := ""        

BeginSql Alias cArqTmp
	
	SELECT RA_FILIAL, RA_CIC, RA_NOME, RA_ENDEREC, RA_BAIRRO, RA_CEP, RA_ESTADO, RA_MUNICIP, RA_DDDFONE,
	RA_TELEFON, RA_PIS, RA_ADMISSA, RA_RG, RA_COMPLRG, RA_NASC, RA_NACIONA, RA_NATURAL, RA_SEXO, AA1_VINCUL, AA1_EXTVIG
	FROM %Table:SRA% SRA
	
	INNER JOIN %Table:AA1% AA1
	ON AA1.AA1_FILIAL = %xfilial:AA1%
	AND AA1.AA1_CDFUNC = SRA.RA_MAT
	AND AA1.%NotDel%
	
	WHERE SRA.RA_FILIAL = %xfilial:SRA%
	AND SRA.%NotDel%
	AND RA_SITFOLH NOT IN(%Exp:"D"%,%Exp:"T"%)
	
EndSql

//Tag para evitar problemas com caracter acentuados
cTextoAux	:= '<?xml version="1.0" encoding="iso-8859-1"?>'+CRLF
cTextoAux	+= '<pessoa-array>'+CRLF

//Chama a rotina para gravar os dados no arquivo
GravaTxt( cArq, cTextoAux)

While (cArqTmp)->(!Eof())
	cTextoAux := ""
	 
	cTextoAux += '	<pessoa>'
	cTextoAux += '		<vinculoEmpregaticio>'+Alltrim((cArqTmp)->AA1_VINCUL)+'</vinculoEmpregaticio>'+CRLF
	cTextoAux += '		<cpf>'+Alltrim(GetTxt((cArqTmp)->RA_CIC))+'</cpf>'+CRLF
	cTextoAux += '		<nome>'+Alltrim((cArqTmp)->RA_NOME)+'</nome>'+CRLF
	cTextoAux += '		<cnpj>'+Alltrim(GetTxt((cArqTmp)->RA_CIC))+'</cnpj>'+CRLF//Alterar
	cTextoAux += '		<endereco>'+Alltrim(GetTxt((cArqTmp)->RA_ENDEREC))+'</endereco>'+CRLF
	cTextoAux += '		<bairro>'+Alltrim((cArqTmp)->RA_BAIRRO)+'</bairro>'+CRLF
	cTextoAux += '		<cep>'+Alltrim(GetTxt((cArqTmp)->RA_CEP))+'</cep>'+CRLF
	cTextoAux += '		<estado>'+Alltrim((cArqTmp)->RA_ESTADO)+'</estado>'+CRLF
	cTextoAux += '		<cidade>'+Alltrim((cArqTmp)->RA_MUNICIP)+'</cidade>'+CRLF
	cTextoAux += '		<telefone>'+Alltrim((cArqTmp)->(RA_DDDFONE + RA_TELEFON))+'</telefone>'+CRLF
	cTextoAux += '		<pis>'+Alltrim(GetTxt((cArqTmp)->RA_PIS))+'</pis>'+CRLF
	cTextoAux += '		<dataAdmissao>'+GetTxt(DTOC(STOD((cArqTmp)->RA_ADMISSA)))+'</dataAdmissao>'+CRLF
    
	If Alltrim((cArqTmp)->AA1_EXTVIG) == "1"
		cTextoAux += '		<extensao>TV</extensao>'+CRLF
	Elseif Alltrim((cArqTmp)->AA1_EXTVIG) == "2"
		cTextoAux += '		<extensao>SPP</extensao>'+CRLF
	ElseIf Alltrim((cArqTmp)->AA1_EXTVIG) == "3"
		cTextoAux += '		<extensao>TV;SPP</extensao>'+CRLF
	ElseIf Alltrim((cArqTmp)->AA1_EXTVIG) == "4"
		cTextoAux += '		<extensao>SPP;TV</extensao>'+CRLF
	Else
		cTextoAux += '		<extensao></extensao>'+CRLF
	EndIf


	cTextoAux += '		<sexo>'+Alltrim((cArqTmp)->RA_SEXO)+'</sexo>'+CRLF
	cTextoAux += '		<rg>'+Alltrim(GetTxt((cArqTmp)->RA_RG))+'</rg>'+CRLF
	cTextoAux += '		<orgaoExpedidor>'+(cArqTmp)->RA_COMPLRG+'</orgaoExpedidor>'+CRLF
	cTextoAux += '		<dataNascimento>'+GetTxt(DTOC(STOD((cArqTmp)->RA_NASC)))+'</dataNascimento>'+CRLF
	cTextoAux += '		<paisNascimento>'+Alltrim((cArqTmp)->RA_NACIONA)+'</paisNascimento>'+CRLF
	cTextoAux += '		<estadoNascimento>'+Alltrim((cArqTmp)->RA_NATURAL)+'</estadoNascimento>'+CRLF
	cTextoAux += '		<cidadeNascimento>'+Alltrim(GetCdNasc((cArqTmp)->RA_NATURAL))+'</cidadeNascimento>'+CRLF
	cTextoAux += '	</pessoa>'+CRLF
    
	//Grava os dados no final do arquivo
	GravaTxt( cArq, cTextoAux)

	(cArqTmp)->(DbSkip())
EndDo                    
cTextoAux	:= '</pessoa-array>'
GravaTxt( cArq, cTextoAux)

(cArqTmp)->(DbCloseArea())

Restarea(aArea)
Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GXMLPS  �Autor  �TOTVS		     � Data �  05/04/2014 ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina utilizada para gravar os dados do arquivo'			  ���
���          �postosdeservicos.xml		           				  		  ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                              	          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GXMLPS(cArq)

Local aArea 	:= Getarea()
Local cTextoAux	:= ""
Local cArqTmp	:= GetNextAlias()
Local aArmPost	:= {}
Local aVigPost 	:= {}
Local nX		:= 0

Default cArq := ""        

BeginSql Alias cArqTmp
	
	SELECT A1_CGC, ABS_CODIGO, ABS_LOJA, ABS_LOCAL, ABS_DESCRI, ABS_END, ABS_BAIRRO, ABS_CEP, ABS_ESTADO, ABS_MUNIC, ABS_CONTAT, U5_FCOM2
	FROM %Table:ABS% ABSP
	
	INNER JOIN %Table:SA1% SA1
	ON SA1.A1_FILIAL = %xfilial:SA1%
	AND SA1.A1_COD = ABSP.ABS_CODIGO
	AND SA1.A1_LOJA = ABSP.ABS_LOJA
	AND SA1.%NotDel%
	
	INNER JOIN %Table:SU5% U5
	ON U5.U5_FILIAL = %xfilial:SU5%
	AND U5.U5_CODCONT = ABSP.ABS_CONTAT
	AND U5.%NotDel%
/*	
	INNER JOIN %Table:AAH% AAH
	ON AAH.AAH_FILIAL = %xfilial:AAH%
	AND AAH.AAH_CODCLI = ABSP.ABS_CODIGO
	AND AAH.AAH_LOJA = 	ABSP.ABS_LOJA
	AND AAH.AAH_STATUS = %Exp:"1"%
	AND AAH.%NotDel%
	*/
	WHERE ABSP.ABS_FILIAL = %xfilial:ABS%
	AND ABSP.%NotDel%
EndSql


//Tag para evitar problemas com caracter acentuados
cTextoAux	:= '<?xml version="1.0" encoding="iso-8859-1"?>'+CRLF
cTextoAux	+= '<postoservico-array>'+CRLF
 
//Chama a rotina para gravar os dados no arquivo
GravaTxt( cArq, cTextoAux)

While (cArqTmp)->(!Eof())
	cTextoAux := ""
	cTextoAux	+= '	<postoservico>'
	cTextoAux	+= '		<cnpjContratante>'+Alltrim(GetTxt((cArqTmp)->A1_CGC))+'</cnpjContratante> '+CRLF	 
	cTextoAux	+= '		<identificador>'+Alltrim((cArqTmp)->ABS_DESCRI)+'</identificador> '+CRLF	 
	cTextoAux	+= '		<cnpjPosto>'+Alltrim(GetTxt((cArqTmp)->A1_CGC))+'</cnpjPosto> '+CRLF	 
	cTextoAux	+= '		<qtdPostosArmados>'+Alltrim(GetQtdPArm((cArqTmp)->ABS_LOCAL))+'</qtdPostosArmados> '+CRLF	 
	cTextoAux	+= '		<qtdPostos>'+GetQtPCli((cArqTmp)->ABS_CODIGO, (cArqTmp)->ABS_LOJA)+'</qtdPostos> '+CRLF	 	
	cTextoAux	+= '		<endereco>'+Alltrim((cArqTmp)->ABS_END)+'</endereco> '+CRLF	 		
	cTextoAux	+= '		<bairro>'+Alltrim((cArqTmp)->ABS_BAIRRO)+'</bairro> '+CRLF
	cTextoAux	+= '		<cep>'+Alltrim(GetTxt((cArqTmp)->ABS_CEP))+'</cep> '+CRLF
	cTextoAux	+= '		<estado>'+Alltrim((cArqTmp)->ABS_ESTADO)+'</estado> '+CRLF	
	cTextoAux	+= '		<cidade>'+Alltrim((cArqTmp)->ABS_MUNIC)+'</cidade> '+CRLF	
	cTextoAux	+= '		<telefone>'+Alltrim((cArqTmp)->U5_FCOM2)+'</telefone> '+CRLF				
	//cTextoAux	+= '		<telefone>'+Alltrim(IIF(!EMPTY(M->ABS_CONTAT),ALLTRIM( POSICIONE("SU5",1,XFILIAL("SU5")+M->ABS_CONTAT,"U5_FCOM2") ) ,""))+'</telefone> '+CRLF			

	aArmPost	:= {}	
	aArmPost	:= GetArmas((cArqTmp)->ABS_LOCAL)//Rotina utilizada para retornar o registro (SINARM) das armas por posto de servi�o
	If Len(aArmPost) > 0
		cTextoAux	+= '		<armas>'+CRLF

		For nX := 1 To Len(aArmPost)
			cTextoAux	+= '			<arma>'+CRLF	
			cTextoAux	+= '				<cadastroSinarm>'+Alltrim(aArmPost[nX])+'</cadastroSinarm>'+CRLF	
			cTextoAux	+= '			</arma>'+CRLF	
		Next

		cTextoAux	+= '		</armas>'+CRLF	
 	EndIf   
 
	aVigPost := {}
	aVigPost := GetVigPost((cArqTmp)->ABS_LOCAL)//Rotina utilizada para retornar o CPF dos vigilantes por posto
	
	If Len(aVigPost) > 0
		cTextoAux	+= '		<vigilantes>'+CRLF

		For nX := 1 To Len(aVigPost)
			cTextoAux	+= '			<vigilante>'+CRLF	
			cTextoAux	+= '				<cpfVigilante>'+Alltrim(aVigPost[nX])+'</cpfVigilante>'+CRLF	
			cTextoAux	+= '			</vigilante>'+CRLF		
		Next

		cTextoAux	+= '		</vigilantes>'+CRLF	
	EndIf

	cTextoAux	+= '	</postoservico>'+CRLF	 	
	GravaTxt( cArq, cTextoAux)

	(cArqTmp)->(DbSkip())
EndDo      
              
cTextoAux	:= '</postoservico-array>'
GravaTxt( cArq, cTextoAux)

(cArqTmp)->(DbCloseArea())

Restarea(aArea)
Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GXMLArmas  �Autor  �TOTVS			     � Data �  05/04/2014 ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina utilizada para gravar o arquivo Armas.xml			  ���
���          �							           				  		  ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                              	          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GXMLArmas(cArq)

Local aArea 	:= Getarea()
Local cTextoAux	:= ""
Local cArqTmp	:= GetNextAlias()

Default cArq := ""        

BeginSql Alias cArqTmp

	SELECT TE0_SINARM, TE0_NUMREG FROM %Table:TE0% TE0
	WHERE TE0_FILIAL = %xfilial:TE0%
	AND TE0.%NotDel%
	
EndSql



//Tag para evitar problemas com caracter acentuados
cTextoAux	:= '<?xml version="1.0" encoding="iso-8859-1"?>'+CRLF
cTextoAux	+= '<arma-array>'+CRLF
 
//Chama a rotina para gravar os dados no arquivo
GravaTxt( cArq, cTextoAux)

While (cArqTmp)->(!Eof())
	cTextoAux := ""
	cTextoAux	+= '	<arma>'+CRLF	 
	cTextoAux	+= '		<cadastroSinarm>'+Alltrim((cArqTmp)->TE0_SINARM)+'</cadastroSinarm>'+CRLF	 
	cTextoAux	+= '		<numeroArma>'+Alltrim((cArqTmp)->TE0_NUMREG)+'</numeroArma>'+CRLF	 
	cTextoAux	+= '	</arma>'+CRLF	 	
	GravaTxt( cArq, cTextoAux)

	(cArqTmp)->(DbSkip())
EndDo      
              
cTextoAux	:= '</arma-array>'
GravaTxt( cArq, cTextoAux)

(cArqTmp)->(DbCloseArea())

Restarea(aArea)
Return



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetQtdPArm  �Autor  �TOTVS		     � Data �  05/04/2014 ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna a quantidade de postos armados					  ���
���          �							           				  		  ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                              	          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GetQtdPArm(cCodPosto)

Local aArea 	:= Getarea()
Local cArqTmp	:= GetNextAlias()
Local cRet		:= "0"      

Default cCodPosto := ""

BeginSql Alias cArqTmp
	
	SELECT	COUNT(*) QTDPOSTARM FROM %Table:TFG% TFG
	
	INNER JOIN %Table:SB5% SB5
	ON SB5.B5_FILIAL = %xfilial:SB5%
	AND SB5.%NotDel%
	AND SB5.B5_COD = TFG.TFG_PRODUT
	AND SB5.B5_TPISERV = %Exp:"1"%
	
	WHERE TFG.TFG_FILIAL = %xfilial:TFG%
	AND TFG.%NotDel%
	AND TFG.TFG_LOCAL = %Exp:cCodPosto%
	
EndSql



If (cArqTmp)->(!Eof())
	cRet :=	Alltrim(Str((cArqTmp)->QTDPOSTARM))
EndIf


(cArqTmp)->(DbCloseArea())

Restarea(aArea)
Return cRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetQtPCli	  �Autor  �TOTVS		     � Data �  05/04/2014 ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna a quantidade de postos por cliente				  ���
���          �							           				  		  ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                              	          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GetQtPCli(cCliente, cLoja)

Local aArea 	:= Getarea()
Local cArqTmp	:= GetNextAlias()
Local cRet		:= "0"      

Default cCliente	:= "" 
Default cLoja		:= ""

BeginSql Alias cArqTmp
	
	SELECT COUNT(*) QTDPOSTCLI  FROM %Table:ABS% ABS

	INNER JOIN %Table:AAH% AAH
	ON AAH.AAH_FILIAL = %xfilial:AAH%
	AND AAH.AAH_CODCLI = ABS.ABS_CODIGO
	AND AAH.AAH_LOJA = 	ABS.ABS_LOJA
	AND AAH.AAH_STATUS = %Exp:"1"%      
	AND AAH.%NotDel%
	
	INNER JOIN %Table:ABB% ABB
	ON  ABB.ABB_FILIAL = %xfilial:ABB%
	AND ABB.ABB_LOCAL = ABS.ABS_LOCAL
	AND ABB.%NotDel%

	WHERE ABS.ABS_FILIAL = %xfilial:ABS%
	AND ABS.%NotDel%
	AND ABS.ABS_CODIGO = %Exp:cCliente%
		
EndSql


If (cArqTmp)->(!Eof())
	cRet :=	Alltrim(Str((cArqTmp)->QTDPOSTCLI))
EndIf


(cArqTmp)->(DbCloseArea())

Restarea(aArea)
Return cRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetArmas  �Autor  �TOTVS			     � Data �  05/04/2014 ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna o c�digo SINARM das armas para cada posto			  ���
���          �							           				  		  ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                              	          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GetArmas(cPostServ)
Local aArea 	:= Getarea()
Local cArqTmp	:= GetNextAlias()
Local aRet		:= {}

Default cPostServ	:= "" 
	
BeginSql Alias cArqTmp
	
	SELECT TFG_LOCAL, TE0_SINARM FROM %Table:TFG% TFG
	
	INNER JOIN %Table:TE0% TE0
	ON TE0.TE0_FILIAL = %xfilial:TE0%
	AND TE0.%NotDel%
	AND TE0.TE0_POSTAL = TFG.TFG_LOCAL
	
	WHERE TFG_FILIAL = %xfilial:TFG%
	AND TFG.%NotDel%
	AND TFG.TFG_LOCAL = %Exp:cPostServ%
	
EndSql


While (cArqTmp)->(!Eof())
	
	Aadd(aRet, (cArqTmp)->TE0_SINARM)
	
	(cArqTmp)->(DbSkip())
EndDo


(cArqTmp)->(DbCloseArea())

Restarea(aArea)
Return aRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetVigPost �Autor  �TOTVS			     � Data �  05/04/2014 ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna o CPF dos vigilantes por posto					  ���
���          �							           				  		  ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                              	          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GetVigPost(cPostServ)
Local aArea 	:= Getarea()
Local cArqTmp	:= GetNextAlias()
Local aRet		:= {}

Default cPostServ	:= "" 
	
BeginSql Alias cArqTmp
	
	SELECT ABB_LOCAL, AA1_CDFUNC, RA_CIC FROM %Table:ABB% ABBP

	INNER JOIN  %Table:AA1% AA1
	ON AA1.AA1_FILIAL = ABBP.ABB_FILIAL
	AND	AA1.AA1_CODTEC = ABBP.ABB_CODTEC 
	AND AA1.%NotDel%

	INNER JOIN %Table:SRA% SRA 
	ON SRA.RA_FILIAL = %xfilial:SRA%
	AND SRA.RA_MAT = AA1.AA1_CDFUNC
	AND SRA.%NotDel%

	WHERE ABBP.ABB_FILIAL = %xfilial:ABB% 
	AND ABBP.ABB_LOCAL = %Exp:cPostServ%
	AND ABBP.ABB_DTINI BETWEEN %Exp:DTOS(MsDate())%  AND %Exp:DTOS(MsDate())%
	AND ABBP.ABB_DTFIM BETWEEN %Exp:DTOS(MsDate())%  AND %Exp:DTOS(MsDate())%
	AND ABBP.ABB_ATIVO = %Exp:"1"% 
	AND ABBP.%NotDel%
	GROUP BY ABB_LOCAL, AA1_CDFUNC, RA_CIC
	
EndSql


While (cArqTmp)->(!Eof())
	
	Aadd(aRet, (cArqTmp)->RA_CIC )
	
	(cArqTmp)->(DbSkip())
EndDo


(cArqTmp)->(DbCloseArea())

Restarea(aArea)
Return aRet




/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VldDirPar  �Autor  �TOTVS			     � Data �  05/04/2014 ���
�������������������������������������������������������������������������͹��
���Desc.     �Verifica se existe diretorio informado no parametro		  ���
���          �MV_TECXML							           				  ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                              	          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function VldDirPar(cDir)
Local aArea 	:= GetArea()
Local lRet		:= .T.

Default cDir 	:= ""

If !ExistDir(cDir)
	lRet := .F.
	HELP(" ",1,"VALIDDIRETORIO",,STR0002+cDir,4,2)  //Diret�rio n�o encontrado: 
EndIf

RestArea(aArea)
Return lRet



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CriaDirDia  �Autor  �TOTVS		     � Data �  05/04/2014 ���
�������������������������������������������������������������������������͹��
���Desc.     �Cria o dirt�rio di�rio para grava��o do arquivo Pessoal.xml ���
���          �           				  								  ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                              	          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CriaDirDia(cDir) 

Local aArea 	:= GetArea()
Local lRet		:= .T.

Default cDir 	:= ""

If !ExistDir(cDir)
	If MakeDir( cDir ) < 0
		lRet := .F.
		HELP(" ",1,"CRIADIR",,STR0003,4,2)  //Erro ao tentar criar diret�rio
		
		Return lRet
	Else
		lRet := .T.
	EndIf
EndIf

RestArea(aArea)
Return lRet   



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetCdNasc	  �Autor  �TOTVS		     � Data �  05/04/2014 ���
�������������������������������������������������������������������������͹��
���Desc.     �		  ���
���          �							           				  		  ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                              	          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GetCdNasc(cEst)

Local aArea := GetArea()
Local cRet	:= ""

Default cEst := ""

Dbselectarea("SX5")
DbSetOrder(1)
If SX5->( MsSeek(xFilial("SX5")+"12"+cEst))
	cRet	:= Alltrim(SX5->X5_DESCRI)
EndIf

Restarea(aArea)
Return cRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetTxt	  �Autor  �TOTVS		     � Data �  05/04/2014 ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna o texto sem caracteres como (. e /)				  ���
���          �       				  									  ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                              	          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GetTxt(cText)

Local cRetNDir	:= ""     

Default cText := ""

cRetNDir := STRTRAN(cText, ".", "")
cRetNDir := STRTRAN(cRetNDir, "/", "")
cRetNDir := STRTRAN(cRetNDir, "\", "")
cRetNDir := STRTRAN(cRetNDir, "-", "")

Return cRetNDir



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetDDirDia  �Autor  �TOTVS		     � Data �  05/04/2014 ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna a descri��o do diret�rio de acrodo com a data		  ���
���          �Exemplo do nome do diret�rio: 05042014       				  ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                              	          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GetDDirDia()

Local cRetNDir	:= ""

cRetNDir := DTOC(MsDate())
cRetNDir := STRTRAN(cRetNDir, "/", "")

Return cRetNDir
               

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �ExclArq	� Autor � TOTVS		     � Data �  05/04/14   	  ���
�������������������������������������������������������������������������͹��
���Descricao � Exclui arquivos se o mesmo existir						  ���
���          �                      									  ���
�������������������������������������������������������������������������͹��
���Uso       �AP 		                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
/*/
Static Function ExclArq(cArq)

Local aArea		:= GetArea()
Local nRetExc   := 0
Local lRet		:= .T.

Default cArq	:= ""

If !Empty(cArq)
	
	nRetExc := FERASE(cArq)
	If nRetExc !=  0
		HELP(" ",1,"EXCARQ",,STR0004+cArq,4,2)//Erro ao excluir arquivo: 
		lRet := .F.
	EndIf
EndIf


RestArea(aArea)
Return lRet



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GravaTxt  �Autor  �TOTVS		         � Data �  05/04/14   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cria arquivo e grava arquivo XML                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                	                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
*/
Static Function GravaTxt( cArq, cTexto )

Local nHandle := 0


If !File( cArq )
	nHandle := FCreate( cArq )
	FClose( nHandle )
Endif

If File( cArq )
	nHandle := FOpen( cArq, 2 )
	FSeek( nHandle, 0, 2 )	// Posiciona no final do arquivo
	FWrite( nHandle, cTexto + Chr(13) + Chr(10), Len(cTexto)+2 )
	FClose( nHandle)
Endif
Return   
