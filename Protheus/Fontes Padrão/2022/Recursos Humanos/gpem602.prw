#include "totvs.ch"
#INCLUDE "GPEM602.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±|Fun‡…o    | GPEM602  | Autor | Marcia Moura            | Data | 01/11/10 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±|Descri‡„o | GERA XML - HOMOLOGNET                                        |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Programador | Data   | BOPS   |  Motivo da Alteracao                     |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Carlos E. o.|07/02/14|M12RH01 | -Inclusao da rotina na P12. Retirada das |±±
±±|            |        |        | funcoes FVerUPDHomo(), ValidPerg().      |±±
±±|            |        |        | -Ajustes nos parametros das              |±±
±±|            |        |        | chamada para funcao FTrabCalen() na      |±±
±±|            |        |        | funcao Registro7().                      |±±
±±|Cecilia Car.|23/05/14|M12RH01 |Correção de error.log na geracao do Xml.  |±±
±±|            |        |        |Efetuada a replica dos chamados da versao |±±
±±|            |        |        |11 (TIGVIB e TIKPSV).                     |±±
±±|Wag Mobile  |06/11/14|TQVZGE  |Ajuste p/ gerar corretamente os valores de|±±
±±|            |        |        |base de Adicionais e Peric./Insalub.      |±±
±±|Allyson M   |21/08/15|TSZ123  |Ajuste p/ nao gerar a tag VLIndenizacao   |±±
±±|            |        |        |caso o valor seja 0.                      |±±
±±|Mariana M.  |06/11/15|TTPZT5  |Ajuste p/ buscar unidades mapeadas da ma- |±±
±±|            |        |        |quina para gerar o arquivo XML            |±±
±±|M. Silveira |27/01/16|TUHCMG  |Ajuste para gerar o salario nao somente no|±±
±±|            |        |        |mes da demissao para horista/diarista.    |±±
±±|Esther V.   |13/06/16|TVFY37  |Incluida validacao de acesso do usuario.  |±±
±±|Allyson M   |12/07/16|TVOIHR  |Ajuste p/ gerar a descrição da rescisao   |±±
±±|            |        |        |corretamente.                      		|±±
±±|Gabriel A.  |22/07/16|TVQIUI  |Retirada instrução incorreta.             |±±
±±|Eduardo K.  |31/10/16|TWI569  |Ajuste p/ carregar o nome comp. à partir  |±±
±±|            |        |        |do campo RA_NOMECMP.                 		|±±
±±³Renan Borges³29/12/16³MRH-1175³Ajuste na geração do xml do homolognet o  |±±
±±³            |        |        |sistema permita gerar o arquivo em disco  |±±
±±³            |        |        |removivel.                                |±±
±±³Eduardo K.  |07/12/16³187990  ³Ajuste na tag <rubricas> para que a mesma |±±
±±³            |        |        |somente seja gerada caso tenha conteudo.  |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GPEM602()
Local nOpca
Local aSays		:=	{}
Local aButtons	:= 	{} //<== arrays locais de preferencia
Local aHelp		:= 	{}
Local aInfo 	:= 	{}                                                                    
Local bProcesso	:= { |oSelf| GPM602Processa( oSelf ) }
Local cPerg		:= "GPM602"

Private cCadastro	:= OemToAnsi(STR0001) //"Geração do arquivo Homolognet
Private nSavRec		:= RECNO()
Private aArray		:= {}  
Private aCodFol		:= {}                                                
Private lRaNumEnd	:= SRA->( Type( "RA_NUMENDE" ) ) != "U"
Private cFilProc	:= "!!"
Private cVbNoValid	:= ""

// Variaveis para tratamento de erros
Private bErro		:= .F.			// Controle dos Dados da Filial
Private lErroRubr	:= .F.			// Controle do Relacionamento entre as Verbas e as Rubricas HomologNet
Private lErroEnde	:= .F.			// Controle da Separacao do Endereco e Numero do Funcionario
Private aLog		:= {}			// Log para impressao
Private aTitle		:= {}			// Controle do Relacionamento entre as Verbas e as Rubricas HomologNet
Private aTotRegs	:= Array( 4 )	// Controle do Total de Erros Encontrados

// Atribui Zeros
aFill( aTotRegs, 0 )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Carrega as Perguntas                                                |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Pergunte( cPerg, .F. )

tNewProcess():New( "GPEM602" , cCadastro , bProcesso , STR0002 , "GPM602",,,,,.T.,.T.  ) 	

If bErro .or. lErroRubr .or. lErroEnde
    Aviso( STR0016, STR0018 + STR0019, { "Ok" } )
	fMakeLog( aLog, aTitle,,, "XML_HomologNet_" + cEmpAnt +"_"+ dtos( dDataBase ), STR0004, "M", "P",, .F. ) // "Log de Ocorrências - XML"
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao|Gpm602ProcessaºAutor  |Microsiga           º Data |  01/20/05   º±±
±±ÌÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc. |                                                                º±±
±±º      |                                                                º±±
±±ÌÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso   | AP                                                             º±±
±±ÈÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 
Static Function Gpm602Processa( oSelf )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Define Variaveis LOCAIS DO PROGRAMA                          |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nReg			:= 0
Local aArea			:= GetArea()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Define Variaveis PRIVADAS BASICAS                            |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aInfo:= {}
Private aInfSind := {}
Private cTipoTom := ""  
Private cCnpjTom := "" 
Private cDadosTom := ""   
Private nTamFil := FWSizeFilial()
Private aDados := {}
Private iExist := 0

//Private aArray :={"","",""}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Define Variaveis PRIVADAS DO PROGRAMA                        |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private nGravados 	:= 0
Private cDrive		:= " "
Private cDiret		:= ""
Private nArq		:= ""
Private iChave		:= 0
Private cChaveRGW	:= ""
Private cParam		:= ""
Private RegV		:= .F.
Private cAnoBase	:= year(date())
Private cNumEnd		:= ""
Private aAux1		:= {}
Private aAux2		:= {}
Private aAux		:= {}
Private lFlag1		:= .F. //Processou ao menos um registro
Private lFlagFech	:= .F. //Flag que verifica se o arquivo foi fechado
Private cNumID		:= ""

Private nULT_DIA	:= F_ULTDIA(dDataBase)
Private cDiasMes	:= GetMv( "MV_DIASMES" )

Private cChPrin		:= ""
Private bSRG		:= .f.
Private cSemana		:= cSem := Space(2)

Private aTab27		:= {}	// Vetor referente as Rubricas Externas conforme Tab. S027
Private aRubrExtEr	:= {}	// Vetor de armazenamento das Rubricas Externas Sem Relacionamento na Tab. S027

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Variaveis utilizadas para parametros                          |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|MV_PAR01 - Filial De ?"                            |
//|MV_PAR02 - Filial   Ate ?                          |
//|MV_PAR03 - Matricula de ?                          |
//|MV_PAR04 - Matricula ate ?                         |
//|MV_PAR05 - Data de Homologacao de                  |
//|MV_PAR06 - Data de Homologacao ate                 |
//|MV_PAR07 - Arquivo ?    							  |
//|MV_PAR08 - Centro de Custo de ?        			  |
//|MV_PAR09 - Centro de Custo ate?        			  |
//|MV_PAR10 - Por tomador       					  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFilDe		:= If(!Empty(MV_PAR01),MV_PAR01, Space(nTamFil))
cFilAte		:= If(!Empty(MV_PAR02),MV_PAR02, Replicate("Z", nTamFil))
cMatDe     	:= mv_par03 
cMatAte   	:= mv_par04
cHomolde 	:= mv_par05
cHomolAte 	:= mv_par06
cDrive   	:= mv_par07 
cCcustoDe   := mv_par08
cCcustoAte  := mv_par09
cTomador    := mv_par10

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Posiciona Ponteiro "DE" Informado                            |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// LEITURA DOS REGISTROS

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Desenha cursor para movimentacao                          |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

ProcRegua(RGW->(RecCount()))

iChave := 1 
cChaveRGW	:= cFilDe + cMatDe + "1" + dtos( cHomolde )
if cTomador == 1 .or. val(cCcustoDe) <> 0  //; por tomador
	iChave := 3 
	cChaveRGW	:= cFilDe + cCcustoDe+cMatDe+"1"+ dtos(cHomolde) 
endif

// Carrega Vetor referente as Rubricas Externas conforme Tab. S027
fRetTab( @aTab27, "S027",,,,, .T. )

dbSelectArea( "RGW" )
dbSetOrder( iChave )
dbGotop()

dbSeek( cChaveRGW , .T. )

if iChave == 1                 
	While !(RGW->(Eof())) .And. RGW->RGW_FILIAL+RGW->RGW_MAT <= cFilAte+cMatAte
			oSelf:IncRegua1( STR0001 )
			if RGW->RGW_FILIAL $ fValidFil() .And. RGW->RGW_HOMOL>=cHomolDe .And. RGW->RGW_HOMOL<=cHomolAte
			   iExist:= aScan(aDados,{|x|(x[2]) == RGW->RGW_FILIAL+RGW->RGW_MAT+RGW->RGW_TPRESC+DTOS(RGW->RGW_HOMOL)}) 
			   if iExist ==0 
				   aadd(aDados,{RGW->RGW_JTCUMP+RGW->RGW_COMPSA+RGW->RGW_FM13+RGW->RGW_FMFER+RGW->RGW_FMAV+STR(RGW->RGW_DAVISO,2)+RGW->RGW_FILIAL,RGW->RGW_FILIAL+RGW->RGW_MAT+RGW->RGW_TPRESC+dtos(RGW->RGW_HOMOL)})
			   endif
			endif
		
		RGW->(DBSKIP())
	Enddo
else
	While !(RGW->(Eof())) .And. RGW->RGW_FILIAL+RGW->RGW_CCUSTO+RGW->RGW_MAT <= cFilAte+cCcustoAte+cMatAte
		oSelf:IncRegua1( STR0001 )
		if RGW->RGW_FILIAL $ fValidFil() .And. RGW->RGW_HOMOL>=cHomolDe .And. RGW->RGW_HOMOL<=cHomolAte
		    iExist:= aScan(aDados,{|x|(x[2]) == RGW->RGW_FILIAL+RGW->RGW_MAT+RGW->RGW_TPRESC+dtos(RGW->RGW_HOMOL)})
	    	if iExist ==0 
	    		if fTomador(RGW->RGW_FILIAL,RGW->RGW_CCUSTO)
		        	 aadd(aDados,{RGW->RGW_JTCUMP+RGW->RGW_COMPSA+RGW->RGW_FM13+RGW->RGW_FMFER+RGW->RGW_FMAV+STR(RGW->RGW_DAVISO,2)+RGW->RGW_FILIAL+strtran(RGW->RGW_CCUSTO,".",""),RGW->RGW_FILIAL+RGW->RGW_MAT+RGW->RGW_TPRESC+dtos(RGW->RGW_HOMOL),RGW->RGW_CCUSTO})
		     	else
		        	 aadd(aDados,{RGW->RGW_JTCUMP+RGW->RGW_COMPSA+RGW->RGW_FM13+RGW->RGW_FMFER+RGW->RGW_FMAV+STR(RGW->RGW_DAVISO,2)+RGW->RGW_FILIAL+strzero(0,len(RGW->RGW_CCUSTO)),RGW->RGW_FILIAL+RGW->RGW_MAT+RGW->RGW_TPRESC+dtos(RGW->RGW_HOMOL),RGW->RGW_CCUSTO})
		        endif
		    endif
		endif
		RGW->(DBSKIP())
	Enddo
Endif

ASORT(aDados,,,{ |x,y| x[1] < y[1] })
cparam := ""

For nReg := 1 to Len( aDados )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Movimenta Regua Processamento                                |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSelf:IncRegua1( STR0001 ) 
	RegV := .F.

	dbSelectArea( "RGW" )
	RGW->( dbSetOrder(1) )
	If RGW->( Dbseek( aDados[nReg,2],.F.) )    
		if RGW->RGW_FILIAL+RGW->RGW_MAT+RGW->RGW_TPRESC+DTOS(RGW->RGW_HOMOL) == aDados[nReg,2]
			RegV := .T.	
		endif                
	endif    

	If RegV // registro lido no array foi encontrado no arquivo RGW    
		if iChave == 1
			if len( cParam ) <> 0 .and. cParam <> aDados[ nReg, 1 ] 
				lFlagFech := .T. // Passou pelo fechamento do arquivo
				Registro9( oSelf )
				aArray := {}
			endif         
		else
			if len( cParam ) <> 0 .and.	( substr(cParam,1,9) == substr(aDados[nReg,1],1,9) .and. ;
										substr(cParam,10,9) <> substr(aDados[nReg,1],10,9) .and. ;
										fTomador(substr(aDados[nReg,1],8,FWGETTAMFILIAL),substr(aDados[nReg,1],10,9))) .or.;
				len( cParam ) <> 0 .and. iChave == 3 .and. substr(cParam,1,9) <> substr(aDados[nReg,1],1,9)
				lFlagFech := .T. // Passou pelo fechamento do arquivo
				Registro9( oSelf )
				aArray := {}
			endif         
		endif

		IF ( iChave == 1 .and. cParam<>aDados[nReg,1] ) .or. ;
		   ( iChave == 3 .and.	substr(cParam,1,9) == substr(aDados[nReg,1],1,9) .and. ;
		   						substr(cParam,10,9) <> substr(aDados[nReg,1],10,9) .and. ;
		   						fTomador(substr(aDados[nReg,1],8,FWGETTAMFILIAL),aDados[nReg,3])) .or.;
			iChave == 3 .and. substr(cParam,1,9) <> substr(aDados[nReg,1],1,9)

			if ! CriaArq( aDados[nReg,1], oSelf )
				Exit	// return
			endif  

			if iChave == 3                           
				cTipoTom := ""
				cCNPJTom := ""
				if fTomador(substr(aDados[nReg,1],8,FWGETTAMFILIAL),aDados[nReg,3])
					cTipoTom := substr(cDadosTom,1,1)
					cCNPJTom := substr(cDadosTom,2,14)                      
				endif         
			endif

			Registro0( oSelf )	// Gera registro 0                              
			lFlagFech := .F.	// Abriu arquivo novo
			Registro1( oSelf )	// Gera registro 1 se mudar a empresa ou tomador

			if bErro
				Exit	// return
			endif                           
		endif 
					
		bSRG := .f.
		cChPrin :=  RGW->RGW_FILIAL + RGW->RGW_MAT + RGW->RGW_TPRESC + dtos(RGW->RGW_HOMOL)
		lFlag1 := .T.

		Registro2( oSelf )				// Dados do Func
		Registro3( oSelf )				// Dados do Contrato
		PrepReg45( aDados[nReg,2] )		// Armazena dados de ferias e 13 salario
		Registro4( oSelf )				// Dados de Férias
		Registro5( oSelf )				// Dados de 13
		Registro6( oSelf )				// Movimentacao
		Registro7( oSelf )				// Financeiros
		Registro8( oSelf )				// Descontos

		aAux1	:=  {}
		aAux2	:=  {}
		aAux	:=  {}
		cParam	:= aDados[nReg,1]

		// Aborta o processamento ao terminar um XML com falha de relacionamento entre Verba e Rubrica Homolognet
		If lErroRubr
			Exit
		EndIf
	Endif
next nReg

if ! lFlagFech .and. lFlag1 // arquivo aberto e foi processado ao menos um funcionario
	Registro9( oSelf )
	aArray := {}
endif

If bErro
	oSelf:SaveLog( STR0016 + STR0017 + "(" + AllTrim(SRA->RA_FILIAL) + "-" + AllTrim(SRA->RA_MAT) + ")" )

	Aadd( aTitle, STR0016 + STR0017 + "(" + AllTrim(SRA->RA_FILIAL) + "-" + AllTrim(SRA->RA_MAT) + ")"  )
	Aadd( aLog	, {} )
	aTotRegs[1] := Len( aLog )
	Aadd( aLog[aTotRegs[1]], STR0016 + STR0017 )
EndIf

// Descarrega Vetor das Verbas sem Relacionamento com as Rubricas HomologNet
If lErroRubr
	If ! Empty( aRubrExtEr )

		Aadd( aTitle, STR0016 + STR0020 + STR0021 )
		Aadd( aLog	, {} )
		aTotRegs[ 2 ] := Len( aLog )

		// Ordena as Verbas antes de gerar o LOG
		ASort( aRubrExtEr )
		aArea := GetArea()
		SRV->( DbSelectArea( "SRV" ) )
		SRV->( DbSetOrder( 1 ) )
		For nReg := 1 to Len( aRubrExtEr )
			oSelf:SaveLog( STR0016 + STR0020 + " " + aRubrExtEr[ nReg ] + STR0021 )

			IF SRV->( DbSeek( xFilial( "SRV" ) + aRubrExtEr[ nReg ] ))
				Aadd( aLog[aTotRegs[2]], aRubrExtEr[ nReg ] + " - " + fSubst( SRV->RV_DESC ) )
			Else
				Aadd( aLog[aTotRegs[2]], aRubrExtEr[ nReg ] + " - " + STR0023 )
			endif
		Next
		RestArea( aArea )
	EndIf
	oSelf:SaveLog( STR0016 + STR0018 + STR0022 )
	Aadd( aTitle, STR0016 + STR0018 + STR0022 )
	Aadd( aLog	, {} )
	aTotRegs[ 3 ] := Len( aLog )
EndIf

oSelf:SaveLog( STR0001 + " - " + STR0012 ) //"Termino do processamento"

// Fecha arquivo XML
FClose( cDrive )

RetIndex( "SRA" )

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±|Fun‡…o    |FDHomol   | Autor | Marcia Moura          | Data | 16/11/10 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±|Descri‡…o | SELECIONAR DIRETORIO PARA GRAVAR ARQUIVO HOMOLOGNET        |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Sintaxe   | FDHomol()     		                                      |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Parametros|                                                            |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±| Uso      | GPEM602                                                    |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FDHomol()

Local mvRet:=Alltrim(ReadVar())
Local cFile                                                    

oWnd 	:= GetWndDefault()
cFile 	:= cGetFile(STR0009,OemToAnsi(STR0010),,,,nOR( GETF_MULTISELECT,GETF_LOCALFLOPPY, GETF_LOCALHARD, GETF_NETWORKDRIVE )) //"hOMOLOGNET |hOMOLOGNET"###"Selecione Diretorio"  
If Empty(cFile)
	Return(.F.)
Endif
cDrive := Alltrim(Upper(cFile))

&mvRet := cFile
If oWnd != Nil
	GetdRefresh()
EndIf

Return( .T. )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±|Fun‡…o    |Registro0     | Autor | Marcia Moura     | Data | 03/10/10 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±|Descri‡…o | Grava dados do registro 0                                 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Sintaxe   | Registro0                                                 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Uso       | GPEM602                                                   |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Registro0( oSelf )
Local n		:= 0
Local aXML	:= {}

DBSELECTarea("RGW")

// Atualizacao de versao
Aadd(aXML,"<?xml version='1.0' encoding='ISO-8859-1' ?>")
Aadd(aXML,"<Empregador xmlns='http://www.mte.gov.br/homolog-net_4_10' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>")

Aadd(aXML,"<DadosIniciais>")
    Aadd(aXML,"<TPJornadaCumpridaIntegralmente>" + RGW_JTCUMP + "</TPJornadaCumpridaIntegralmente>")
	Aadd(aXML,"<TPJornadaSemana>" + RGW_COMPSA + "</TPJornadaSemana>")

	Aadd(aXML,"<FormaCalculo>")
	  	Aadd(aXML,"<NRDuracaoAvisoPrevio>" + STRZERO(RGW->RGW_DAVISO,2) + "</NRDuracaoAvisoPrevio>")					// Campo N
    	Aadd(aXML,"<TPCalculoMediasVariaveisDecimoTerceiro>" + RGW_FM13 + "</TPCalculoMediasVariaveisDecimoTerceiro>")	// campo C

	    //campo d
		if VAL(RGW_FM13) == 2 
			Aadd(aXML,"<TPDecimoTerceiro>" + RGW_PER13 + "</TPDecimoTerceiro>")
			// campo E
			if val(RGW_PER13) == 1
				Aadd(aXML,"<NRDecimoTerceiroUltimosMesesQuantidade>" + strzero(RGW_QTDE13,2) + "</NRDecimoTerceiroUltimosMesesQuantidade>")
			Endif
		Endif

		// campo F
		if VAL(RGW_PER13) == 1 
		  	Aadd(aXML,"<NRDecimoTerceiroUltimosMesesMaiores>" + strzero(RGW_MA13,2) + "</NRDecimoTerceiroUltimosMesesMaiores>")
		endif

	  	Aadd(aXML,"<TPCalculoMediasVariaveisFerias>" + RGW_FMFER + "</TPCalculoMediasVariaveisFerias>")		// campo G

	  	//Campo H         
	  	if VAL(RGW_FMFER) == 2 
			Aadd(aXML,"<TPFerias>" + RGW_PERFER + "</TPFerias>")
		  	//Campo I                                           
	  		if val(RGW_PERFER)=1
			  	Aadd(aXML,"<NRFeriasUltimosMesesQuantidade>" + strzero(RGW_QTDFER,2) + "</NRFeriasUltimosMesesQuantidade>")
	        Endif
		Endif

	   	if val(RGW_PERFER) == 1
		  	Aadd(aXML,"<NRFeriasUltimosMesesMaiores>" + strzero(RGW_MAFER,2) + "</NRFeriasUltimosMesesMaiores>")	// Campo J
		Endif

		Aadd(aXML,"<TPCalculoMediasVariaveisAvisoPrevio>" + RGW_FMAV + "</TPCalculoMediasVariaveisAvisoPrevio>")	// Campo K

		if VAL(RGW_FMAV) == 2 
		  	//Campo L
		  	Aadd(aXML,"<NRAvisoPrevioUltimosMesesQuantidade>" + strzero(RGW_QTDEAV,2) + "</NRAvisoPrevioUltimosMesesQuantidade>")
		  	//Campo M        
		  	if RGW_MAAV == 0 // se os maiores meses for zero então tem que repetir a quantidade de meses.
		  		Aadd(aXML,"<NRAvisoPrevioUltimosMesesMaiores>" + strzero(RGW_QTDEAV,2)	+ "</NRAvisoPrevioUltimosMesesMaiores>")
		  	Else
		  		Aadd(aXML,"<NRAvisoPrevioUltimosMesesMaiores>" + strzero(RGW_MAAV,2)	+ "</NRAvisoPrevioUltimosMesesMaiores>")
			Endif	  	
		Endif                              

   	Aadd(aXML,"</FormaCalculo>")
Aadd(aXML,"</DadosIniciais>")

For n:=1 to Len(aXML)
	//	FWrite(nArq,aXML[n])
	FWrite(nArq,aXML[n]+CHR(13)+CHR(10))

	If Ferror() # 0
		cMsg := STR0008+STR(Ferror(),3) 		//-- "Erro de grava‡„o, codigo DOS:"
		oSelf:SaveLog( STR0001+ " - "+ cDrive+ ": "+cMsg) 
	Endif
Next n

aXML	:= {}

Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±|Fun‡…o    |Registro1     | Autor | Marcia Moura     | Data | 03/10/10 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±|Descri‡…o | Grava dados do registro 1 - Dados do empregador           |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Sintaxe   | Registro1                                                 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Uso       | GPEM602                                                   |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Registro1( oSelf )

Local cEndereco	:= ""
Local cNumero	:= ""                
Local n 		:= 0
Local aXML		:= {}

bErro := .f.

If !fInfo(@aInfo,RGW->RGW_FILIAL) .Or. ValType(aInfo[15]) = "C"
	oSelf:SaveLog("Dados da Filial  - " + RGW->RGW_FILIAL + " Não encontrados") //"Termino do processamento"
	bErro := .t.
EndIf           

If aInfo[15] == 1 .Or. ( Len(aInfo) >= 27 .And. !Empty( aInfo[27] ) ) // CEI
	Aadd(aXML,"<TPInscricao>2</TPInscricao>") //CEI
else
	Aadd(aXML,"<TPInscricao>1</TPInscricao>") //CNPJ
endif                                                          

Aadd(aXML,"<NRCnpjCei>"		+ If( Len(aInfo) >= 27 .And. !Empty( aInfo[27] ), aInfo[27], aInfo[8] )	+ "</NRCnpjCei>")		// Campo 2 CNPJ
Aadd(aXML,"<NORazaoSocial>"	+ fsubst(aInfo[03])	+ "</NORazaoSocial>")	//Campo3 Nome    

//Dados do sindicato patronal
If fSindi(@aInfSind,RGW->RGW_FILIAL,cAnoBase)
	if val(aInfSind[01])<>0 .and. val(aInfSind[02])<>0 
		Aadd(aXML,"<NRCnpjEspCees>"				+ alltrim(aInfSind[01]) + "</NRCnpjEspCees>")				//CNPJ Sindicato
		Aadd(aXML,"<NRCodigoSindicalEspCees>"	+ alltrim(aInfSind[02]) + "</NRCodigoSindicalEspCees>")		//Codigo Sindicato
	else
		oSelf:SaveLog( STR0001+ "- "+ cDrive+ ": "+STR0006) //"CNPJ e o Codigo da entidade do sindicato esta em branco"
	endif
else
	oSelf:SaveLog( STR0001+ " - "+ cDrive+ ": "+STR0005) //"CNPJ e o Codigo da entidade do sindicato esta em branco"
endif
                             
//Dados da Obra/Tomador
if cTomador == 1  
	Aadd(aXML,"<TPInscricaoTomadorObra>"	+ cTipoTom	+ "</TPInscricaoTomadorObra>")	//Campo6
	Aadd(aXML,"<NRCnpjCeiTomadorObra>"		+ cCNPJTom	+ "</NRCnpjCeiTomadorObra>")	//Campo7
endif

Aadd(aXML,"<Cnae>" + aInfo[16] + "</Cnae>")		//CNAE

Aadd(aXML,"<Endereco>")
	Aadd(aXML,"<NRCep>"	+ aInfo[07]	+ "</NRCep>")	//CEP

	cEndereco      := PADR(aInfo[4]  ,40)
	cNumero		   := "000000"
	If AT(" NR.", upper(aInfo[4])) > 0
		cEndereco	:= PADR(Substr(aInfo[4], 1, AT(" NR.", upper(aInfo[4]))-1), 40)
		cNumero		:= AllTrim(Substr(aInfo[4], AT(" NR.", upper(aInfo[4]))+4, 6))
		cNumero		:= Right( "000000" + cNumero, 6 )
	EndIf

	Aadd(aXML,"<EDLogradouro>"	+ fsubst(cEndereco)	+ "</EDLogradouro>")	// Endereco
	Aadd(aXML,"<NREndereco>"	+ cNumero			+ "</NREndereco>")		// Numero
	Aadd(aXML,"<DSComplemento>"	+ fsubst(aInfo[14])	+ "</DSComplemento>")	// Complemento
	Aadd(aXML,"<NOBairro>" 		+ fsubst(aInfo[13])	+ "</NOBairro>")		// Bairro
	Aadd(aXML,"<NOMunicipio>"	+ fsubst(aInfo[05])	+ "</NOMunicipio>")		// Municipio
	Aadd(aXML,"<SGUF>"			+ aInfo[06]			+ "</SGUF> ")			// Estado
Aadd(aXML,"</Endereco>")

For n:=1 to Len(aXML)
	FWrite(nArq,aXML[n]+chr(13)+chr(10))
	If Ferror() # 0
		oSelf:SaveLog( STR0001+" - "+ cDrive+ ": "+cMsg) //-- "Erro de grava‡„o, codigo DOS:"
	Endif
Next n

aXML := {}

Return Nil                       

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±|Fun‡…o	 |fleRCECNPJ  | Autor | Mauricio MR               | Data | 03/02/06 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±|Descri‡…o |Obtem o CNPJ do Sindicato		                			        |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Sintaxe	 |fBuscRCECGC(cFil)													|±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±| Uso		 | GPEM530   												        |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/  
Static Function fLeRCECNPJ( cFil, cSindica )
Local nCNPJ		:= 0
If cFilial == space(FWGETTAMFILIAL) .Or.  (cFil == space(FWGETTAMFILIAL)  .And. cFil # space(FWGETTAMFILIAL)) .or. empty(cFil)
	cFil := cFilial
Endif
cFil := xFilial( "RCE", cFil )

dbSelectArea( "RCE" )
RCE->(dbSetOrder(1))

If RCE->( Dbseek( cFil + cSindica ) )
    nCNPJ :=  val(RCE->RCE_CGC )
Endif                 

Return ( nCNPJ )    

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±|Fun‡…o	 |fBuscRCECOD | Autor | Mauricio MR               | Data | 03/02/06 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±|Descri‡…o |Obtem o COD do Sindicato		                			        |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Sintaxe	 |fBuscRCECOD(cFil)													|±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±| Uso		 | GPEM602   												        |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/  

Static Function fLeRCECOD( cFil, cSindica )
Local nCod		:= 0
If cFilial == space(FWGETTAMFILIAL) .Or.  (cFil == space(FWGETTAMFILIAL)  .And. cFil # space(FWGETTAMFILIAL)) .or. empty(cFil)
	cFil := cFilial
Endif
cFil := xFilial( "RCE", cFil )

dbSelectArea( "RCE" )
RCE->(dbSetOrder(1))

If RCE->( Dbseek( cFil + cSindica ) )
    nCOD :=  val(strtran(RCE->RCE_ENTSIN,".",""))
Endif

Return ( nCOD )    

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±|Fun‡ao    |fSindi        | Autor | Mauricio Mr       | Data | 02.02.06 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±|Descri‡…o | Carrega informacoes sobre os sindicatos Patronais		  |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±| Uso      | Generico                                                   |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fSindi( aInfSind, cFil, cAnoBase )
Local aRCTArea	:= RCT->(GetArea())
Local cChave	:= cFil+alltrim(str(cAnobase))
Local nCNPJ		:= 0
Local nCOD      := 0
Local lRet		:= .T.

Begin Sequence
	aInfSind := { "", "", 0, 0, 0, 0, 0, 0 }
	//-- Corre Todas as Contribuicoes sindicais do ano
	If ( RCT->(DbSeek(cChave)) )
	 	While RCT->( !Eof() .And. ( ( RCT_FILIAL+ RCT_ANO ) == cChave ) )  
	        nCNPJ	:= 0
			nCOD	:= 0
	        //-- Distribui as contriuicoes sindicais
			If  RCT->RCT_TPCONT == '2'  	//SINDICAL
				aInfSind[01] := strzero(fLeRCECNPJ(cFil, RCT->RCT_SIND),14) 
				aInfSind[02] := strzero(fLeRCECOD (cFil, RCT->RCT_SIND),15)
			Endif		
	        RCT->(DBSKIP())
	    END WHILE    
	Endif
End Sequence

RestArea(aRCTArea)

Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±|Fun‡…o    |Registro8     | Autor | Marcia Moura     | Data | 03/10/10 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±|Descri‡…o | Grava dados do registro 8 - Descontos                     |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Sintaxe   | Registro8                                                 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Uso       | GPEM602                                                   |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Registro8( oSelf )
Local cChave	:= cChPrin
Local cCampo	:= {}
Local cRubExt	:= ""
Local n			:= 0
Local aXML		:= {}
Local aArea		:= GetArea()

// Var para controle de impressao de desconto tipo OUTRO, caso nao seja impresso
// nenhum tem que gerar ao menos as tags de abrir <Outro> e fechar </Outro>
Local lImpDesc	:= .F.

aadd( cCampo,{ "A01", "<VLAdiantamentoSalarial>"			, "</VLAdiantamentoSalarial>"			})
aadd( cCampo,{ "A02", "<VLAdiantamento13Salario>"			, "</VLAdiantamento13Salario>"			})
aadd( cCampo,{ "A03", "<NRFaltas>"							, "</NRFaltas>"							})
aadd( cCampo,{ "A04", "<VLValeTransporte>"					, "</VLValeTransporte>"					})
aadd( cCampo,{ "A05", "<VLValeAlimentacao>"					, "</VLValeAlimentacao>"				})
aadd( cCampo,{ "A06", "<VLReembolsoVT>"						, "</VLReembolsoVT>"					})
aadd( cCampo,{ "A07", "<VLReembolsoVA>"			  			, "</VLReembolsoVA>"					})
aadd( cCampo,{ "A08", "<VLCreditoConsignado>"	  			, "</VLCreditoConsignado>"				})
aadd( cCampo,{ "A09", "<VLIndenizacao>"						, "</VLIndenizacao>"					})
aadd( cCampo,{ "A10", "<VLContribuicaoPrevidenciaPrivada>"	, "</VLContribuicaoPrevidenciaPrivada>"	})
aadd( cCampo,{ "A11", "<VLContribuicaoFapi>"				, "</VLContribuicaoFapi>"				})

// As ordens destes codigos no XML estavam invertidas. Tem que ser nesta ordem.
aadd( cCampo,{ "A13", "<VLContribuicaoSindicalLaboral>"		, "</VLContribuicaoSindicalLaboral>"	})
aadd( cCampo,{ "A12", "<VLOutrasDeducoesBaseCalculoIRRF>"	, "</VLOutrasDeducoesBaseCalculoIRRF>"	})

// Inclusao de novos descontos - SEMPRE Verificar as funcoes GPEM601RGY e GPEM601V04
aadd( cCampo,{ "A14", "<VLCompensacaoDiasSalarioFeriasMesAfastamento>"	, "</VLCompensacaoDiasSalarioFeriasMesAfastamento>"	})
aadd( cCampo,{ "A15", "<VLComplementacaoIRRFRendimentoMesQuitacao>"		, "</VLComplementacaoIRRFRendimentoMesQuitacao>"	})

dbSelectArea("RGY")
dbSetOrder(1)
dbGotop()

Aadd(aXML,"<Desconto>")   
	For n := 1 to Len( cCampo )
		If ( RGY->(DbSeek(cChave+cCampo[n,1])) )
			if n == 3
				Aadd(aXML,cCampo[n,2] + strzero(RGY->RGY_VALHORA,2) + cCampo[n,3])
			else
				 Aadd(aXML,cCampo[n,2]+AllTrim(Transform(RGY->RGY_VALHORA,"@R 99999999999.99"))+cCampo[n,3])
			endif
		Else
			if n == 3    
				 Aadd(aXML,cCampo[n,2] + "00" + cCampo[n,3])
    		ElseIf cCampo[n, 1] != "A09"
				 Aadd(aXML,cCampo[n,2] + "0.00" + cCampo[n,3])
			endif
		endif
	Next n

	Aadd(aXML,"<Outros>") 		                  
		cChave	:= cChPrin
		If ( RGY->(DbSeek(cChave)) )                                                       
			While RGY->( !Eof() .And. ( ( RGY_FILIAL + RGY_MAT + RGY_TPRESC + dtos( RGY_HOMOL ) ) == cChave ) )  
				if RGY->RGY_TPREG == "2" 
					cRubExt := fBuscCODIGO( RGY->RGY_CODIGO, "3", RGY->RGY_FILIAL )

					// Caso o codigo retorne ZEROS deve-se abortar o processamento e avisar o
					// usuario para relacionar a verba com uma rubrica das tabelas S020 ou S027
					If cRubExt == "000"
						// Carrega Verba sem relacionamento somente uma vez
						If Ascan( aRubrExtEr, RGY->RGY_CODIGO ) == 0
							Aadd( aRubrExtEr, RGY->RGY_CODIGO )
						EndIf
						lErroRubr := .T.
					EndIf

					If cRubExt # "@@@"
						Aadd(aXML,"<Outro>") 
							Aadd(aXML,"<CDOutro>"				+ cRubExt													+ "</CDOutro>")
							Aadd(aXML,"<VLDesconto>"			+ AllTrim(Transform(RGY->RGY_VALHORA,"@R 99999999999.99"))	+ "</VLDesconto>")
							Aadd(aXML,"<CDIncidenteTributacao>"	+ RGY->RGY_TRIBUT											+ "</CDIncidenteTributacao>")
						Aadd(aXML,"</Outro>") 
	
						// Indicacao de que imprimiu pelo menos um desconto do tipo OUTRO
						lImpDesc := .T.
					EndIf
				Endif
		      RGY->( DBSKIP() )
			EndDo
		Endif

		// Caso nao seja encontrado nenhum registro obrigatoriamente tem que abrir e fechar esta TAG
		If ! lImpDesc
			Aadd(aXML,"<Outro>") 
			Aadd(aXML,"</Outro>") 
		Endif

	Aadd(aXML,"</Outros>") 

Aadd(aXML,"</Desconto>")

// Encerra as TAG's do XML abertas anteriormente
Aadd(aXML,"</Contrato>")
Aadd(aXML,"</Contratos>")
Aadd(aXML,"</Empregado>")

For n:=1 to Len(aXML)
	FWrite(nArq,aXML[n]+chr(13)+chr(10))
	If Ferror() # 0
		cMsg := STR0008+STR(Ferror(),3) 		//-- "Erro de grava‡„o, codigo DOS:"
		oSelf:SaveLog( STR0001+ " - "+ cDrive+ ": "+cMsg) 
	Endif
Next n

aXML := {}

RestArea( aArea )
Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±|Fun‡…o    |Registro7     | Autor | Marcia Moura     | Data | 03/10/10 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±|Descri‡…o | Grava dados do registro 7 - Calculo da Rescisao           |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Sintaxe   | Registro7                                                 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Uso       | GPEM602                                                   |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Registro7( oSelf )
Local cChave	:= cChPrin
Local cMes		:= ""
Local lFlag		:= .f.
Local lSalDH	:= .F.
Local cRubExt	:= ""
Local nDDSR		:= 0
local ndTrab	:= 0
Local nDNDifeVT	:= 0
Local dDataRef	:= SRG->RG_DATADEM
Local dDataFim	:= SRG->RG_DATADEM
Local n			:= 0
Local aXML		:= {}
Local aXMLProv	:= {}
Local aXMLPext	:= {}
Local nDias		:= 0
Local cValor	:= ""
Local cBaseC	:= ""
Local aArea		:= GetArea()
Local cPeriodo	:= SRG->RG_PERIODO
Local cNrPagto := SRG->RG_SEMANA
Local cRoteiro := SRG->RG_ROTEIR

FTrabCalen( cPeriodo,;			//-- Periodo
			@ndTrab,;	//-- Dias Trabalhados
			,;			//-- Dias Nao Trabalhados
			@nDDSR,; 	//-- Dias de DSR
			,;			//-- Dias Nao Uteis de Vale Transporte 
			,;			//-- Dias uteis de Vale Transporte 
			,; 			//-- Dias de Diferenca de Vale Transporte
			,;			//-- Qtde de Horas de DSR
			,;			//-- Qtde de HoraS Trabalhadas 
			,;			//-- Dias de Vale Refeicao 
			,;			//-- Dias totais de V.T. Dias Uteis
			,;    		//-- Dias totais de V.T. Dias Nao uteis
			cNrPagto,;	//-- Numero de Pagamento
			.F., ;		//-- Se Verifica Afastamentos 
			.F., ;		//-- Proporcional a Admissao
			dDataFim,;	//-- Data Fim do Periodo
			cRoteiro;	//-- Roteiro
			,;			//-- Data inicial para pesquisa (opcional)
			,;			//-- Verbas de tipos de afastamentos (opcional)			
			,;			//-- Dias de Vale Alimentacao
			,;			//-- Dias uteis
			,;			//-- Dias de Diferença de VT ( dias Nao uteis) 
			)

//Encontra dias/horas mes
IF SRA->RA_TIPOPGT = "S"
	nDias := 30 
ElseIf SRA->RA_CATFUNC = "H" .and. GetMv("MV_PGCOMHR",,"2") == "1"					//-- Parametro que indica se deve pagar Saldo de Salario pela composição de horas 
	//nDias := Round( Salario / SRA->RA_HRSMES * (Normal+Descanso) , MsDecimais(1))	//--Proporcionaliza salario conforme composicao do mes
	nDias := If( cDiasMes == "S", nUlt_dia, 30 )
Else  
	nDias := 30
EndIF	

dbSelectArea("RGX")
dbSetOrder(1)
dbGotop()

Aadd(aXML,"<Financeiro>") 
	Aadd(aXML,"<Salarios>") 
		If ( RGX->(DbSeek(cChave)) )
		 	While RGX->( !Eof() .And. ( ( RGX_FILIAL + RGX_MAT + RGX_TPRESC + dtos(RGX_HOMOL) ) == cChave ) )

				//Gera Salario Fixo para Horista/Diarista com salario Fixo e Variavel para nao gerar erro no validador HomologNet
				lSalDH := SRA->RA_CATFUNC $ "H/D"

				IF cMes <> RGX->RGX_MESANO .and. len(cMes) <> 0
					For n:=1 to Len(aXML)
						FWrite(nArq,aXML[n]+chr(13)+chr(10))
						If Ferror() # 0
							cMsg := STR0008+STR(Ferror(),3) 		//-- "Erro de grava‡„o, codigo DOS:"
							oSelf:SaveLog( STR0001+" - "+ cDrive+ ": "+cMsg) 
						Endif
					Next n   

					If (Len(aXMLProv) <> 0) .Or.(aScan( aXMLProv, { |x| x == "<CDTipoRubrica>001</CDTipoRubrica>" } ) == 0 .And. RGX->RGX_MESANO != "999999")
						FWrite(nArq,"<Rubricas>"+chr(13)+chr(10))
			 				
							 // Verifica se precisa adicionar a rúbrica 001 - Usado quando o Funcionário está de férias.
			 				IF aScan( aXMLProv, { |x| x == "<CDTipoRubrica>001</CDTipoRubrica>" } ) == 0 .And. RGX->RGX_MESANO != "999999"
				 				Aadd(aXMLProv, "<Rubrica>")
								Aadd(aXMLProv, "<CDTipoRubrica>001</CDTipoRubrica>")
								Aadd(aXMLProv, "<VLRubrica>" + AllTrim( Transform( SRA->RA_SALARIO, "@R 99999999999.99" ) ) + "</VLRubrica>")
								Aadd(aXMLProv, "</Rubrica>")
			 				ENDIF
							 
							 For n:=1 to Len(aXMLProv)
								FWrite(nArq,aXMLProv[n]+chr(13)+chr(10))
								If Ferror() # 0
									cMsg := STR0008+STR(Ferror(),3) 		//-- "Erro de grava‡„o, codigo DOS:"
									oSelf:SaveLog( STR0001+" - "+ cDrive+ ": "+cMsg) 
								Endif
							Next n
						FWrite(nArq,"</Rubricas>"+chr(13)+chr(10))
					EndIf

					if len(aXMLPext) <> 0 
   						FWrite(nArq,"<RubricasExternas>"+chr(13)+chr(10))
				 			For n:=1 to Len(aXMLPext)
								FWrite(nArq,aXMLPext[n]+chr(13)+chr(10))
								If Ferror() # 0
									cMsg := STR0008+STR(Ferror(),3) 		//-- "Erro de grava‡„o, codigo DOS:"
									oSelf:SaveLog( STR0001+" - "+ cDrive+ ": "+cMsg) 
								Endif
							Next n
   						FWrite(nArq,"</RubricasExternas>"+chr(13)+chr(10))  
   					endif
					FWrite(nArq,"</Salario>"+chr(13)+chr(10)) 

					aXML		:= {}
					aXMLProv	:= {}
					aXMLPext	:= {}
					lFlag		:= .f.
				Endif

		 		If RGX->RGX_MESANO == "999999"
					Aadd (aXML,"</Salarios>")
					//ftrabcalen()
					      
           			Aadd(aXML,"<NRQuantidadeDsr>"	+ strzero(nDDSR,1)	+ "</NRQuantidadeDsr>")

					// Somente enviar Salario Liquido se Data de Afastamento for entre o Primeiro e Sexto Dia do Mes
					If Day( SRG->RG_DATADEM ) < 7
						Aadd(aXML,"<VLSalarioLiquidoMesAnteriorRescisao>"+AllTrim(Transform(RGX->RGX_SALLIQ,"@R 99999999999.99"))+"</VLSalarioLiquidoMesAnteriorRescisao>") 
					EndIf

		   			Aadd(aXML,"</Financeiro>")
            		For n:=1 to Len(aXML)
						FWrite(nArq,aXML[n]+chr(13)+chr(10))
						If Ferror() # 0
							cMsg := STR0008+STR(Ferror(),3) 		//-- "Erro de grava‡„o, codigo DOS:"
							oSelf:SaveLog( STR0001+" - "+ cDrive+ ": "+cMsg) 
						Endif
					Next n   
					return
		   		Endif

				If !lFlag // grava os dados de salario
					Aadd(aXML,"<Salario>")
						Aadd(aXML,"<DTAnoMes>"		+ RGX->RGX_MESANO	+ "</DTAnoMes>")
						Aadd(aXML,"<TPFormacao>"	+ RGX->RGX_FORSAL	+ "</TPFormacao>")
						if RGX->RGX_FORSAL == "1" .OR. RGX->RGX_FORSAL == "3"
							Aadd (aXML,"<TPSalario>" + RGX_TPSAL + "</TPSalario>")
						endif
				 		cMes := RGX->RGX_MESANO

						// Somente envia Salario do Funcionario no mesmo Mes da Demissao, pois nao eh informado pelos acumulados (SRD)
					    If RGX->RGX_MESANO == MesAno( SRG->RG_DATADEM ) .Or. lSalDH //Para Horista/Diarista gera Salario Fixo em todos os meses
				 			Aadd(aXMLProv,"<Rubrica>")
								Aadd (aXMLProv,"<CDTipoRubrica>001</CDTipoRubrica>")
								Aadd (aXMLProv,"<VLRubrica>" + AllTrim( Transform( SRA->RA_SALARIO, "@R 99999999999.99" ) ) + "</VLRubrica>")
							Aadd (aXMLProv,"</Rubrica>")
						EndIf

				 		lFlag := .t.
				Endif

				if RGX->RGX_TPREG == "1"            

					// Tratamento para enviar os valores com o PONTO DECIMAL
				    cValor := AllTrim( Transform( RGX->RGX_VALRUB , "@R 99999999999.99" ) )
				    cBaseC := AllTrim( Transform( RGX->RGX_VALBC  , "@R 99999999999.99" ) )

  					 Aadd(aXMLProv,"<Rubrica>")
					 Aadd (aXMLProv,"<CDTipoRubrica>" + RGX->RGX_CODRUB + "</CDTipoRubrica>")
					 if RGX->RGX_VALRUB <> 0
					     Aadd(aXMLProv,"<VLRubrica>" + cValor + "</VLRubrica>")
					 Endif

				    if RGX->RGX_MESANO == SUBSTR(DTOS(SRG->RG_DATADEM),1,6)
						if (VAL(RGX->RGX_CODRUB) == 002 .or. VAL(RGX->RGX_CODRUB) == 017) .or. (VAL(RGX->RGX_CODRUB) == 024 .or. VAL(RGX->RGX_CODRUB) == 026) .or. (VAL(RGX->RGX_CODRUB) == 029 .or. VAL(RGX->RGX_CODRUB) == 030)
							cValor := AllTrim( Transform( (( RGX->RGX_VALRUB / @ndTrab) * nDias ), "@R 99999999999.99" ) )
						endif
						if (VAL(RGX->RGX_CODRUB) == 013 .or. VAL(RGX->RGX_CODRUB) == 014) .or. (VAL(RGX->RGX_CODRUB) == 018 .or. VAL(RGX->RGX_CODRUB) == 019)
							cBaseC := AllTrim( Transform( (( RGX->RGX_VALBC * RGX->RGX_PERC ) / 100 ), "@R 99999999999.99" ) )
					    endif
				    endif
				
					If Val( RGX->RGX_PROD ) <> 0 .And. ( cRubExt := fBuscCODIGO( RGX->RGX_PROD, "1", RGX->RGX_FILIAL ) ) # "@@@"
 
						If Val( RGX->RGX_PROD ) <> 0
							// Caso o codigo retorne ZEROS deve-se abortar o processamento e avisar o
							// usuario para relacionar a verba com uma rubrica das tabelas S020 ou S027
							If cRubExt == "000"
								// Carrega Verba sem relacionamento somente uma vez
								If Ascan( aRubrExtEr, RGX->RGX_PROD ) == 0
									Aadd( aRubrExtEr, RGX->RGX_PROD )
								EndIf
								lErroRubr := .T.
							EndIf
							Aadd (aXMLProv,"<NRSequencialProduto>" + strzero(val(cRubExt),20) + "</NRSequencialProduto>")
						EndIf

				    EndIf

					 if RGX->RGX_VALBC <> 0 
					     Aadd (aXMLProv,"<VLBaseCalculo>" + cBaseC + "</VLBaseCalculo>")
					 endif

					 if RGX->RGX_QTDPRO <> 0
					     Aadd(aXMLProv,"<NRQuantidadeProdutos>" + AllTrim(Transform(RGX->RGX_QTDPRO,"@R 999999.99")) + "</NRQuantidadeProdutos>")
					 endif

					 if RGX->RGX_PERC <> 0
					     Aadd (aXMLProv,"<PCPercentualRubrica>" + AllTrim(Transform(NOROUND(RGX->RGX_PERC,2) , "@R 999.99")) + "</PCPercentualRubrica>")
					 Endif

					 if !(RGX->RGX_QTDHOR == 0)
					     Aadd (aXMLProv,"<NRHoras>" + AllTrim(Transform(RGX->RGX_QTDHOR,"@R 999.99")) + "</NRHoras>")						
					 Endif						  
					 Aadd (aXMLProv,"</Rubrica>")
				    
				Else         
					//if fBuscaId(RGX->RGX_CODRUB) //so vai processar se não for restrito
					cRubExt := fBuscCODIGO( RGX->RGX_CODRUB, "2", RGX->RGX_FILIAL )
					
					// Caso o codigo retorne ZEROS deve-se abortar o processamento e avisar o
					// usuario para relacionar a verba com uma rubrica das tabelas S020 ou S027
					If cRubExt == "000"
						// Carrega Verba sem relacionamento somente uma vez
						If Ascan( aRubrExtEr, RGX->RGX_CODRUB ) == 0
							Aadd( aRubrExtEr, RGX->RGX_CODRUB )
						EndIf
						lErroRubr := .T.
					EndIf
					If cRubExt # "@@@"
						Aadd (aXMLPext,"<RubricaExterna>")
						Aadd (aXMLPext,"<CDRubricaExterna>"			+ cRubExt													+ "</CDRubricaExterna>")
						Aadd (aXMLPext,"<VLVerbaRescisoria>"		+ AllTrim(Transform(RGX->RGX_VALRUB,"@R 99999999999.99"))	+ "</VLVerbaRescisoria>")
						Aadd (aXMLPext,"<CDIncidenteTributacao>"	+ RGX->RGX_TRIBUT											+ "</CDIncidenteTributacao>")
						Aadd (aXMLPext,"<CDIndicadorIntegracaoBaseCalculo>" + RGX->RGX_INTBC + "</CDIndicadorIntegracaoBaseCalculo>")
						Aadd (aXMLPext,"</RubricaExterna>")
					EndIf
				EndIf
            	RGX->(dbskip())
			Enddo
		Endif

aXML		:= {}
aXMLProv	:= {}
aXMLPext	:= {}

RestArea( aArea )
Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±|Fun‡…o    |Registro6     | Autor | Marcia Moura     | Data | 03/10/10 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±|Descri‡…o | Grava dados do registro 6 - Movimentacoes                 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Sintaxe   | Registro6                                                 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Uso       | GPEM602                                                   |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Registro6( oSelf )
Local n		:= 0
Local aXML	:= {}
Local aArea	:= GetArea()

dbSelectArea("RGZ")
dbSetOrder(1)
dbGotop()

Aadd(aXML,"<Movimentacoes>")  		                  
	cChave	:= cChPrin		
	If ( RGZ->(DbSeek(cChave)) )                                                       
		While RGZ->( !Eof() .And. ( ( RGZ_FILIAL + RGZ_MAT + RGZ_TPRESC + dtos(RGZ_HOMOL) ) == cChave ) )  
			Aadd(aXML,"<Movimentacao>") 
				Aadd(aXML,"<CDMotivo>"			+ AllTrim( RGZ->RGZ_MOTIVO )	+ "</CDMotivo>")
				Aadd(aXML,"<DTMovimentacao>"	+ DTOS( RGZ->RGZ_DTMVTO )		+ "</DTMovimentacao>")
			Aadd(aXML,"</Movimentacao>")
			RGZ->(DBSKIP())
		EndDo
	Endif
Aadd(aXML,"</Movimentacoes>")  		                  

For n:=1 to Len(aXML)
	FWrite(nArq,aXML[n]+chr(13)+chr(10))
	If Ferror() # 0
		cMsg := STR0008+STR(Ferror(),3) 		//-- "Erro de grava‡„o, codigo DOS:"
		oSelf:SaveLog( STR0001+" - "+ cDrive+ ": "+cMsg) 
	Endif
Next n

aXML := {}

RestArea( aArea )
Return Nil



/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±|Fun‡…o    |Registro5     | Autor | Marcia Moura     | Data | 03/10/10 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±|Descri‡…o | Grava registro 5 - 13 salario                             |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Sintaxe   |Registro5                                                  |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Uso       | GPEM602                                                   |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Registro5( oSelf )
Local i				:= 0
Local nX			:= 0
Local aXML			:= {}

Aadd(aXML,"<DecimosTerceiros>")

 	Aadd(aXML,"<DecimoTerceiro>")
		IF Len( aAux1 ) > 0
			Aadd( aXML, "<FaltasInjustificadas>" )
			For i := 1 to len( aAux1 )

				// Somente gera no XML os 5 anos mais recentes em acordo com o Ano do 13 Pago definido no vetor aAux do FOR abaixo
				If ! ( Len( aAux ) > 5 .and. substr( aAux1[i,1],1,4) == aAux[ 1, 1 ] )
					Aadd(aXML,"<FaltaInjustificada>")
						Aadd(aXML,"<DTAnoMes>"	+ aAux1[i,1]			+ "</DTAnoMes>")
						Aadd(aXML,"<NRFalta>"	+ strzero(aAux1[i,2],2)	+ "</NRFalta>")
					Aadd(aXML,"</FaltaInjustificada>")
				EndIf
			next i  
			Aadd(aXML,"</FaltasInjustificadas>")
		Endif
	Aadd(aXML,"</DecimoTerceiro>")

	For i = 1 to Len( aAux )
		// Somente gera no XML os 5 anos mais recentes
		If Len( aAux ) <= 5 .or. Len( aAux ) > 5 .and. i > 1
			Aadd (aXML,"<DecimoTerceiro>")
				Aadd(aXML,"<NRAno>"		+ aAux[i,1]	+ "</NRAno>")
				Aadd(aXML,"<STPago>"	+ aAux[i,2]	+ "</STPago>")
				If val(aAux[i,2]) == 3
					Aadd(aXML,"<VLValor>" + aAux[i,3] + "</VLValor>")
				endif
			Aadd (aXML,"</DecimoTerceiro>")
		EndIf
	next i  

Aadd(aXML,"</DecimosTerceiros>")

For nX:=1 to Len(aXML)
	FWrite(nArq,aXML[nX]+chr(13)+chr(10))
	If Ferror() # 0
		cMsg := STR0008+STR(Ferror(),3) 		//-- "Erro de grava‡„o, codigo DOS:"
		oSelf:SaveLog( STR0001+" - "+ cDrive+ ": "+cMsg) 
	Endif
Next nX

aXML := {}

Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±|Fun‡…o    |Registro3     | Autor | Marcia Moura     | Data | 03/10/10 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±|Descri‡…o | Grava registro 3 - Dados do Contrato de Trabalho          |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Sintaxe   |Registro3                                                  |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Uso       | GPEM602                                                   |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Registro3( oSelf )
Local cCNPJ		:= ""
Local cCod		:= ""
Local cCodRes	:= ""
Local cAviso	:= ""
Local nPer1		:= 0
Local nPer2		:= 0
Local nPos		:= 0
Local cPer1		:= 0
Local cPer2		:= 0
Local nDepIR	:=0
Local nDepSF	:=0
Local n			:= 0
Local aXML		:= {}
Local cCbo		:= fCodCBO(SRA->RA_FILIAL,SRA->RA_CODFUNC,SRA->RA_DEMISSA,.T.)                                              
Local nBnValFix	:= 0	// Valor fixo de pensao alimenticia do Beneficiario
     
	Aadd(aXML,"<Contratos>")
		Aadd(aXML,"<Contrato>")
			Aadd(aXML,"<NRCbo>"+cCbo+"</NRCbo>")    

			// Dados do Sindicato do Funcionario
			cCNPJ	:= StrZero(fLeRCECNPJ(SRA->RA_FILIAL, SRA->RA_SINDICA), 14 )
			cCOD    := Strzero(fLeRCECOD(SRA->RA_FILIAL,SRA->RA_SINDICA),15)
			if val(cCNPJ) <> 0 
				Aadd(aXML,"<NRCnpjEslCees>" + cCNPJ + "</NRCnpjEslCees>") //Campo4
			else 
				oSelf:SaveLog( STR0001+ " - "+ cDrive+ ": "+STR0006)   //cnpj/codigo sind  nao cadastrado
			endif
			if val(cCOD)<>0
				Aadd(aXML,"<NRCodigoSindicalEslCees>" + cCOD + "</NRCodigoSindicalEslCees>") //Campo5
			else
				oSelf:SaveLog( STR0001+ " - "+ cDrive+ ": "+STR0006) 
			endif
			if val(RCE->RCE_MESDIS) = 0 
				oSelf:SaveLog( STR0001+ " - "+ cDrive+ ": "+STR0014) 
			else
				if RCE->RCE_DIADIS = 0 
					Aadd(aXML,"<DTBaseCategoriaProfissional>" + RCE->RCE_MESDIS + "01</DTBaseCategoriaProfissional>")
				Else
					Aadd(aXML,"<DTBaseCategoriaProfissional>" + RCE->RCE_MESDIS+strzero(RCE->RCE_DIADIS,2) + "</DTBaseCategoriaProfissional>")
				Endif
			Endif

			Aadd(aXML,"<DTAdmissao>"		+ DTOS(SRA->RA_ADMISSA)			+ "</DTAdmissao>")
			Aadd(aXML,"<NRTrabalhoSemanal>"	+ STRZERO(SRA->RA_HRSEMAN,2)	+ "</NRTrabalhoSemanal>")

			dbSelectArea("SRG")
			dbSetOrder(1)                                                                                                
			dbGotop()    
			if dbSeek( SUBSTR(cChPrin,1,(nTamFil+6)), .T. )
				While !(SRG->(Eof())) .And. SRG->RG_FILIAL+SRG->RG_MAT <= SUBSTR(cChPrin,1,(nTamFil+6))
                	IF dtos(SRG->RG_DATAHOM) == SUBSTR(cChPrin,(nTamFil+8),8)
                		bSRG := .t.
						exit 
					endif  
					SRG->(DBSKIP())
				end do
			endif
			if bSRG			
				// Tratamento para Data do Aviso maior que a Data de Demissao.
				If SRG->RG_DTAVISO > SRG->RG_DATADEM
					Aadd(aXML,"<DTAvisoPrevio>" + DTOS(SRG->RG_DATADEM) + "</DTAvisoPrevio>")
				Else
					Aadd(aXML,"<DTAvisoPrevio>" + DTOS(SRG->RG_DTAVISO) + "</DTAvisoPrevio>")
				EndIf

			  	Aadd(aXML,"<DTAfastamento>" + DTOS(SRG->RG_DATADEM) + "</DTAfastamento>")
				nPos	:= fPosTab("S043", SRG->RG_TIPORES, "==", 04)
				cCodRes	:= fTabela("S043", nPos, 25)
			    Aadd(aXML,"<TPCausaAfastamento>" + cCodRes + "</TPCausaAfastamento>")
			else
				oSelf:SaveLog( STR0001+ " - "+ cDrive+ ": "+STR0015) 
			endif

			If SRA->RA_TPCONTR $ "1/3"
	  			Aadd(aXML,"<TPContratoTrabalho>1</TPContratoTrabalho>")
	  		Else
				if SRA->RA_CLAURES == "1"
		  			Aadd(aXML,"<TPContratoTrabalho>2</TPContratoTrabalho>")
		  		Else
		  			Aadd(aXML,"<TPContratoTrabalho>3</TPContratoTrabalho>")
				Endif
			Endif 

			if 	(cCodRes == "SJ2" .or. cCodRes == "RA2") .and. VAL(SRG->RG_COMPRAV) == 0
				oSelf:SaveLog( STR0001+ " - "+ cDrive+ ": "+STR0013) 
			Endif

			Aadd(aXML,"<TPComprovacaoEmpregoDuranteAvisoPrevio>" + SRG->RG_COMPRAV + "</TPComprovacaoEmpregoDuranteAvisoPrevio>")

			if 	(cCodRes == "SJ1" .or. cCodRes == "RA1")
				cAviso := SubStr( fDesc("SRX","32"+SRG->RG_TIPORES,"RX_TXT",,SRA->RA_FILIAL) , 04 , 1)
				if cAviso == "N"
					Aadd(aXML,"<TPEmpregadoDispensadoAvisoPrevio>1</TPEmpregadoDispensadoAvisoPrevio>") //sim
				else					
					Aadd(aXML,"<TPEmpregadoDispensadoAvisoPrevio>2</TPEmpregadoDispensadoAvisoPrevio>") //nao
				endif
			endif  

			nBnValFix := 0
			nPer1 := nPer2 := 0
			cPer1 := cPer2 := 0
			dbSelectArea( "SRQ" )
			If dbSeek( SRA->RA_FILIAL + SRA->RA_MAT )
				While SRQ->RQ_FILIAL+SRQ->RQ_MAT == SRA->RA_FILIAL + SRA->RA_MAT
					If val(SRQ->RQ_VERBFOL)<>0
						nPer1		:= nPer1 + SRQ->RQ_PERCENT
						nBnValFix	+= SRQ->RQ_VALFIXO
					Endif
					nPer2 := nPer2 + SRQ->RQ_PERFGTS
					SRQ->(DBSKIP())
				enddo
				// Caso a pensao alimenticia tenha VALOR FIXO nao gerar registro do PERCENTUAL
				if nPer1 <> 0 .and. Empty( nBnValFix )
					cPer1 := strtran(strzero(nPer1,4),".","")
				    Aadd(aXML,"<VLPensaoAlimenticiaTRCT>0000</VLPensaoAlimenticiaTRCT>")
				    Aadd(aXML,"<PCPensaoAlimenticiaTRCT>" + cPer1 + "</PCPensaoAlimenticiaTRCT>")
				else
				    Aadd(aXML,"<VLPensaoAlimenticiaTRCT>" + AllTrim(Transform(nBnValFix,"@R 99999999999.99")) + "</VLPensaoAlimenticiaTRCT>")
				    Aadd(aXML,"<PCPensaoAlimenticiaTRCT>0000</PCPensaoAlimenticiaTRCT>") 
		        endif
			endif

			// Independente de ter ou nao a PENSAO ALIMENTICIA deve ser enviado o PERCENTUAL FGTS
			// Caso nao tenha sera enviado ZEROS
			if nPer2 <> 0
				cPer2 := strtran(strzero(nPer2,4),".","")
			  	Aadd(aXML,"<PCPensaoAlimenticiaFGTS>" + cPer2 + "</PCPensaoAlimenticiaFGTS>")
			else
			  	Aadd(aXML,"<PCPensaoAlimenticiaFGTS>0000</PCPensaoAlimenticiaFGTS>")
			Endif

			if val(SRA->RA_CATEG)=0
				Aadd(aXML,"<TPCategoriaTrabalhador>01</TPCategoriaTrabalhador>")
			else
				Aadd(aXML,"<TPCategoriaTrabalhador>" + SRA->RA_CATEG + "</TPCategoriaTrabalhador>")
			endif

			dbSelectArea( "SRR" )
			If dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + "R" + DTOS(SRG->RG_DTGERAR),.t.)                    
				While SRR->( !Eof() .And.   SRR->RR_FILIAL+SRR->RR_MAT + SRR->RR_TIPO3 + DTOS(SRR->RR_DATA) == SRA->RA_FILIAL + SRA->RA_MAT + "R" + DTOS(SRG->RG_DTGERAR))   
					SRV->( DbSelectArea("SRV") )
					SRV->( DbSetOrder(1) )
					SRV->( DbGoTop() )
					IF SRV->( DbSeek( xFilial("SRV") +  SRR->RR_PD ) )	
						If SRV->RV_CODFOL == '0034'
							nDepSF := SRR->RR_HORAS
						Endif
						If SRV->RV_CODFOL == '0059'
							nDepIR := SRR->RR_HORAS
						Endif     
					endif
			        SRr->(DBSKIP())
				enddo		

				If nDepIR <> 0 
					Aadd(aXML,"<NRDependentesIR>" + strzero(nDepIR,2) + "</NRDependentesIR>")
				else
					Aadd(aXML,"<NRDependentesIR>000</NRDependentesIR>")
				endif
				
				If nDepSF <> 0 
				  	Aadd(aXML,"<NRDependentesSalarioFamilia>" + strzero(nDepSF,2) + "</NRDependentesSalarioFamilia>")
				else                              
				  	Aadd(aXML,"<NRDependentesSalarioFamilia>0000</NRDependentesSalarioFamilia>")
				endif                              
			Endif

		  	if !EMPTY(DTOS(SRA->RA_DTFIMCT))
				Aadd(aXML,"<DTTerminoContratoPrazoDeterminado>" + DTOS(SRA->RA_DTFIMCT) + "</DTTerminoContratoPrazoDeterminado>")
			endif

			Aadd(aXML,"<TPContratoTempoParcial>" + SRA->RA_HOPARC + "</TPContratoTempoParcial>")

			if (val(SRA->RA_VIEMRAI) == 20 .or. val(SRA->RA_VIEMRAI) == 25) .or. (val(SRA->RA_VIEMRAI) == 70 .or. val(SRA->RA_VIEMRAI) == 75)
				Aadd(aXML,"<TPTrabalhador>2</TPTrabalhador>")
			else
				Aadd(aXML,"<TPTrabalhador>1</TPTrabalhador>")
			endif

			Aadd(aXML,"<DTQuitacaoRescisao>" + DTOS(SRG->RG_DATAHOM) + "</DTQuitacaoRescisao>")

	For n:=1 to Len(aXML)
		FWrite(nArq,aXML[n]+chr(13)+chr(10))
		If Ferror() # 0
			cMsg := STR0008+STR(Ferror(),3) 		//-- "Erro de grava‡„o, codigo DOS:"
			oSelf:SaveLog( STR0001+" - "+ cDrive+ ": "+cMsg) 
		Endif
	Next n
	aXML := {}
Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±|Fun‡…o    |Registro2     | Autor | Marcia Moura     | Data | 03/10/10 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±|Descri‡…o | Grava registro 2 - Dados do Empregado                     |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Sintaxe   |Registro2                                                  |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Uso       | GPEM602                                                   |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Registro2( oSelf )
Local n		:= 0
Local aXML	:= {}
Local aArea	:= GetArea()

// Limpa variaveis do Endereco do Funcionario
Private cEndFunc	:= ""
Private cNumFunc	:= ""

dbSelectArea( "SRA" )
dbSetOrder(1)
if  SRA->(DbSeek(substr(cChPrin,1,(nTamFil+6)))) 

    Aadd(aXML,"<Empregado>")
		Aadd(aXML,"<NRPisPasep>"	+ substr(SRA->RA_PIS,1,11)	+ "</NRPisPasep>")
	    Aadd(aXML,"<NRCpf>"			+ SRA->RA_CIC				+ "</NRCpf>")
        If !empty(SRA->RA_NOMECMP)
 	    	Aadd(aXML,"<NOEmpregado>"	+ alltrim( SRA->RA_NOMECMP ) + "</NOEmpregado>")
        Else
    	    Aadd(aXML,"<NOEmpregado>"	+ alltrim( SRA->RA_NOME )    + "</NOEmpregado>")
        EndIf
        Aadd(aXML,"<DTNascimento>"	+ dtos(SRA->RA_NASC)		+ "</DTNascimento>")
	    Aadd(aXML,"<NOMae>"			+ alltrim( SRA->RA_MAE )	+ "</NOMae>")

    	Aadd(aXML,"<Endereco>")
			Aadd(aXML,"<NRCep>" + alltrim( SRA->RA_CEP )	+ "</NRCep>") 

			// Separacao das informacoes do endereco em variaveis proprias
			If ! fBuscaNum( SRA->RA_ENDEREC )
				oSelf:SaveLog( STR0016 + STR0024 + "(" + SRA->RA_MAT + ")" )
			
				Aadd( aTitle, STR0016 + STR0024 + "(" + SRA->RA_MAT + ")"  )
				Aadd( aLog	, {} )
				aTotRegs[4] := Len( aLog )

				Aadd( aLog[aTotRegs[4]], STR0025 + SRA->RA_ENDEREC )
				Aadd( aLog[aTotRegs[4]], STR0026 + cEndFunc )
				Aadd( aLog[aTotRegs[4]], STR0027 + cNumFunc )

				oSelf:SaveLog( STR0016 + STR0024 + STR0025 + SRA->RA_ENDEREC )
				oSelf:SaveLog( STR0016 + STR0024 + STR0026 + cEndFunc )
				oSelf:SaveLog( STR0016 + STR0024 + STR0027 + cNumFunc )
				lErroEnde := .T.
			Else
				lErroEnde := .F.
			EndIf

			// Gera as informacoes no XML mesmo que ocorra falha na separacao
		  	Aadd(aXML,"<EDLogradouro>"	+ cEndFunc			+ "</EDLogradouro>")
		  	Aadd(aXML,"<NREndereco>"	+ cNumFunc			+ "</NREndereco>")

			// Se Complemento nao estiver preenchido, nao pode ser gerado sem espacos. Portanto nao pode ter ALLTRIM.
		  	Aadd(aXML,"<DSComplemento>"	+ SRA->RA_COMPLEM	+ "</DSComplemento>")
			Aadd(aXML,"<NOBairro>"		+ SRA->RA_BAIRRO	+ "</NOBairro>")
			Aadd(aXML,"<NOMunicipio>"	+ SRA->RA_MUNICIP	+ "</NOMunicipio>")
			Aadd(aXML,"<SGUF>"			+ SRA->RA_ESTADO	+ "</SGUF>")
				
		Aadd(aXML,"</Endereco>")

		Aadd(aXML,"<NRCtps>"		+ strzero(val(SRA->RA_NUMCP),7)	+ "</NRCtps>") 
		Aadd(aXML,"<NRSerieCTPS>"	+ SRA->RA_SERCP						+ "</NRSerieCTPS>") 
		Aadd(aXML,"<SGUfCtps>"		+ alltrim( SRA->RA_UFCP )			+ "</SGUfCtps>") 

		For n:=1 to Len(aXML)
			FWrite(nArq,aXML[n]+chr(13)+chr(10))
			If Ferror() # 0
				cMsg := STR0008+STR(Ferror(),3) 		//-- "Erro de grava‡„o, codigo DOS:"
				oSelf:SaveLog( STR0001+" - "+ cDrive+ ": "+cMsg) 
			Endif
		Next n
Endif	

aXML := {}

RestArea( aArea )
Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±|Fun‡…o    |Registro4     | Autor | Marcia Moura     | Data | 03/10/10 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±|Descri‡…o | Grava registro 4 - férias                                 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Sintaxe   |Registro4                                                  |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Uso       | GPEM602                                                   |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Registro4( oSelf )
Local i		:= 0
Local aXML	:= {}
Local n		:= 0

if len( aAux2 ) == 0
	Return
endif

Aadd(aXML,"<Ferias>")
	For i=1 to len(aAux2)
		Aadd(aXML,"<PeriodoAquisitivo>")

			Aadd(aXML,"<DTInicio>"			+ dtos(aAux2[i,1])	+ "</DTInicio>")
			Aadd(aXML,"<DTFim>"				+ dtos(aAux2[i,2])	+ "</DTFim>")
			Aadd(aXML,"<TPQuitacaoFerias>"	+ aAux2[i,3]		+ "</TPQuitacaoFerias>")

			if val(aAux2[i,3]) == 2
				Aadd(aXML,"<NRFaltas>"		+ strzero(aAux2[i,4],2) + "</NRFaltas>")
			endif

		Aadd(aXML,"</PeriodoAquisitivo>")
	next i
Aadd(aXML,"</Ferias>")

For n:=1 to Len(aXML)
	FWrite(nArq,aXML[n]+chr(13)+chr(10))
	If Ferror() # 0
		cMsg := STR0008+STR(Ferror(),3) 		//-- "Erro de grava‡„o, codigo DOS:"
		oSelf:SaveLog( STR0001+" - "+ cDrive+ ": "+cMsg) 
	Endif
Next n

aXML := {}

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±|Fun‡…o	 |fBuscCODIGO | Autor |Marcia Moura               | Data | 11/11/10 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±|Descri‡…o |Obtem o codigo da rubrica  	                			        |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Sintaxe	 |fBuscCODIGO(cCodigo,cTipo)							        	|±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±| Uso		 | GPEM602   												        |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/  
Static Function fBuscCODIGO( cCodigo, cTipo, cFilTab )
Local nPosFixa	:= 0
Local cCodRet	:= ""

//Trata as verbas que nao precisam ter rubrica vinculada
If Empty(aCodFol) .And. Fp_CodFol(@aCodFol,xFilial("SRA",RGY->RGY_FILIAL)) .Or. cFilProc # cFilTab

	cFilProc	:= cFilTab
	cVbNoValid	:=	aCodFol[034,1] +"/"+ aCodFol[035,1] +"/"+ aCodFol[048,1] +"/"+ ; 
					aCodFol[064,1] +"/"+ aCodFol[066,1] +"/"+ aCodFol[067,1] +"/"+ ;
					aCodFol[070,1] +"/"+ aCodFol[071,1] +"/"+ aCodFol[072,1] +"/"+ ;
					aCodFol[077,1] +"/"+ aCodFol[086,1] +"/"+ aCodFol[087,1] +"/"+ ;
					aCodFol[111,1] +"/"+ aCodFol[112,1] +"/"+ aCodFol[113,1] +"/"+ ;
					aCodFol[114,1] +"/"+ aCodFol[115,1] +"/"+ aCodFol[122,1] +"/"+ ;
					aCodFol[111,1] +"/"+ aCodFol[112,1] +"/"+ aCodFol[113,1] +"/"+ ;
					aCodFol[125,1] +"/"+ aCodFol[126,1] +"/"+ aCodFol[166,1] +"/"+ ;
					aCodFol[224,1] +"/"+ aCodFol[226,1] +"/"+ aCodFol[230,1] +"/"+ ;
					aCodFol[224,1] +"/"+ aCodFol[226,1] +"/"+ aCodFol[230,1] +"/"+ ;
					aCodFol[231,1] +"/"+ aCodFol[248,1] +"/"+ aCodFol[249,1] +"/"+ ;
					aCodFol[250,1] +"/"+ aCodFol[251,1] +"/"+ aCodFol[252,1] +"/"+ ;
					aCodFol[253,1] +"/"+ aCodFol[328,1] +"/"+ aCodFol[430,1] +"/"+ ;
					aCodFol[625,1] +"/"+ aCodFol[925,1] +"/"+ aCodFol[926,1]
	
Endif

// Retorna ZERO caso nao tenha sido relacionada nenhuma verba com rubrica externa
nPosFixa	:= IIf( Len( aTab27 ) > 0, aScan( aTab27, {|x| x[6] = cCodigo } ), 0 )
cCodRet		:= IIf( nPosFixa > 0, aTab27[ nPosFixa ][5], "000" )

If cCodigo $ cVbNoValid
	cCodRet	:= "@@@"
EndIf

If cCodRet <> "000" .And. cCodRet <> "@@@"
	If Len( aArray ) == 0 .or. aScan( aArray, { |x|(x[1]+x[2]) == cCodigo + cTipo } ) == 0
	    Aadd( aArray, { cCodigo, cTipo } )
	EndIf
Endif

Return( cCodRet )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±|Fun‡…o    |Registro9     | Autor | Marcia Moura     | Data | 03/10/10 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±|Descri‡…o | Grava dados do registro 9 - Outros codigos                |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Sintaxe   | Registro9                                                 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Uso       | GPEM602                                                   |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Registro9( oSelf )
Local cAliasAnt	:= Alias() 
Local i			:= 0
Local n			:= 0
Local aXML		:= {}
Local cCodExt	:= ""

Aadd(aXML,"<Codigos>")
	If Len( aArray ) <> 0
		for i := 1 to Len( aArray )

			// Carrega Rubrica Externa relacionada a Verba para gerar no XML
			cCodExt := fBuscCODIGO( aArray[ i, 1 ], aArray[ i, 2 ] )

			if Val( aArray[ i, 2 ] ) == 1
				cCodExt := Replicate( "0", 20 - Len(cCodExt)) + cCodExt
			endif	

			Aadd(aXML,"<Codigo>")  
				Aadd(aXML,"<TPCodigo>" + aArray[ i, 2 ]	+ "</TPCodigo>")
				Aadd(aXML,"<CDCodigo>" + cCodExt		+ "</CDCodigo>")
	
				SRV->( DbSelectArea("SRV") )
				SRV->( DbSetOrder(1) )
				SRV->( DbGoTop() )
				IF SRV->( DbSeek( xFilial("SRV") +  aArray[i,1]) )	
			   		Aadd(aXML,"<DSCodigo>" + aArray[ i, 1 ] + "-" + fSubst( SRV->RV_DESC ) + "</DSCodigo>")
				endif
			Aadd(aXML,"</Codigo>")
		next i
	EndIf
Aadd(aXML,"</Codigos>") 

// Encerra TAG do Empregador aberto anteriormente
Aadd( aXML, "</Empregador>" )

For n := 1 to Len( aXML )
	FWrite( nArq, aXML[n] + chr(13) + chr(10) )
	If Ferror() # 0
		cMsg := STR0008+STR(Ferror(),3) 		//-- "Erro de grava‡„o, codigo DOS:"
		oSelf:SaveLog( STR0001+" - "+ cDrive+ ": "+cMsg) 
	Endif
Next n

aXML := {}
FClose( nArq )

dbselectarea( cAliasAnt )
Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±|Fun‡…o    |fBuscaNum     | Autor | Marcia Moura     | Data | 03/10/10 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±|Descri‡…o | Separa Endereco e Numero do Funcionario					 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Sintaxe   | fBuscaNum( cString )                                      |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Uso       | GPEM602                                                   |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fBuscaNum( cStrEnd )
Local nStrAtual		:= 0
Local nTamEndFun	:= 0
Local lRet			:= .F.
Local cCaracAtu		:= " "

// Limpa Endereco e Numero do Funcionario
cEndFunc	:= ""
cNumFunc	:= ""

If lRaNumEnd
	cEndFunc := cStrEnd
	cNumFunc := AllTrim( SRA->RA_NUMENDE )
Else
	For nStrAtual := 1 to Len( cStrEnd )
		cCaracAtu := SubStr( cStrEnd , nStrAtual , 1 )
	
		if Type( cCaracAtu ) == "N"
	
			// Carrega somente o NUMERO do Endereco do Funcionario nesta variavel
			cNumFunc := cNumFunc + cCaracAtu
	
			if nTamEndFun == 0 
				nTamEndFun := nStrAtual - 1
			endif
		endif
	Next
	
	// Caso o endereco do funcionario nao tenha nenhum NUMERO
	// informado, pelo menos o ENDERECO deve ser enviado
	nTamEndFun := IIf( nTamEndFun > 0, nTamEndFun, Len( cStrEnd ) )
	
	// Carrega somente o ENDERECO do Funcionario nesta variavel
	cEndFunc := substr( cStrEnd, 1, nTamEndFun )
EndIf

// Valida Numero do endereco do Funcionario, pois somente pode ser enviado
// NUMEROS para o XML. Caso seja diferente devera gerar Log de Ocorrencia.
lRet		:= (Len( cNumFunc ) > 0)
cCaracAtu	:= " "
If Len( cNumFunc ) > 0
	For nStrAtual := 1 to Len( cNumFunc )
		cCaracAtu := SubStr( cNumFunc , nStrAtual , 1 )

		if Type( cCaracAtu ) # "N"
			lRet := .F.
		endif
	Next
EndIf

Return( lRet )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±|Fun‡…o    | FTomador      | Autor | Cristina Ogura   | Data | 17/09/98 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±|Descri‡…o | Funcao que verifica o tomador                              |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Sintaxe   | FTomador                                                   |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Uso       | GPEM610                                                    |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FTomador( cAuxFil, cCentro )

Local lRet := .f.

dbSelectArea( "CTT" )
CTT->(dbSetOrder(1))

If cFilial == space(FWGETTAMFILIAL) .Or.  (cAuxFil == space(FWGETTAMFILIAL)  .And. cFilial # space(FWGETTAMFILIAL)) .or. empty(cAuxFil)
	cAuxFil := cFilial
Endif

cAuxFil := xFilial( "CTT", cAuxFil )

If CTT->( dbSeek(cAuxFil+cCentro) )
	If TYPE("CTT->CTT_CEI") # "U" .and. TYPE("CTT->CTT_TIPO") # "U"
	    if CTT->CTT_TIPO == "1" .OR. CTT->CTT_TIPO == "2"
		    if CTT->CTT_CEI <> ""
		    	lRet		:= .T.
		    	cDadosTom	:= CTT->CTT_TIPO + strzero(val(CTT->CTT_CEI),14)
      		endif
         endif
     endif
endif         

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±|Fun‡…o    |Cria Arq  | Autor | Marcia Moura          | Data | 16/11/10 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±|Descri‡…o | Criacao  do registro TXT                                   |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Sintaxe   | CriaTxt (cArquivo,oSelf)                                   |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Parametros| cArq := Diretorio        			                      |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±| Uso      | GPEM602                                                    |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CriaArq( cArquivo, oSelf )
Local cMsg 	:= ""
Local cTime := ""    

cDrive	:= alltrim(mv_par07)  
cTime	:= Time()
cTime	:= strtran(ctime,":","")  
cNumId	:= alltrim(cArquivo) +dtos(date())+ctime+".xml"
cDrive	:= cDrive +alltrim(cArquivo)+dtos(date())+ctime+".xml"
nArq	:= MSFCREATE(cDrive,0)

IF Ferror() # 0 .AND. nArq = -1
	cMsg := STR0007+STR(Ferror(),3) 		//-- "Erro de grava‡„o, codigo DOS:"
	oSelf:SaveLog( STR0001+" - "+ cDrive+ ": "+cMsg) 
	Return(.F.)
ELSE
	oSelf:SaveLog( STR0001+" - "+ cdrive+ ": "+STR0011) 
ENDIF

Return( .T. )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±|Fun‡…o    | FSubst        | Autor | Cristina Ogura   | Data | 17/09/98 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±|Descri‡…o | Funcao que substitui os caracteres especiais por espacos   |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Sintaxe   | FSubst()                                                   |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Uso       | GPEM610                                                    |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FSubst( cTexto )

Local aAcentos:={}
Local aAcSubst:={}
Local cImpCar := Space(01)
Local cImpLin :=""
Local cAux 	  :=""
Local cAux1	  :=""   
Local nTamTxt := Len(cTexto)	
Local j
Local nPos
  
// Para alteracao/inclusao de caracteres, utilizar a fonte TERMINAL no IDE com o tamanho
// maximo possivel para visualizacao dos mesmos.
// Utilizar como referencia a tabela ASCII anexa a evidencia de teste (FNC 807/2009).

aAcentos :=	{;   
			Chr(199),Chr(231),Chr(196),Chr(197),Chr(224),Chr(229),Chr(225),Chr(228),Chr(170),;
			Chr(201),Chr(234),Chr(233),Chr(237),Chr(244),Chr(246),Chr(242),Chr(243),Chr(186),;
			Chr(250),Chr(097),Chr(098),Chr(099),Chr(100),Chr(101),Chr(102),Chr(103),Chr(104),;
			Chr(105),Chr(106),Chr(107),Chr(108),Chr(109),Chr(110),Chr(111),Chr(112),Chr(113),;
			Chr(114),Chr(115),Chr(116),Chr(117),Chr(118),Chr(120),Chr(122),Chr(119),Chr(121),;
			Chr(065),Chr(066),Chr(067),Chr(068),Chr(069),Chr(070),Chr(071),Chr(072),Chr(073),;
			Chr(074),Chr(075),Chr(076),Chr(077),Chr(078),Chr(079),Chr(080),Chr(081),Chr(082),;
			Chr(083),Chr(084),Chr(085),Chr(086),Chr(088),Chr(090),Chr(087),Chr(089),Chr(048),;
			Chr(049),Chr(050),Chr(051),Chr(052),Chr(053),Chr(054),Chr(055),Chr(056),Chr(057),;
			Chr(038),Chr(195),Chr(212),Chr(211),Chr(205),Chr(193),Chr(192),Chr(218),Chr(220),;
			Chr(213),Chr(245),Chr(227),Chr(252),chr(167);
			}
			
aAcSubst :=	{;
			"C","c","A","A","a","a","a","a","a",;
			"E","e","e","i","o","o","o","o","o",;
			"u","a","b","c","d","e","f","g","h",;
			"i","j","k","l","m","n","o","p","q",;
			"r","s","t","u","v","x","z","w","y",;
			"A","B","C","D","E","F","G","H","I",;
			"J","K","L","M","N","O","P","Q","R",;
			"S","T","U","V","X","Z","W","Y","0",;
			"1","2","3","4","5","6","7","8","9",;
			"E","A","O","O","I","A","A","U","U",;
			"O","o","a","u","0";
			}

For j:=1 TO Len(AllTrim(cTexto))
	cImpCar	:=SubStr(cTexto,j,1)
	//-- Nao pode sair com 2 espacos em branco.
	cAux	:=Space(01)  
    nPos 	:= 0
	nPos 	:= Ascan(aAcentos,cImpCar)
	If nPos > 0
		cAux := aAcSubst[nPos]
	Elseif (cAux1 == Space(1) .And. cAux == space(1)) .Or. Len(cAux1) == 0
		cAux :=	""
	EndIf		
    cAux1 	:= 	cAux
	cImpCar	:=	cAux
	cImpLin	:=	cImpLin+cImpCar

Next j

//--Volta o texto no tamanho original
cImpLin := Left(cImpLin+Space(nTamTxt),nTamTxt)

Return cImpLin       
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±|Fun‡…o    |PrepReg45     | Autor | Marcia Moura     | Data | 03/10/10 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±|Descri‡…o | Prepara dados para gravacao do reg 4  e 5,  Ferias e 13   |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Sintaxe   | PrepReg45                                                 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Uso       | GPEM602                                                   |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PrepReg45( cDados )
Local aArea			:= GetArea()
Local aRGWArea		:= RGW->(GetArea())
Local i				:= 0
Local dDtInicial	:= MonthSub( SRA->RA_DEMISSA, 85 )	// Limita informacoes a 85 meses atras

Default cDados		:= ""

While RGW->RGW_FILIAL+RGW->RGW_MAT+RGW->RGW_TPRESC+DTOS(RGW->RGW_HOMOL) == cDados
	if RGW->RGW_TPREG == "1" 

		// Somente acrescenta no vetor se estiver dentro dos 85 meses anteriores
		If substr( dtos( RGW->RGW_DTINI ), 1, 6 ) >= AnoMes( dDtInicial )
			aadd( aAux2, { RGW->RGW_DTINI, RGW->RGW_DTFIM, RGW->RGW_QUIT, RGW->RGW_FALT }) //inicio per aqui, fim per aqui, pago e faltas
		EndIf
	else
		i := 0

		// Somente acrescenta no vetor se estiver dentro dos 85 meses anteriores
		If substr( dtos( RGW->RGW_DTINI ), 1, 6 ) >= AnoMes( dDtInicial )
			aadd( aAux, { substr( dtos(RGW->RGW_DTINI),1,4), RGW->RGW_QUIT, RGW->RGW_VALP13 }) // Carrega Ano, se pago e valor pago
		EndIf

		if (RGW->RGW_QUIT == "1" .AND. substr(dtos(RGW->RGW_DTINI),1,4) ==  substr(dtos(SRA->RA_DEMISSA),1,4)) .or. RGW->RGW_QUIT <> "1"

			For i := 1 to 12
				// Despreza registros com Data Menor que a Data de Admissao ou com Data Maior
				// que a Data de Demissao E se estiver dentro dos 85 meses anteriores
				If substr( dtos( RGW->RGW_DTINI ), 1, 4 ) + strzero( i, 2 ) >= AnoMes( SRA->RA_ADMISSA ) .AND. ;
				   substr( dtos( RGW->RGW_DTINI ), 1, 4 ) + strzero( i, 2 ) <= AnoMes( SRA->RA_DEMISSA ) .and. ;
				   substr( dtos( RGW->RGW_DTINI ), 1, 4 ) + strzero( i, 2 ) >= AnoMes( dDtInicial )

			 		if &( "RGW->RGW_M" + strzero( i, 2 ) ) <> 0
			  			aadd( aAux1, { substr(dtos(RGW->RGW_DTINI),1,4) + strzero(i,2), &("RGW->RGW_M"+strzero(i,2))	})	// ano e mes das Faltas
					else
			  			aadd( aAux1, { substr(dtos(RGW->RGW_DTINI),1,4) + strzero(i,2), 0								})	// mes e ano e Faltas
			  		endif

		 		EndIf
		 	next i

		endif
	endif
	RecLock( 'RGW', .f. )
		RGW->RGW_NUMID := cNumId
	MsUnLock()
	RGW->( DBSKIP() )
EndDo 

RestArea(aRGWArea)  	
RestArea(aArea)  	
Return 
