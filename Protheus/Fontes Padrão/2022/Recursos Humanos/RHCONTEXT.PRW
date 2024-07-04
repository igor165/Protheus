#INCLUDE "PROTHEUS.CH"
#INCLUDE "RHCONTEXT.CH"

/*/{Protheus.doc} RhContExt( cCNPJ )
- Bloqueio de acesso às rotinas anuais através do CNPJ. 
@Type Function
@author:	Oswaldo Leite	
@param: cCNPJ - CNPJ da empresa utilizada.
@version 1.0
@return lRetorno - Verdadeiro se CNPJ está autorizado a utilizar a rotina.
/*/
Function RhContExt( cCNPJ )


Local aCNPJ		:= {}					// Array com os CNPJs com contrato extendido
Local nPos		:= 0					// Posicao do array de CNPJs
Local lRetorno 	:= .F.					// Retorno da funcao
Local cCodCNPJ	:= Left( cCNPJ, 8 )		// Considera apenas os 8 primeiros digitos do CNPJ, que é o codigo de inscricao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Adiciona no array os CNPJs que estao em Regime Especial³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   

//TOTVS
aAdd( aCNPJ, { "53113791" } )

//AVIBRAS - 12.1.14
aAdd( aCNPJ, { "60181468" } )
aAdd( aCNPJ, { "59814046" } )
aAdd( aCNPJ, { "43268960" } )
aAdd( aCNPJ, { "50459080" } )
aAdd( aCNPJ, { "00435091" } )
aAdd( aCNPJ, { "49531536" } )
aAdd( aCNPJ, { "71855340" } )
aAdd( aCNPJ, { "47897731" } )
aAdd( aCNPJ, { "55574503" } )
aAdd( aCNPJ, { "56755184" } )
aAdd( aCNPJ, { "53350526" } )


//EMATER-EMP.ASSIST.TECNICA EST. MG
aAdd( aCNPJ, { "19198118" } )

//SEST SERVICO SOCIAL DO TRANSPORTE/Serviço Nacional de Aprendizagem do Transporte (SEST / SENAT)
aAdd( aCNPJ, { "73471963" } )
aAdd( aCNPJ, { "73471989" } )

//EMPRESA DE TECNOLOGIA E INFORMACOES DA PREVIDENCIA SOCIAL DATAPREV
aAdd( aCNPJ, { "42422253" } )

//EMPRESA DE TECNOLOGIA DA INFORMACAO E COMUNICACAO DO MUNICIPIO DE SAO PAULO - PRODAM-SP AS
aAdd( aCNPJ, { "43076702" } )

//FEDERACAO DAS INDUSTRIAS DO ESTADO DE SAO PAULO - TEZBIV
aAdd( aCNPJ, { "62225933" } )
aAdd( aCNPJ, { "61029427" } )

//BRASPE
aAdd( aCNPJ, { "01019747" } )
aAdd( aCNPJ, { "16850970" } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica no array de CNPJs se o CNPJ passado como     ³
//³parametro tem contrato extendido.                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPos := aScan( aCNPJ, { |x| x[1] == cCodCNPJ } )

If nPos > 0
   lRetorno := .T.				//O CNPJ pode gerar arquivo magnetico
Else
	lRetorno := .F.				//O CNPJ nao pode gerar arquivo magnetico	
Endif 

Return( lRetorno )

/*/{Protheus.doc} RhGUPYExt( cCNPJ )
- Bloqueio de acesso às rotinas do Projeto GUPY. 
@Type Function
@author:	Wesley Alves Pereira	
@param: cCNPJ - CNPJ da empresa utilizada.
@version 1.0
@return lRetorno - Verdadeiro se CNPJ está autorizado a utilizar a rotina.
/*/
Function RhGUPYExt( cCNPJ )

Local aCNPJ		:= {}					// Array com os CNPJs com contrato extendido
Local nPos		:= 0					// Posicao do array de CNPJs
Local lRetorno := .F.					// Retorno da funcao
Local cCodCNPJ	:= " "

Default cCNPJ = Space(14)

cCodCNPJ	:= Left( cCNPJ, 8 )		// Considera apenas os 8 primeiros digitos do CNPJ, que é o codigo de inscricao

//TOTVS
aAdd( aCNPJ, { "53113791" } )

//TELEMONT ENGENHARIA DE TELECOMUNICACOES SA
aAdd( aCNPJ, { "18725804" } )

//EXPRESSO NEPOMUCENO SA	
aAdd( aCNPJ, { "19368927" } )

//SPDM ASSOCIACAO PAULISTA PARA O DESENVOLVIMENTO DA MEDICINA	
aAdd( aCNPJ, { "61699567" } )

//FUNDACAO INSTITUTO DE PESQUISA E ESTUDO DE DIAGNOSTICO POR IMAGEM FIDI	
aAdd( aCNPJ, { "55401178" } )

//JBS SA	
aAdd( aCNPJ, { "29162650" } )

//TECNOLOGIA BANCARIA S A	
aAdd( aCNPJ, { "51427102" } )

//ASSOCIACAO ANTONIO VIEIRA	
aAdd( aCNPJ, { "92959006" } )

//UNIMED DE BELEM COOPERATIVA DE TRABALHO MEDICO	
aAdd( aCNPJ, { "42013720" } )

//CENTRO CLINICO GAUCHO LTDA
aAdd( aCNPJ, { "77363900" } )	

//CVI REFRIGERANTES LTDA	
aAdd( aCNPJ, { "72114994" } )

//FUNDACAO DE APOIO AO HOSPITAL DAS CLINICAS DA UNIVERSIDADE FEDERAL DE GOIAS	
aAdd( aCNPJ, { "29183470" } )

//EASYNVEST TITULO CORRETORA DE VALORES SA	
aAdd( aCNPJ, { "62169875" } )

//PHARLAB INDUSTRIA FARMACEUTICA SA	
aAdd( aCNPJ, { "25012970" } )

//ASSOCIACAO DAS RELIGIOSAS DA INSTRUCAO CRISTA	
aAdd( aCNPJ, { "10847762" } )

//ASTRA SA INDUSTRIA E COMERCIO	
aAdd( aCNPJ, { "50949528" } )

//IPOG INSTITUTO DE POS GRADUACAO E GRADUACAO LTDA EPP	
aAdd( aCNPJ, { "46889770" } )

//FOCO TREINAMENTO E DESENVOLVIMENTO LTDA	
aAdd( aCNPJ, { "10359738" } )

//L DIAS DOS SANTOS E CIA LTDA	
aAdd( aCNPJ, { "85091380" } )

//SIDI	
aAdd( aCNPJ, { "61765860" } )

//FLORA PRODUTOS DE HIGIENE E LIMPEZA SA	
aAdd( aCNPJ, { "85057360" } )

//DISTRIBUIDORA AMARAL LTDA	
aAdd( aCNPJ, { "21759758" } )

//CONCESSIONARIA AUTO RAPOSO TAVARES S.A.	
aAdd( aCNPJ, { "10531501" } )

//ENTREVIAS CONCESSIONARIA DE RODOVIAS SA	
aAdd( aCNPJ, { "26664057" } )

//EIXO SP CONCESSIONARIA DE RODOVIAS SA	
aAdd( aCNPJ, { "36146575" } )

//ESCRITORIO CENTRAL DE ARRECADACAO E DISTRIBUICAO ECAD	
aAdd( aCNPJ, { "47497300" } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica no array de CNPJs se o CNPJ passado como     ³
//³parametro tem contrato extendido.                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPos := aScan( aCNPJ, { |x| x[1] == cCodCNPJ } )

If nPos > 0
   lRetorno := .T.				//O CNPJ está autorizado a utilizar as rotinas GUPY
Else
	lRetorno := .F.				//O CNPJ NÃO está autorizado a utilizar as rotinas GUPY
   Help( " ", 1, OemToAnsi(STR0002),, OemToAnsi(STR0001), 1, 0 )//"ATENCAO // Essa rotina é especifica para clientes que adquiriram a integração com a GUPY
Endif 

Return( lRetorno )