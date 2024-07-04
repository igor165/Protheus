#include 'protheus.ch'
#include 'parmtype.ch'
#include "xmlxfun.ch"
#include "gpem551.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ±±
±±|Funcao    | GPEM551  | Autor | Matheus Bizutti.        | Data | 28/12/16 |±±
±±|ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ|±±
±±|Descricao |					                                            |±±
±±|ÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ|±±
±±|         ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.               |±±
±±|ÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ|±±
±±|Programador | Data   | BOPS   |  Motivo da Alteracao                     |±±
±±|ÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ|±±
±±|Jônatas A.  |11/01/16|MRH-4373|Ajuste para posicionar na filial do func. |±±
±±|            |        |        |no Seek da tabela SMU pois é exclusiva.   |±±
±±|Jônatas A.  |23/01/17|MRH-5183|Inclusão de query p/ gerar SMU apenas p/  |±±
±±|            |        |        |funcionarios c/ pelo menos um desconto    |±±
±±|            |        |        |de previdência privada no SRD.            |±±
±±|Jônatas A.  |23/01/17|MRH-5183|Ajuste nos parãmetros da fRetTab()        |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/

Function GPEM551()

Local aArea      := GetArea()
Local oMBrowse	       
Local bProcesso			:= { || NIL }
Local cPerg		:= "GPM551"
Local cMsg		:= ""
Local cMsg1		:= ""
Local oProc 	:= Nil
Local cCadastro	:= OemToAnsi(STR0001)  //Previdência Complementar por funcionário

// - Variáveis utilizadas no tratamento de erros.
Private bErro		:= .F.			// - Controle dos Dados da Filial
Private aLog		:= {}			// - Log para impressao
Private aTotRegs	:= Array( 4 )	// - Controle do Total de Erros Encontrados
Private aTitle		:= {}			// - Controle do Relacionamento 

Default cFilPrev	:= cFilAnt

cMsg := OemToAnsi(STR0002) + CRLF //"Este programa tem como objetivo gerar dados na tabela Previdência Complementar por Funcionário – SMU, que será utilizada na geração do arquivo da DIRF" + CRLF
cMsg += OemToAnsi(STR0003) + CRLF //"Ao solicitar o processamento, serão gravados os dados do Fornecedor de previdência para o qual os funcionários contribuíram, assim como o período de contribuição." + CRLF
cMsg += OemToAnsi(STR0004) 		  //"Durante a geração da DIRF, buscaremos as verbas que estão vinculadas na Tabela S073 e que estão presentes na tabela de acumulados do funcionário."

bProcesso	:= { |oSelf| Gpm551Proc( oSelf ) }

// - Inicializa o Array com zeros.
aFill( aTotRegs, 0 )

Pergunte( cPerg, .F. )

If cFilAnt <> cFilPrev
	cFilAnt := cFilPrev
ENDIF

tNewProcess():New( "GPEM551" , cCadastro , bProcesso , cMsg , cPerg, ,.T.,,,.T.,.T.  ) 	

RestArea( aArea )

Return(Nil)


/*/{Protheus.doc}Gpm551Proc()
- Efetua o processamento - Grava os registros na SMU.
@author:	Matheus Bizutti	
@since:		29/12/2016
@param:		oProcess - Objeto da classe TNewProcess.

/*/
Static Function Gpm551Proc( oProcess )

/*/ -----------------------------------------
// - MV_PAR01 - Filial De ?                  ||
// - MV_PAR02 - Filial Ate ?     	         ||
// - MV_PAR03 - Centro de Custo De ?	 	 ||
// - MV_PAR04 - Centro de Custo Ate ?		 ||
// - MV_PAR05 - Matricula De ?				 ||
// - MV_PAR06 - Matricula Ate ?   		 	 ||
// - MV_PAR07 - Situações Contratuais ?	     ||
// - MV_PAR08 - Categorias ?			 	 ||
// - MV_PAR09 - Mes e Ano De ?				 ||
// - MV_PAR10 - Mes e Ano Ate ?			 	 ||
// - MV_PAR11 - Cod Fonecedor				 ||
--------------------------------------------/*/

// - Variáveis utilizadas no pergunte.
Local cFilDe 	:= MV_PAR01
Local cFilAte	:= MV_PAR02
Local cCCde		:= MV_PAR03
Local cCCAte	:= MV_PAR04
Local cMatDe	:= MV_PAR05
Local cMatAte	:= MV_PAR06
Local cSituac	:= MV_PAR07
Local cCateg	:= MV_PAR08
Local cMesAnoDe := MV_PAR09
Local cMesAnoAt := MV_PAR10
Local cCodFor	:= MV_PAR11


// - Variáveis utilizadas no processamento.
Local cAliasSMU 	:= "SMU"
Local cAliasSRA		:= GetNextAlias()
Local cAliasSRD		:= GetNextAlias() 
Local cSitQuery		:= ""
Local cCatQuery		:= ""
Local cWhere		:= ""
Local cOrder		:= ""
Local cFilAnterior  := Replicate("!", FWGETTAMFILIAL)
Local cPdQry		:= ""

Local nRegProc		:= 0
Local nOrderSRA 	:= RetOrdem("SRA","RA_FILIAL+RA_MAT")
Local nOrderSMU 	:= RetOrdem("SMU","MU_FILIAL+MU_MAT+MU_CODFOR+MU_PERINI")
Local nReg			:= 0
Local nPos			:= 0
Local nI			:= 0
Local cDtPerI		:= "" //Data inicial no parâmetro
Local cDtPerF		:= "" //Data final no parâmetro

Local lExistSMU		:= .F.
Local aTabS073		:= {}

// - Abre o arquivo SMU
DbSelectArea(cAliasSMU)
(cAliasSMU)->(DbSetOrder(nOrderSMU))

// Modifica variaveis para a Query
For nReg:=1 to Len(cSituac)
	cSitQuery += "'"+Subs(cSituac,nReg,1)+"'"
	If ( nReg+1 ) <= Len(cSituac)
		cSitQuery += "," 
	EndIf
Next nReg     
cSitQuery := If( Empty( cSitQuery ), "' '", cSitQuery )
cSitQuery := "%" + cSitQuery + "%"

For nReg:=1 to Len(cCateg)
	cCatQuery += "'"+Subs(cCateg,nReg,1)+"'"
	If ( nReg+1 ) <= Len(cCateg)
		cCatQuery += "," 
	EndIf
Next nReg
cCatQuery := If( Empty( cCatQuery ), "' '", cCatQuery )
cCatQuery := "%" + cCatQuery + "%"

cOrder := "%RA_FILIAL, RA_MAT%"

/*Filtra tabela SRA de acordo à parametrização da rotina*/	
BeginSql alias cAliasSRA
	SELECT SRA.RA_FILIAL, SRA.RA_MAT
	FROM %table:SRA% SRA
	WHERE      SRA.RA_FILIAL BETWEEN %exp:cFilDe%   AND %exp:cFilAte%
		   AND SRA.RA_MAT    BETWEEN %exp:cMatDe%   AND %exp:cMatAte%
		   AND SRA.RA_CC     BETWEEN %exp:cCCDe%    AND %exp:cCCAte%
		   AND SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%)
		   AND SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%)
		   AND SRA.%notDel%
	GROUP BY %exp:cOrder%
	ORDER BY %exp:cOrder%
EndSql

// Contador de registros para régua de processamento
COUNT TO nRegProc 
oProcess:SetRegua1(nRegProc)
oProcess:SaveLog(OemToAnsi(STR0005)) //Processando registros...

dbSelectArea("SRA")
dbSetOrder(nOrderSRA)

// Processa funcionários selecionados
dbSelectArea(cAliasSRA)
(cAliasSRA)->( dbGoTop() )

cDtPerI	:= Subs( cMesAnoDe, 3, 4 ) + Subs(cMesAnoDe,1,2) + "01"
cDtPerF	:= DtoS( LastDate( CtoD( "01/" + Subs( cMesAnoAt, 1, 2 ) + "/" + Subs( cMesAnoAt, 3, 4 ), "DDMMYYYY" ) ) )

While (cAliasSRA)->(!Eof()) 
	
	//Posiciona no SRA para carregar tabela S073 com a filial do funcionário
	If SRA->( !dbSeek( (cAliasSRA)->RA_FILIAL + (cAliasSRA)->RA_MAT ) )
		(cAliasSRA)->( dbSkip() )
		Loop
	EndIf
	
	If (cAliasSRA)->RA_FILIAL # cFilAnterior
		cFilAnterior := (cAliasSRA)->RA_FILIAL
		//Carrega Tabela de Fornecedores de Prev. Compl.
		aTabS073 := {}
		fRetTab( @aTabS073, "S073", , , , , .T., , .T. )
		
		nPos	:= aScan( aTabS073, { |x| x[ 5 ] == cCodFor } )
		cPdQry	:= ""
		
		//Monta lista de verbas de previdência complementar p/ query
		If nPos > 0
			For nI := 8 To 23
				If !Empty( aTabS073[ nPos ][ nI ] )

					cPdQry += "'" + aTabS073[ nPos ][ nI ] + "'"

					If ( nI + 1 ) < 23
						cPdQry += "," 
					EndIf
				ElseIf nI == 23 .And. !Empty( cPdQry )
					cPdQry := Subs( cPdQry, 1, Len( cPdQry ) - 1 )
				EndIf
			Next nI
		EndIf
		
		// Modifica variaveis para a Query
		cPdQry := "%" + cPdQry + "%"
	EndIf
	
	// Pula funcionário caso não haja fornecedor de previdência compl. cadastrado para a filial
	// ou caso todos os campos de verbas estejam em branco no cadastro de fornecedores
	If nPos == 0 .Or. cPdQry == "%%"
		(cAliasSRA)->( dbSkip() )
		Loop
	EndIf
	
	//Não gera para funcionários sem desconto de previdência no período selecionado
	BeginSql alias cAliasSRD
		SELECT SRD.RD_FILIAL, SRD.RD_MAT, SRD.RD_PD, SRD.RD_DATPGT  
		FROM %table:SRD% SRD
		WHERE		SRD.RD_FILIAL = %exp:Upper(( cAliasSRA )->RA_FILIAL )%
				AND SRD.RD_MAT = %exp:Upper(( cAliasSRA )->RA_MAT )%
				AND SRD.RD_PD IN ( %exp:Upper( cPdQry )% )
				AND SRD.RD_DATPGT BETWEEN %exp:cDtPerI% AND %exp:cDtPerF%
				AND SRD.%notDel%
		GROUP BY  SRD.RD_FILIAL, SRD.RD_MAT, SRD.RD_PD, SRD.RD_DATPGT
		ORDER BY  SRD.RD_FILIAL, SRD.RD_MAT, SRD.RD_PD, SRD.RD_DATPGT
	EndSql
	
	// Contador de registros para régua de processamento
	COUNT TO nRegProc 
	
	(cAliasSRD)->( DbCloseArea() )
	
	If nRegProc == 0		
		(cAliasSRA)->(DbSkip())
		Loop
	Endif
	
	// - Verifica se o registro existe na SMU para gravar ou alterar.									
	If !(cAliasSMU)->( DbSeek( (cAliasSRA)->RA_FILIAL + (cAliasSRA)->RA_MAT + cCodFor + cMesAnoDe) )
		lExistSMU := .T.
	EndIf
	
	// - Grava ou Altera um registro na SMU
	RecLock("SMU", lExistSMU)
	(cAliasSMU)->MU_FILIAL := (cAliasSRA)->RA_FILIAL
	(cAliasSMU)->MU_MAT    := (cAliasSRA)->RA_MAT
	(cAliasSMU)->MU_CODFOR := cCodFor
	(cAliasSMU)->MU_PERINI := Alltrim(cMesAnoDe)
	(cAliasSMU)->MU_PERFIM := Alltrim(cMesAnoAt)
	(cAliasSMU)->(MsUnlock())
	
	// - Devolve o valor padrão
	lExistSMU := .F.
	
	oProcess:IncRegua1((OemToAnsi(STR0006) + space(1) + (cAliasSRA)->RA_MAT)) //'Matricula: ' + ########
	
	(cAliasSRA)->(DbSkip())
EndDo

// - Fecha os arquivos SMU e SRA
(cAliasSRA)->( DbCloseArea() )	
(cAliasSMU)->( DbCloseArea() )
	
If !oProcess:lEnd
	Aviso(OemToAnsi(STR0007),OemToAnsi(STR0008) , {OemToAnsi(STR0010)}) //'Previdência Complementar', 'Fim do Processamento.' , {'Ok'})		
	oProcess:SaveLog(OemToAnsi(STR0008)) //'Fim do Processamento.'			
Else
	Aviso(OemToAnsi(STR0007),OemToAnsi(STR0009), {OemToAnsi(STR0010)}) //'Previdência Complementar', 'Processamento cancelado.', {'Ok'})			
	oProcess:SaveLog(OemToAnsi(STR0008)) //'Fim do Processamento.'
EndIf	

Return(Nil)
