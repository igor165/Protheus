#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "HEADERGD.CH"
#INCLUDE "APWEBSRV.CH"
#include "AP5MAIL.CH"
#INCLUDE "FILEIO.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PTSREPOBJ

@author		Igor Franzoi
@since		04/08/2010
@version	1.0
@return		NIL
@obs		
/*/
//-------------------------------------------------------------------
User Function _TSADNEZCRX ; Return  // "dummy" function - Internal Use 

class PTSREPOBJ

	data aReadFields	//Array para armazenar as informacoes antes e depois das alteracoes
	data aCodeError		//Array contendo os codigos de retornos dos webservices
	data aRetError		//Array para armazenar as informacoes chaves para retorno no arquivo de LOG
	data cBodyMailAll	//String contendo as descricoes dos erros quando enviado via JOB
	data wsdlSave
	
	Method New()
	Method WSLegal( nOption )
	Method WSSindicatoLegal( nOption )
	Method WSNatural( nOption )
	Method WSUnit( nOption )
	Method WSAllocation( nOption )
	Method WSShiftWork( nOption )
	Method WSSCale( nOption , cWeek , cDayType )
	Method WSUser( nOption )

	Method WSDayNotWorked( nOption , aCompany , aOldDados )
	Method WSLocation( nOption )
	Method WSPositionLevel( nOption )
	Method WSCostCenter( nOption )
	Method WSException( nOption , aRegistry , aOldDados )
	Method WSAbsenceReason( nOption , cKeyUnit , cDataIni , cDataFim )
				
	Method WSReadRHExp( cAlias )
	Method WSUpdRHExp( cAlias , lClear )
	Method WSChkRHExp( cAlias, lJob , cField )
	Method WSTnoScale( cKeyShiftWork , ckeyWeek , cDayType )
	Method WSExpPairScale( nOption, cMat )
	Method WSLogSendWS( cService , oObject , lJOB , lRet , lSync, cExternalKey )
	Method WSSendMail( cService, cBody )
	Method WSSendArq( cService, cBody )
	Method WSLoadMsg( oObject )	
	Method WSInsertSync( oObject )	
	Method WSFieldsLoadMsg( oObject )		
endclass

//-------------------------------------------------------------------
/*/{Protheus.doc} New

@author		Igor Franzoi
@since		04/08/2010
@version	1.0
@return		NIL
@obs		Construtor do objeto
/*/
//-------------------------------------------------------------------
Method New() class PTSREPOBJ
Local lTsaDep	:= If( SQB->(ColumnPos('QB_RHEXP'))>0, SuperGetMv("MV_TSADEP", NIL ,.F. ),.F. )

	::aRetError		:= {} //Array para armazenar as informacoes chaves para retorno no arquivo de LOG do PONM430
	aAdd(::aRetError,{ "NaturalPerson"			, ' "| Chave Filial/Matricula-> " +SRA->RA_FILIAL +"/" +SRA->RA_MAT' 							, .F. } )
	aAdd(::aRetError,{ "LegalPerson"			, ' "| Chave Empresa/Filial-> " +SM0->M0_CODIGO +"/" +SM0->M0_CODFIL' 							, .F. } )
	aAdd(::aRetError,{ "Unit"					, ' "| Chave Empresa/Filial-> " +SM0->M0_CODIGO +"/" +SM0->M0_CODFIL' 							, .F. } )
	If !lTsaDep
		aAdd(::aRetError,{ "AllocationUnit"		, ' "| Chave Empresa/Filial-> " +SM0->M0_CODIGO +"/" +SM0->M0_CODFIL' 							, .F. } )
	Else
		aAdd(::aRetError,{ "AllocationUnit"		, ' "| Chave Empresa/Filial/Departamento-> " +SM0->M0_CODIGO +"/" +SQB->QB_FILIAL + "/" +SQB->QB_DEPTO' , .F. } )
	EndIf
	aAdd(::aRetError,{ "Location"				, ' "| Chave Empresa/Filial-> " +SM0->M0_CODIGO +"/" +SM0->M0_CODFIL' 							, .F. } )
	aAdd(::aRetError,{ "SindicatoLegal"			, ' "| Chave Filial/Sindicato-> " +RCE->RCE_FILIAL +"/" +RCE->RCE_CODIGO' 						, .F. } )
	aAdd(::aRetError,{ "ShiftWork"				, ' "| Chave Filial/Turno-> " +SR6->R6_FILIAL +"/" +SR6->R6_TURNO' 								, .F. } )
	aAdd(::aRetError,{ "updateDescriptionShiftWork"	,' "| Chave Filial/Turno-> " +SR6->R6_FILIAL +"/" +SR6->R6_TURNO' 							, .F. } )
	aAdd(::aRetError,{ "Scale"					, ' "| Chave Filial/Turno/Semana-> " +SPJ->PJ_FILIAL +"/" +SPJ->PJ_TURNO +"/" +SPJ->PJ_SEMANA' 	, .F. } )
	aAdd(::aRetError,{ "PositionLevel"			, ' "| Chave Filial/Funcao-> " +SRJ->RJ_FILIAL +"/" +SRJ->RJ_FUNCAO' 							, .F. } )
	aAdd(::aRetError,{ "User"					, ' "| Chave Filial/Matricula-> " +SRA->RA_FILIAL +"/" +SRA->RA_MAT' 							, .F. } )
	aAdd(::aRetError,{ "UserPositionLevel"		, ' "| Chave Filial/Matr/Funcao-> " +SRA->RA_FILIAL +"/" +SRA->RA_MAT +"/" +SRJ->RJ_FUNCAO' 	, .F. } )
	aAdd(::aRetError,{ "UserShiftWork"			, ' "| Chave Filial/Matr/Turno-> " +SRA->RA_FILIAL +"/" +SRA->RA_MAT +"/" +SR6->R6_TURNO' 		, .F. } )
	aAdd(::aRetError,{ "UserExternalKey"		, ' "| Chave Filial/Matricula-> " +SRA->RA_FILIAL +"/" +SRA->RA_MAT'							, .F. } )
	aAdd(::aRetError,{ "UserLocation"			, ' "| Chave Filial/Matricula-> " +SRA->RA_FILIAL +"/" +SRA->RA_MAT' 							, .F. } )
	aAdd(::aRetError,{ "UserRoleBadge"			, ' "| Chave Filial/Matricula-> " +SRA->RA_FILIAL +"/" +SRA->RA_MAT' 							, .F. } )
	aAdd(::aRetError,{ "UserCostCenter"			, ' "| Chave Filial/Matr/CCusto-> " +SRA->RA_FILIAL +"/" +SRA->RA_MAT +"/" +CTT->CTT_CUSTO' 	, .F. } )
	aAdd(::aRetError,{ "UserAllocationUnit"		, ' "| Chave Filial/Matricula-> " +SRA->RA_FILIAL +"/" +SRA->RA_MAT' 							, .F. } )
	aAdd(::aRetError,{ "DayNotWorked"			, ' "| Chave Filial/Data-> " +SP3->P3_FILIAL +"/" +DTOS(SP3->P3_DATA)' 							, .F. } )
	aAdd(::aRetError,{ "DayNotWorkedE"			, ' "| Chave Filial/Data-> " +SP2->P2_FILIAL +"/" +DTOS(SP2->P2_DATA)' 							, .F. } )
	aAdd(::aRetError,{ "CostCenter"				, ' "| Chave Filial/CCusto-> " +CTT->CTT_FILIAL +"/" +CTT->CTT_CUSTO' 							, .F. } )
	aAdd(::aRetError,{ "Exception"				, ' "| Chave Filial/Matricula-> " +SP2->P2_FILIAL +"/" +SP2->P2_MAT' 							, .F. } )
	aAdd(::aRetError,{ "AbsenceReason"			, ' "| Chave Filial-> " +SM0->M0_CODIGO +"/" +SM0->M0_CODFIL' 									, .F. } )
	aAdd(::aRetError,{ "UnitAbsenceReason"		, ' "| Chave Filial-> " +SM0->M0_CODIGO +"/" +SM0->M0_CODFIL' 									, .F. } )
	aAdd(::aRetError,{ "UserAbsenceReason"		, ' "| Chave Filial/Matricula-> " +SRA->RA_FILIAL +"/" +SRA->RA_MAT' 							, .F. } )
	aAdd(::aRetError,{ "RemoveUserAbsenceReason", ' "| Chave Filial/Matricula-> " +SRA->RA_FILIAL +"/" +SRA->RA_MAT' 							, .T. } )
	aAdd(::aRetError,{ "RemoveUserShiftWork"	, ' "| Chave Filial/Matricula-> " +SRA->RA_FILIAL +"/" +SRA->RA_MAT' 							, .T. } )
	aAdd(::aRetError,{ "RemoveUser"				, ' "| Chave Filial/Matricula-> " +SRA->RA_FILIAL +"/" +SRA->RA_MAT' 							, .T. } )
	aAdd(::aRetError,{ "RemovePositionLevel"	, ' "| Chave Filial/Funcao-> " +SRJ->RJ_FILIAL +"/" +SRJ->RJ_FUNCAO' 							, .T. } )
	aAdd(::aRetError,{ "RemoveNaturalPerson"	, ' "| Chave Filial/Matricula-> " +SRA->RA_FILIAL +"/" +SRA->RA_MAT' 							, .T. } )
	aAdd(::aRetError,{ "RemoveSindicatoLegal"	, ' "| Chave Filial/Sindicato-> " +RCE->RCE_FILIAL +"/" +RCE->RCE_CODIGO' 						, .T. } )
	aAdd(::aRetError,{ "RemoveShiftWork"		, ' "| Chave Filial/Turno-> " +SR6->R6_FILIAL +"/" +SR6->R6_TURNO' 								, .T. } )
	aAdd(::aRetError,{ "RemoveUserCostCenter"	, ' "| Chave Filial/Matr/CCusto-> " +SRA->RA_FILIAL +"/" +SRA->RA_MAT +"/" +CTT->CTT_CUSTO' 	, .T. } )			
	aAdd(::aRetError,{ "RemoveDayNotWorked"		, ' "| Chave Filial/Data-> " +SP3->P3_FILIAL +"/" +DTOS(SP3->P3_DATA)' 							, .T. } )
	aAdd(::aRetError,{ "RemoveDayNotWorkedE"	, ' "| Chave Filial/Data-> " +SP2->P2_FILIAL +"/" +DTOS(SP2->P2_DATA)' 							, .T. } )
	aAdd(::aRetError,{ "RemoveScale"			, ' "| Chave Filial/Turno/Semana-> " +SPJ->PJ_FILIAL +"/" +SPJ->PJ_TURNO +"/" +SPJ->PJ_SEMANA' 	, .T. } )
	aAdd(::aRetError,{ "RemoveCostCenter"		, ' "| Chave Filial/CCusto-> " +CTT->CTT_FILIAL +"/" +CTT->CTT_CUSTO' 							, .T. } )
	aAdd(::aRetError,{ "RemoveException"		, ' "| Chave Filial/Matricula-> " +SP2->P2_FILIAL +"/" +SP2->P2_MAT' 							, .T. } )
			
	// Os campos das tabelas foram baseados na documentacao do TSA, caso houver inclusao de propriedades/campos deverao ser revisado os array
	::aReadFields	:= {} 	//Array para armazenar as informacoes antes e depois das alteracoes
	::aCodeError	:= {}
	::cBodyMailAll	:= ""
	::wsdlsave		:= GetMv("MV_TSATLOG",.F.,3) == 5
	
	// Pessoa Juridica - SRA (WSRHLegalPerson:WSLegal)
	aAdd(::aCodeError,{ "00100", .F. } )	// Erro Tecnico (retornar erros ocorridos durante a execucao).
	aAdd(::aCodeError,{ "00101", .T. } )	// Inclusao/Alteracao da Empresa Juridica realizada com sucesso.
	aAdd(::aCodeError,{ "00102", .F. } )	// Chave externa da Empresa Juridica e obrigatoria.
	aAdd(::aCodeError,{ "00103", .F. } )	// Deve ser informado apenas um dos campos: CNPJ ou CEI.
	aAdd(::aCodeError,{ "00104", .T. } )	// Exclusão da unidade realizada com sucesso.
	aAdd(::aCodeError,{ "00105", .F. } )	// Usuario ou senha sao invalidos.
	aAdd(::aCodeError,{ "00106", .F. } )	// Nome da pessoa juridica e obrigatorio.
	aAdd(::aCodeError,{ "00107", .F. } )	// Pessoa juridica esta sendo usada, nao e possivel realizar a exclusao.

	// Unidade - SRA (WSRHLegalPerson:WSUnit)
	aAdd(::aCodeError,{ "00200", .F. } )	// Erro Tecnico (retornar erros ocorridos durante a execucao).
	aAdd(::aCodeError,{ "00201", .T. } )	// Inclusao/Alteracao da unidade realizada com sucesso.
	aAdd(::aCodeError,{ "00202", .F. } )	// Chave externa da Unidade e obrigatoria.
	aAdd(::aCodeError,{ "00203", .F. } )	// Chave externa de Pessoa Juridica e obrigatoria.
	aAdd(::aCodeError,{ "00204", .F. } )	// Codigo da unidade e obrigatorio.
	aAdd(::aCodeError,{ "00205", .F. } )	// Tipo da unidade e obrigatorio.
	aAdd(::aCodeError,{ "00206", .T. } )	// Exclusao da unidade realizada com sucesso.
	aAdd(::aCodeError,{ "00207", .T. } )	// Inclusao de relacionamento realizada com sucesso.
	aAdd(::aCodeError,{ "00208", .T. } )	// Exclusao de relacionamento realizada com sucesso.
	aAdd(::aCodeError,{ "00209", .F. } )	// Inclusao de relacionamento realizada parcialmente.
	aAdd(::aCodeError,{ "00210", .F. } )	// Unidade esta sendo usada, nao e possivel realizar a exclusao.
	aAdd(::aCodeError,{ "00211", .F. } )	// Inclusao de relacionamento nao realizada, nenhuma chave externa e existente.
	aAdd(::aCodeError,{ "00212", .F. } )	// Exclusao de relacionamento nao realizada, nenhuma chave externa e existente.
	aAdd(::aCodeError,{ "00213", .F. } )	// Usuario ou senha sao invalidos.
	aAdd(::aCodeError,{ "00214", .F. } )	// Unidade esta sendo usada, nao e possivel realizar a exclusao.
	aAdd(::aCodeError,{ "00215", .F. } )	// Descricao da Unidade e Obrigatoria.
	aAdd(::aCodeError,{ "00216", .F. } )	// Nenhum registro encontrado com a chave externa.

	// Centro de Custo - CTT (WSRHCostCenter:WSCostCenter)
	aAdd(::aCodeError,{ "00300", .F. } )	// Erro Tecnico (retornar erros ocorridos durante a execucao).
	aAdd(::aCodeError,{ "00301", .T. } )	// Inclusao/Alteracao do Centro de Custo realizada com sucesso.
	aAdd(::aCodeError,{ "00302", .F. } )	// Chave externa do Centro de Custo e obrigatoria.
	aAdd(::aCodeError,{ "00303", .T. } )	// Exclusao do Centro de Custo realizado com sucesso.
	aAdd(::aCodeError,{ "00304", .F. } )	// Usuario ou senha sao invalidos.
	aAdd(::aCodeError,{ "00305", .F. } )	// Descricao do Centro de Custo e obrigatoria.
	aAdd(::aCodeError,{ "00306", .F. } )	// Centro de Custo esta sendo usado, nao e possivel realizar a exclusao.

	// Unidade de Lotacao - SRA (WSRHLegalPerson:WSLocation)
	aAdd(::aCodeError,{ "00400", .F. } )	// Erro Tecnico (retornar erros ocorridos durante a execucao).
	aAdd(::aCodeError,{ "00401", .T. } )	// Inclusao/Alteracao da Unidade de Lotacao realizada com sucesso.
	aAdd(::aCodeError,{ "00402", .F. } )	// Chave externa da Unidade de Lotacao e obrigatoria.
	aAdd(::aCodeError,{ "00403", .T. } )	// Exclusao da Unidade de Lotacao realizada com sucesso.
	aAdd(::aCodeError,{ "00404", .F. } )	// Usuario ou senha sao invalidos.
	aAdd(::aCodeError,{ "00405", .F. } )	// Descricao da Unidade de Lotacao e obrigatoria.
	aAdd(::aCodeError,{ "00406", .F. } )	// Unidade de Lotacao esta sendo usada, nao e possivel realizar a exclusao.

	// Turno - SR6 (WSRHShiftWork:WSShiftWork)
	aAdd(::aCodeError,{ "00500", .F. } )	// Erro Tecnico (retornar erros ocorridos durante a execucao).
	aAdd(::aCodeError,{ "00501", .T. } )	// Inclusão/Alteracao do Turno realizada com sucesso.
	aAdd(::aCodeError,{ "00502", .F. } )	// Chave externa do Turno e obrigatoria.
	aAdd(::aCodeError,{ "00503", .F. } )	// Data de inicio e obrigatoria.
	aAdd(::aCodeError,{ "00504", .F. } )	// Data de inicio deve ser uma data valida.
	aAdd(::aCodeError,{ "00505", .T. } )	// Exclusao do Turno realizada com sucesso.
	aAdd(::aCodeError,{ "00506", .F. } )	// Pelo menos uma escala deve estar informada e deve conter pelo menos um intervalo de horario do tipo Jornada.
	aAdd(::aCodeError,{ "00507", .F. } )	// Descricao e obrigatoria.
	aAdd(::aCodeError,{ "00509", .F. } )	// Turno esta sendo usado, nao e possivel realizar a exclusao.

	// Escala - SR6 (WSRHShiftWork:WSSCale)
	aAdd(::aCodeError,{ "00600", .F. } )	// Erro Tecnico (retornar erros ocorridos durante a execucao).
	aAdd(::aCodeError,{ "00601", .T. } )	// Inclusao/Alteracao da Grade de Trabalho realizada com sucesso.
	aAdd(::aCodeError,{ "00602", .F. } )	// Chave externa da Grade de trabalho e obrigataria.
	aAdd(::aCodeError,{ "00603", .F. } )	// A chave externa do turno e obrigatorio.
	aAdd(::aCodeError,{ "00604", .F. } )	// A escala deve conter pelo menos um par de horario do tipo Jornada.
	aAdd(::aCodeError,{ "00605", .F. } )	// Os pares de horarios informados estao incorretos.
	aAdd(::aCodeError,{ "00606", .F. } )	// A sequencia de inicio e obrigatoria.
	aAdd(::aCodeError,{ "00607", .F. } )	// A sequencia de termino e obrigatoria.
	aAdd(::aCodeError,{ "00608", .F. } )	// O tipo e obrigatorio.
	aAdd(::aCodeError,{ "00609", .F. } )	// A entrada de jornada e obrigatoria.
	aAdd(::aCodeError,{ "00610", .F. } )	// A saida de jornada e obrigatoria.
	aAdd(::aCodeError,{ "00611", .F. } )	// A sequencia de inicio nao pode ser superior a sequencia de termino.
	aAdd(::aCodeError,{ "00612", .T. } )	// Exclusao do Turno realizada com sucesso.
	aAdd(::aCodeError,{ "00613", .F. } )	// Usuario ou senha sao invalidos.
	aAdd(::aCodeError,{ "00614", .F. } )	// Escala esta sendo usada, nao e possivel realizar a exclusao.

	// Pessoa Fisica - SRA (WSRHUser:WSNatural)
	aAdd(::aCodeError,{ "00700", .F. } )	// Erro Tecnico (retornar erros ocorridos durante a execucao).
	aAdd(::aCodeError,{ "00701", .T. } )	// Inclusao/Alteracao da Pessoa Fisica realizada com sucesso.
	aAdd(::aCodeError,{ "00702", .F. } )	// Chave externa da Pessoa Fisica e obrigatoria.
	aAdd(::aCodeError,{ "00703", .F. } )	// Pelo menos CPF ou RG deve ser informado.
	aAdd(::aCodeError,{ "00704", .T. } )	// Exclusao da pessoa fisica realizada com sucesso.
	aAdd(::aCodeError,{ "00705", .F. } )	// Usuario ou senha sao invalidos.
	aAdd(::aCodeError,{ "00706", .F. } )	// Pessoa Fisica esta sendo usada, nao e possivel realizar a exclusao.

	// Localidade - SRA (WSRHLegal:WSLocation)
	aAdd(::aCodeError,{ "00800", .F. } )	// Erro Tecnico (retornar erros ocorridos durante a execucao).
	aAdd(::aCodeError,{ "00801", .T. } )	// Inclusao/Alteracao da Localidade realizada com sucesso.
	aAdd(::aCodeError,{ "00802", .F. } )	// Chave externa da Localidade e obrigatoria.
	aAdd(::aCodeError,{ "00803", .T. } )	// Exclusao da localidade realizada com sucesso.
	aAdd(::aCodeError,{ "00804", .F. } )	// Usuario ou senha sao invalidos.
	aAdd(::aCodeError,{ "00805", .F. } )	// Pelo menos Pais, Estado ou Cidade deve ser informada.
	aAdd(::aCodeError,{ "00806", .F. } )	// Descricao de Pais deve ser informada.
	aAdd(::aCodeError,{ "00807", .F. } )	// Descricao de Estado deve ser informada.
	aAdd(::aCodeError,{ "00808", .F. } )	// Descricao de Cidade deve ser informada.
	aAdd(::aCodeError,{ "00809", .F. } )	// Localidade esta sendo usada, nao e possivel realizar a exclusao.

	// Cargo/Nivel - SRJ (WSRHPositionLevel:WSPositionLevel)
	aAdd(::aCodeError,{ "00900", .F. } )	// Erro Tecnico (retornar erros ocorridos durante a execucao).
	aAdd(::aCodeError,{ "00901", .T. } )	// Inclusao/Alteracao do Cargo/Nivel realizada com sucesso.
	aAdd(::aCodeError,{ "00902", .F. } )	// Chave externa da Cargo/Nivel e obrigatoria.
	aAdd(::aCodeError,{ "00903", .F. } )	// Descricao e obrigatoria;
	aAdd(::aCodeError,{ "00904", .T. } )	// Exclusao do Cargo/Nivel realizada com sucesso.
	aAdd(::aCodeError,{ "00905", .F. } )	// Usuario ou senha sao invalidos.
	aAdd(::aCodeError,{ "00906", .F. } )	// Cargo/Nivel esta sendo usada, nao e possivel realizar a exclusao.

	// Situacao de Afastamento - SX5 (WSRHAbsenceReason:WSAbsenceReason)
	aAdd(::aCodeError,{ "01000", .F. } )	// Erro Tecnico (retornar erros ocorridos durante a execucao).
	aAdd(::aCodeError,{ "01001", .T. } )	// Inclusao/Alteracao da situacao de afastamento realizada com sucesso.
	aAdd(::aCodeError,{ "01002", .F. } )	// Chave externa da situacao de afastamento e obrigatoria.
	aAdd(::aCodeError,{ "01003", .F. } )	// Tipo da situacao de afastamento e obrigatorio.
	aAdd(::aCodeError,{ "01004", .T. } )	// Exclusao da situacao de afastamento realizada com sucesso.
	aAdd(::aCodeError,{ "01005", .F. } )	// Data inicio e Data termino sao obrigatorias.
	aAdd(::aCodeError,{ "01006", .T. } )	// Exclusao do relacionamento realizado com sucesso.
	aAdd(::aCodeError,{ "01007", .F. } )	// Usuario ou senha sao invalidos.
	aAdd(::aCodeError,{ "01008", .F. } )	// Descricao da situacao de afastamento e obrigatoria;
	aAdd(::aCodeError,{ "01009", .F. } )	// Situacao de afastamento esta sendo usada, nao e possivel realizar a exclusao.
	aAdd(::aCodeError,{ "01010", .T. } )	// Inclusao do relacionamento realizado com sucesso.

	// Excessao - SP2 (WSRHEDayNotWorked:WSDayNotWorked(4))
	aAdd(::aCodeError,{ "01100", .F. } )	// Erro Tecnico (retornar erros ocorridos durante a execucao).
	aAdd(::aCodeError,{ "01101", .T. } )	// Inclusao/Alteracao da excessao realizada com sucesso.
	aAdd(::aCodeError,{ "01102", .F. } )	// Chave externa da excessao e obrigatoria.
	aAdd(::aCodeError,{ "01103", .F. } )	// Tipo da excessao e obrigatorio.
	aAdd(::aCodeError,{ "01104", .F. } )	// Origem e obrigatorio.
	aAdd(::aCodeError,{ "01105", .F. } )	// Data Inicio e obrigatorio.
	aAdd(::aCodeError,{ "01106", .F. } )	// Data Termino e obrigatorio.
	aAdd(::aCodeError,{ "01112", .T. } )	// Exclusao da excessao realizada com sucesso.
	aAdd(::aCodeError,{ "01113", .F. } )	// Pelo menos um periodo deve ser informado.
	aAdd(::aCodeError,{ "01114", .F. } )	// Usuario ou senha invalidos.
	aAdd(::aCodeError,{ "01115", .F. } )	// Os pares de horarios informados estao incorretos.
	//aAdd(::aCodeError,{ "01106", .F. } )	// Direcao e obrigatorio.

	// Dias nao trabalhado - SP3 (WSRHEDayNotWorked:WSDayNotWorked(1))
	aAdd(::aCodeError,{ "01200", .F. } )	// Erro Tecnico (retornar erros ocorridos durante a execucao).
	aAdd(::aCodeError,{ "01201", .T. } )	// Inclusao/Alteracao da excessao realizada com sucesso.
	aAdd(::aCodeError,{ "01202", .F. } )	// Chave externa da excessao e obrigatoria.
	aAdd(::aCodeError,{ "01203", .F. } )	// Recorrente e obrigatorio.
	aAdd(::aCodeError,{ "01204", .F. } )	// Data e obrigatoria.
	aAdd(::aCodeError,{ "01205", .T. } )	// Exclusao do dia nao trabalhado realizada com sucesso.
	aAdd(::aCodeError,{ "01206", .F. } )	// O turno deve ser informado.
	aAdd(::aCodeError,{ "01207", .F. } )	// A localidade deve ser informada.
	aAdd(::aCodeError,{ "01208", .F. } )	// Usuario ou senha invalidos.
	aAdd(::aCodeError,{ "01209", .F. } )	// Dia nao trabalhado esta sendo usado, nao e possivel realizar a exclusao.
	aAdd(::aCodeError,{ "01210", .T. } )	// Inclusao do relacionamento Dia Nao Trabalhado/Localidade/Turno realizado com sucesso.
	aAdd(::aCodeError,{ "01211", .T. } )	// Exclusao do relacionamento Dia Nao Trabalhado/Localidade/Turno realizado com sucesso.
	
	// Usuario - SRA (WSRHUser:WSUser)
	aAdd(::aCodeError,{ "01300", .F. } )	// Erro Tecnico (retornar erros ocorridos durante a execucao).
	aAdd(::aCodeError,{ "01301", .T. } )	// Inclusao/Alteracao do usuario realizada com sucesso.
	aAdd(::aCodeError,{ "01302", .F. } )	// Chave externa do usuario nao foi informada.
	aAdd(::aCodeError,{ "01303", .F. } )	// Chave externa de pessoa fisica nao foi informada.
	aAdd(::aCodeError,{ "01304", .F. } )	// O tipo papel nao foi informado.
	aAdd(::aCodeError,{ "01305", .F. } )	// Data inicio de validade do turno deve ser informada.
	aAdd(::aCodeError,{ "01306", .F. } )	// Data termino de validade do turno deve ser informada.
	aAdd(::aCodeError,{ "01307", .F. } )	// Data inicio de validade do Centro de custo deve ser informada.
	aAdd(::aCodeError,{ "01308", .F. } )	// Data termino de validade do Centro de custo deve ser informada.
	aAdd(::aCodeError,{ "01309", .F. } )	// Data inicio de validade do Cargo/Nivel deve ser informada.
	aAdd(::aCodeError,{ "01310", .F. } )	// Data termino de validade do Cargo/Nivel deve ser informada.
	aAdd(::aCodeError,{ "01311", .F. } )	// Data inicio de validade da Unidade de Lotacao deve ser informada.
	aAdd(::aCodeError,{ "01312", .F. } )	// Data termino de validade da Unidade de Lotacao deve ser informada.
	aAdd(::aCodeError,{ "01313", .F. } )	// Data inicio de validade da Localidade deve ser informada.
	aAdd(::aCodeError,{ "01314", .F. } )	// Data termino de validade da Localidade deve ser informada.
	aAdd(::aCodeError,{ "01315", .F. } )	// Chave externa de pessoa fisica nao existe.
	aAdd(::aCodeError,{ "01316", .F. } )	// Chave externa de turno nao existe.
	aAdd(::aCodeError,{ "01317", .F. } )	// Chave externa de centro de custo nao existe.
	aAdd(::aCodeError,{ "01318", .F. } )	// Chave externa de cargo/nivel nao existe.
	aAdd(::aCodeError,{ "01319", .F. } )	// Chave externa de unidade de lotacao nao existe.
	aAdd(::aCodeError,{ "01320", .F. } )	// Chave externa de localidade nao existe.
	aAdd(::aCodeError,{ "01321", .F. } )	// Chave externa de usuario nao existe.
	aAdd(::aCodeError,{ "01322", .T. } )	// Relacionamento incluido/alterado com sucesso.
	aAdd(::aCodeError,{ "01323", .F. } )	// Usuario ou senha invalidos.
	aAdd(::aCodeError,{ "01324", .F. } )	// Usuario esta sendo usado, nao e possivel realizar a exclusao.
	aAdd(::aCodeError,{ "01325", .T. } )	// Exclusao do usuario realizada com sucesso.
	aAdd(::aCodeError,{ "01326", .T. } )	// Exclusao do relacionamento de usuario com "nome do relacionamento", realizada com sucesso.
	aAdd(::aCodeError,{ "01327", .F. } )	// Exclusao do relacionamento de usuario com "nome do relacionamento", nao realizada.

	// Marcacoes
	aAdd(::aCodeError,{ "01400", .F. } )	// Erro Tecnico (retornar erros ocorridos durante a execucao).
	aAdd(::aCodeError,{ "01401", .T. } )	// Importacao da batida realizada no REP: "numero do rep" e NSR: "numero do nsr" foi importada com sucesso. 
	aAdd(::aCodeError,{ "01402", .F. } )	// Importação da batida realizada no REP: "numero do rep" e NSR: "numero do nsr" nao foi importada.
	
Return (Nil)

//-------------------------------------------------------------------
/*/{Protheus.doc} WSNatural

@author		Aldo Marini
@since		15/06/2011
@version	1.0
@return		NIL
@obs		Envia as informacoes de Funcionarios para Web Services aplicativo TSA
/*/
//-------------------------------------------------------------------
Method WSNatural( nOption ) class PTSREPOBJ

Local cDtRGEXP	:= Iif ( cPaisLoc == "BRA",  DTOS(SRA->RA_DTRGEXP), '' )
//Local cFone 	:= StrTran(StrTran(StrTran(AllTrim(SRA->RA_TELEFON),"-",""),")",""),"(","")
Local cServTSA	:= GetMv("MV_TSASERV",.F.,"http://localhost:8080")
Local oWSSrvCnt	:= WSNaturalPersonIntegrationServiceBeanService():New()
Local oSrvCnt	:= NaturalPersonIntegrationServiceBeanService_naturalPersonDTO():New()
Local lRet		:= .F.
Local aServices	:= {"NaturalPerson",;
					"WSNaturalPersonIntegrationServiceBeanService",;
					"NaturalPersonIntegrationServiceBeanService_naturalPersonDTO",;
					"InsertOrUpdate",;
					"" }
Local bBloco	:= { || .T. }
Local cBmpPict 	:= ""
Local cPathPict	:= GetSrvProfString("Startpath","") + "tsa\"
Local cExtensao	:= ".JPG"
Local cBitMap	:= ""
Local lTsa 		:= SUPERGETMV("MV_TSAINT",,.F., SRA->RA_FILIAL) 
Local lTsaCodU	:= ExistBlock( "PTSACODU" )

DEFAULT nOption := 1
If !ExistDir(cPathPict)
	makedir(cPathPict)
EndIf
cServTSA	    += If(Right(cServTSA,1) <> "/","/","")
oWSSrvCnt:_URL  := cServTSA+"NaturalPersonIntegrationServiceBean"
aServices[5]  	:= cServTSA+"NaturalPersonIntegrationServiceBean"

WsdlSaveXml (::WsdlSave) // utilizado para gerar XML de envio e recebimento do client(somente para debug)

// Inclusão ou Alteracao

If nOption == 1 .Or. nOption == 2

	If SRA->( FieldPos( "RA_CODUNIC" )) != 0 .And. !Empty( SRA->RA_CODUNIC )
		If !lTsaCodU
			oSrvCnt:cExternalKey	:= SRA->RA_CODUNIC
		Else
			oSrvCnt:cExternalKey	:= ExecBlock("PTSACODU",.F.,.F. )
		EndIf
	Else
		oSrvCnt:cExternalKey	:= AllTrim(cEmpAnt+SRA->RA_FILIAL+SRA->RA_MAT)
	EndIf
	oSrvCnt:cfilial			:= SRA->RA_FILIAL
	oSrvCnt:caddress		:= AllTrim(SRA->RA_ENDEREC)+ " " + AllTrim(SRA->RA_NUMENDE)+ " " + AllTrim(SRA->RA_COMPLEM)
	oSrvCnt:ccity			:= SRA->RA_MUNICIP
	oSrvCnt:ccountry		:= If(!Empty(SRA->RA_NACIONA),Tabela("34",SRA->RA_NACIONA),"")
	oSrvCnt:cemail          := SRA->RA_EMAIL
	oSrvCnt:cfederalId		:= SRA->RA_CIC
	oSrvCnt:cidCard			:= SRA->RA_RG
	If !lTsa
		oSrvCnt:csex			:= SRA->RA_SEXO
		oSrvCnt:cbirthDate		:= SubStr(dTos(SRA->RA_NASC),1,4)+"-"+SubStr(dTos(SRA->RA_NASC),5,2)+"-"+SubStr(dTos(SRA->RA_NASC),7,2)
	EndIf
	If !Empty(cDtRGEXP)	
		oSrvCnt:cidCardDate := SubStr(cDtRGEXP,1,4)+"-"+SubStr(cDtRGEXP,5,2)+"-"+SubStr(cDtRGEXP,7,2)
	Else
		oSrvCnt:cidCardDate := "1900-01-01"
	Endif
	oSrvCnt:cidCardEmitter  := SRA->RA_RGEXP
	oSrvCnt:cidCardState	:= SRA->RA_RGUF

	If !Empty( cBmpPict := Upper( AllTrim( SRA->RA_BITMAP ) ) )
		If File(cPathPict+cBmpPict+".BMP")
			Ferase(cPathPict+cBmpPict+".BMP")
		EndIf
		If File(cPathPict+cBmpPict+cExtensao)
			Ferase(cPathPict+cBmpPict+cExtensao)
		EndIf
		If RepExtract(cBmpPict,cPathPict+cBmpPict+cExtensao)
			If !File(cPathPict+cBmpPict+cExtensao)
				cExtensao := ".BMP"
			EndIf
			nHandle := FOpen(cPathPict+cBmpPict+cExtensao)
			If nHandle <> 0
				nLidos := 1
				While nLidos > 0
					cLeitura := ""
					nLidos := Fread(nHandle,@cLeitura,4096)
					cBitMap += cLeitura
				EndDo
				oSrvCnt:cimage := cBitMap
			Else
				oSrvCnt:cimage          := ""	// Implementacao Futura
			EndIf
			FClose(nHandle)
			Ferase(cPathPict+cBmpPict+cExtensao)
		Else
			oSrvCnt:cimage          := ""	// Implementacao Futura
		EndIf
	Else
		oSrvCnt:cimage          := ""	// Implementacao Futura
	EndIF

	oSrvCnt:cname			:= SRA->RA_NOME
	oSrvCnt:cneighborhood	:= SRA->RA_BAIRRO

	If !Empty(SRA->RA_TELEFON)
		oSrvCnt:nphone1     := Val(StrTran(StrTran(StrTran(AllTrim(SRA->RA_TELEFON),"-",""),")",""),"(",""))
		oSrvCnt:nphoneCode1 := Val(SRA->RA_DDDFONE)
	Else
		oSrvCnt:nphone1     := 0
		oSrvCnt:nphoneCode1	:= 0
	Endif

	If !Empty(SRA->RA_NUMCELU)
		oSrvCnt:nphone2		:= Val(StrTran(StrTran(StrTran(AllTrim(SRA->RA_NUMCELU),"-",""),")",""),"(",""))
		oSrvCnt:nphoneCode2	:= Val(SRA->RA_DDDCELU)
	Else
		oSrvCnt:nphone2		:= 0
		oSrvCnt:nphoneCode2	:= 0	
	EndIf

	oSrvCnt:cstate			:= SRA->RA_ESTADO
	oSrvCnt:czipCode 		:= SRA->RA_CEP

	oWSSrvCnt:oWsNaturalPersonDTO := oSrvCnt
	If !( lRet := oWSSrvCnt:insertOrUpdate(oSrvCnt) )
		// Avalia retorno da execucao do metodo
		bBloco	:= { || oWSSrvCnt:insertOrUpdate(oSrvCnt) }
		If !( lRet := fValidRet( bBloco ) )
			lRet := oObjRep:WSLogSendWS(aServices, oWSSrvCnt:oWsNaturalPersonDTO,,lRet)
		EndIf
	EndIf	

Else
	// Exclusao
	If !Empty(SRA->RA_RHEXP)
		If !( lRet := oWSSrvCnt:remove(AllTrim(cEmpAnt+SRA->RA_FILIAL+SRA->RA_MAT)) )
			bBloco	:= { || oWSSrvCnt:remove(AllTrim(cEmpAnt+SRA->RA_FILIAL+SRA->RA_MAT)) }
			If !( lRet := fValidRet( bBloco ) )
				// Avalia retorno da execucao do metodo
				aServices[1] := "RemoveNaturalPerson"
				aServices[4] := "remove"
				lRet := oObjRep:WSLogSendWS(aServices, oWSSrvCnt,,lRet,.T.,AllTrim(cEmpAnt+SRA->RA_FILIAL+SRA->RA_MAT))
			EndIf
		EndIf

	Endif
		
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} WSLegal

@author		Aldo Marini
@since		15/06/2011
@version	1.0
@return		NIL
@obs		Envia as informacoes de Funcionarios para Web Services aplicativo TSA
/*/
//-------------------------------------------------------------------
Method WSLegal( nOption ) class PTSREPOBJ
//Local cFone 	:= StrTran(StrTran(StrTran(AllTrim(SM0->M0_TEL),"-",""),")",""),"(","")
Local cServTSA	:= GetMv("MV_TSASERV",.F.,"http://localhost:8080")
Local oWSSrvCnt	:= WSLegalPersonIntegrationServiceBeanService():New()
Local oSrvCnt	:= LegalPersonIntegrationServiceBeanService_legalPersonDTO():New()
Local lRet		:= .F.
Local bBloco	:= { || .T. }

DEFAULT nOption := 1

cServTSA	+= If(Right(cServTSA,1) <> "/","/","")
oWSSrvCnt:_URL := cServTSA+"LegalPersonIntegrationServiceBean"

WsdlSaveXml (::WsdlSave) // utilizado para gerar XML de envio e recebimento do client(somente para debug)
// Inclusão ou Alteracao

If nOption == 1 .Or. nOption == 2

	oSrvCnt:caddress		:= SM0->M0_ENDCOB
	If SM0->M0_TPINSC == 1
		oSrvCnt:ccei		:= AllTrim(SM0->M0_CGC)
	Else
		oSrvCnt:ccei		:= ""
	Endif
	oSrvCnt:ccity			:= SM0->M0_CIDCOB
	oSrvCnt:ccompanyName	:= SM0->M0_NOMECOM
	oSrvCnt:ccountry		:= ""	// Campo não existe
	oSrvCnt:cemail          := ""	// Campo não existe
	oSrvCnt:cexternalKey	:= "E"+SM0->M0_CODIGO+SM0->M0_CODFIL
	If SM0->M0_TPINSC == 0 .OR. SM0->M0_TPINSC == 2
		oSrvCnt:cfederalId	:= AllTrim(SM0->M0_CGC)
	Else
		oSrvCnt:cfederalId	:= ""
	Endif
	oSrvCnt:cneighborhood	:= SM0->M0_BAIRCOB

	//	Retirado temporariamente para definicao da picture do campo RA_TELEFON
	//  Atualmente permite digitar qual caracter sem ter um padrao de preenchimento
	//  ocasionamento problemas no envio para o webservices do TSA
//	If !Empty(cFone)

//		oSrvCnt:nphone      := Val(cFone)
//		oSrvCnt:nphoneCode  := Val(Left(cFone,2))

//	Else
		oSrvCnt:nphone      := 0
		oSrvCnt:nphoneCode  := 0
//	Endif
	oSrvCnt:cstate			:= SM0->M0_ESTCOB
	oSrvCnt:czipCode 		:= SM0->M0_CEPCOB

	oWSSrvCnt:oWsLegalPersonDTO := oSrvCnt
	If !( lRet := oWSSrvCnt:insertOrUpdate(oSrvCnt) )
		bBloco	:= { || oWSSrvCnt:insertOrUpdate(oSrvCnt) }
		If !( lRet := fValidRet( bBloco ) )
			// Avalia retorno da execucao do metodo
			lRet := oObjRep:WSLogSendWS({"LegalPerson"},oWSSrvCnt:oWsLegalPersonDTO,,lRet)
		EndIf
	EndIf


Else
	// Exclusao
	lRet := oWSSrvCnt:remove("E"+SM0->M0_CODIGO+SM0->M0_CODFIL)
	bBloco := { || oWSSrvCnt:remove("E"+SM0->M0_CODIGO+SM0->M0_CODFIL) }
	lRet := fValidRet( bBloco )
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} WSSindicatoLegal

@author		Aldo Marini
@since		15/06/2011
@version	1.0
@return		NIL
@obs		Envia as informacoes de Funcionarios para Web Services aplicativo TSA
/*/
//-------------------------------------------------------------------
Method WSSindicatoLegal( nOption ) class PTSREPOBJ
Local cFone 	:= StrTran(StrTran(StrTran(AllTrim(RCE->RCE_FONE),"-",""),")",""),"(","")
Local cDDDFone 	:= StrTran(StrTran(StrTran(AllTrim(RCE->RCE_DDD),"-",""),")",""),"(","")
Local cServTSA	:= GetMv("MV_TSASERV",.F.,"http://localhost:8080")
Local oWSSrvCnt	:= WSLegalPersonIntegrationServiceBeanService():New()
Local oSrvCnt	:= LegalPersonIntegrationServiceBeanService_legalPersonDTO():New()
Local lRet		:= .F.
Local aServices	:= {"SindicatoLegal",;
					"WSLegalPersonIntegrationServiceBeanService",;
					"LegalPersonIntegrationServiceBeanService_legalPersonDTO",;
					"InsertOrUpdate",;
					"" }
Local bBloco	:= { || .T. }


DEFAULT nOption 	:= 1

cServTSA		+= If(Right(cServTSA,1) <> "/","/","")
oWSSrvCnt:_URL 	:= cServTSA+"LegalPersonIntegrationServiceBean"
aServices[5]	:= cServTSA+"LegalPersonIntegrationServiceBean"

WsdlSaveXml (::WsdlSave) // utilizado para gerar XML de envio e recebimento do client(somente para debug)

// Inclusão ou Alteracao

If nOption == 1 .Or. nOption == 2

	oSrvCnt:caddress		:= RCE->RCE_ENDER+" "+RCE->RCE_NUMER+" "+RCE->RCE_COMPLE
	oSrvCnt:ccei			:= ""
	oSrvCnt:ccity			:= RCE->RCE_MUNIC 	
	oSrvCnt:ccompanyName	:= RCE->RCE_DESCRI	
	oSrvCnt:ccountry		:= ""	// Campo não existe
	oSrvCnt:cemail          := RCE->RCE_EMAIL	
	oSrvCnt:cexternalKey	:= AllTrim("S"+cEmpAnt+RCE->RCE_FILIAL+RCE->RCE_CODIGO)
	oSrvCnt:cfederalId		:= AllTrim(RCE->RCE_CGC)
	oSrvCnt:cneighborhood	:= RCE->RCE_BAIRRO	

	If !Empty(RCE->RCE_FONE)
		oSrvCnt:nphone      := Val(cFone)
		oSrvCnt:nphoneCode  := Val(cDDDFone)
	Else
		oSrvCnt:nphone      := 0
		oSrvCnt:nphoneCode  := 0
	Endif
	oSrvCnt:cstate			:= RCE->RCE_UF	
	oSrvCnt:czipCode 		:= RCE->RCE_CEP	
	
	oWSSrvCnt:oWsLegalPersonDTO := oSrvCnt
	If !( lRet := oWSSrvCnt:insertOrUpdate(oSrvCnt) )
		bBloco	:= { || oWSSrvCnt:insertOrUpdate(oSrvCnt) }
		If !( lRet := fValidRet( bBloco ) )
			// Avalia retorno da execucao do metodo
			lRet := oObjRep:WSLogSendWS(aServices, oWSSrvCnt:oWsLegalPersonDTO,,lRet)
		EndIf	
	EndIf	

Else
	// Exclusao
	If !Empty(RCE->RCE_RHEXP)
		
		If !( lRet := oWSSrvCnt:remove(AllTrim("S"+cEmpAnt+RCE->RCE_FILIAL+RCE->RCE_CODIGO)) )
			bBloco := { || oWSSrvCnt:remove(AllTrim("S"+cEmpAnt+RCE->RCE_FILIAL+RCE->RCE_CODIGO)) }
			If !( lRet := fValidRet( bBloco ) )
				// Avalia retorno da execucao do metodo
				aServices[1] := "RemoveSindicatoLegal"
				aServices[4] := "remove"
				lRet := oObjRep:WSLogSendWS(aServices, oWSSrvCnt,,lRet,.T.,AllTrim("S"+cEmpAnt+RCE->RCE_FILIAL+RCE->RCE_CODIGO))		
			EndIf
		EndIf
	Endif
Endif

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} WSUnit

@author		Aldo Marini
@since		15/06/2011
@version	1.0
@return		NIL
@obs		Envia as informacoes de Funcionarios para Web Services aplicativo TSA
/*/
//-------------------------------------------------------------------
Method WSUnit( nOption ) class PTSREPOBJ
Local cServTSA	:= GetMv("MV_TSASERV",.F.,"http://localhost:8080")
Local oWSSrvCnt	:= WSUnitIntegrationServiceBeanService():New()
Local oSrvCnt	:= UnitIntegrationServiceBeanService_unitDTO():New()
Local lRet		:= .F.
Local bBloco	:= { || .T. }
					
DEFAULT nOption 	:= 1

cServTSA	+= If(Right(cServTSA,1) <> "/","/","")
oWSSrvCnt:_URL := cServTSA+"UnitIntegrationServiceBean"

WsdlSaveXml (::WsdlSave) // utilizado para gerar XML de envio e recebimento do client(somente para debug)

// Inclusão ou Alteracao

If nOption == 1 .Or. nOption == 2

	oSrvCnt:cdescription 			:= AllTrim(SM0->M0_FILIAL)+" "+SM0->M0_NOME
	oSrvCnt:cexternalKey			:= AllTrim(SM0->M0_CODIGO+SM0->M0_CODFIL+SM0->M0_FILIAL)
	oSrvCnt:clegalPersonExternalKey := "E"+SM0->M0_CODIGO+SM0->M0_CODFIL
	oSrvCnt:nunitType				:= 0

	oWSSrvCnt:oWSUnitDTO := oSrvCnt
	If !( lRet := oWSSrvCnt:insertOrUpdate(oSrvCnt) )
		bBloco	:= { || oWSSrvCnt:insertOrUpdate(oSrvCnt) }
		If !( lRet := fValidRet( bBloco ) )
			// Avalia retorno da execucao do metodo
			lRet := oObjRep:WSLogSendWS({"Unit"}, oWSSrvCnt:oWSUnitDTO,,lRet)
		EndIf
	EndIf

Else
// Exclusao
	lRet := oWSSrvCnt:remove(AllTrim(SM0->M0_CODIGO+SM0->M0_CODFIL+SM0->M0_FILIAL))
	bBloco	:= {|| oWSSrvCnt:remove(AllTrim(SM0->M0_CODIGO+SM0->M0_CODFIL+SM0->M0_FILIAL)) }
	lRet := fValidRet( bBloco )
Endif



Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} WSAllocation

@author		Aldo Marini
@since		15/06/2011
@version	1.0
@return		NIL
@obs		Envia as informacoes de Funcionarios para Web Services aplicativo TSA
/*/
//-------------------------------------------------------------------
Method WSAllocation( nOption ) class PTSREPOBJ
Local cAliasSQB 	:= GetNextAlias()
Local cWhere		:= ""
Local nTotReg		:= 0
Local nReg			:= 0
Local lRegua		:= .F.
Local cServTSA	:= GetMv("MV_TSASERV",.F.,"http://localhost:8080")
Local oWSSrvCnt	:= WSAllocationUnitIntegrationServiceBeanService():New()
Local oSrvCnt	:= AllocationUnitIntegrationServiceBeanService_AllocationUnitDTO():New()
Local lRet		:= .F.
Local bBloco	:= { || .T. }
Local lTsaDep	:= If( SQB->(ColumnPos('QB_RHEXP'))>0, SuperGetMv("MV_TSADEP", NIL ,.F. ),.F. )
					
DEFAULT nOption 	:= 1

cServTSA	+= If(Right(cServTSA,1) <> "/","/","")
oWSSrvCnt:_URL := cServTSA+"AllocationUnitIntegrationServiceBean"

WsdlSaveXml (::WsdlSave) // utilizado para gerar XML de envio e recebimento do client(somente para debug)

// Inclusão ou Alteracao

If nOption == 1 .Or. nOption == 2
	If !lTsaDep
		oSrvCnt:cdescription 			:= AllTrim(SM0->M0_FILIAL)+" "+SM0->M0_NOME
		oSrvCnt:cexternalKey			:= AllTrim(SM0->M0_CODIGO+SM0->M0_CODFIL+SM0->M0_FILIAL)

		oWSSrvCnt:oWSAllocationUnitDTO := oSrvCnt
		If !( lRet := oWSSrvCnt:insertOrUpdate(oSrvCnt) )
			bBloco	:= { || oWSSrvCnt:insertOrUpdate(oSrvCnt) }
			If !( lRet := fValidRet( bBloco ) )
				// Avalia retorno da execucao do metodo
				lRet := oObjRep:WSLogSendWS({"AllocationUnit"}, oWSSrvCnt:oWSAllocationUnitDTO,,lRet)
			EndIf
		EndIf
	Else
		cWhere		:= "% SQB.QB_FILIAL = '" + xFilial("SQB",SM0->M0_CODFIL) + "'  %"
		
		BeginSql alias cAliasSQB
			SELECT QB_FILIAL,QB_DEPTO, QB_DESCRIC
			FROM %table:SQB% SQB
			WHERE %exp:cWhere%
			and SQB.D_E_L_E_T_  = ' '
		EndSql
		
		While (cAliasSQB)->(!Eof())
		
			oSrvCnt:cdescription 			:= AllTrim(SM0->M0_CODIGO) +  " " + Alltrim((cAliasSQB)->QB_FILIAL) + " " + Alltrim((cAliasSQB)->QB_DESCRIC)
			oSrvCnt:cexternalKey			:= AllTrim(SM0->M0_CODIGO+(cAliasSQB)->QB_FILIAL+(cAliasSQB)->QB_DEPTO)

			oWSSrvCnt:oWSAllocationUnitDTO := oSrvCnt
			If !( lRet := oWSSrvCnt:insertOrUpdate(oSrvCnt) )
				bBloco	:= { || oWSSrvCnt:insertOrUpdate(oSrvCnt) }
				If !( lRet := fValidRet( bBloco ) )
					// Avalia retorno da execucao do metodo
					lRet := oObjRep:WSLogSendWS({"AllocationUnit"}, oWSSrvCnt:oWSAllocationUnitDTO,,lRet)
				EndIf
			EndIf
			(cAliasSQB)->(dbSkip())
		
		EndDo

		(cAliasSQB)->(dbCloseArea())
	EndIf
ElseIf lTsaDep .And. (nOption == 3 .Or. nOption == 4)

		oSrvCnt:cdescription 			:= AllTrim(SM0->M0_CODIGO) +  " " + Alltrim(SQB->QB_FILIAL) + " " + Alltrim(SQB->QB_DESCRIC)
		oSrvCnt:cexternalKey			:= AllTrim(cEmpAnt+SQB->QB_FILIAL+SQB->QB_DEPTO)

		oWSSrvCnt:oWSAllocationUnitDTO := oSrvCnt
		If !( lRet := oWSSrvCnt:insertOrUpdate(oSrvCnt) )
			bBloco	:= { || oWSSrvCnt:insertOrUpdate(oSrvCnt) }
			If !( lRet := fValidRet( bBloco ) )
				// Avalia retorno da execucao do metodo
				lRet := oObjRep:WSLogSendWS({"AllocationUnit"}, oWSSrvCnt:oWSAllocationUnitDTO,,lRet)
			EndIf
		EndIf

Else
// Exclusao
	If !lTsaDep
		lRet := oWSSrvCnt:remove(AllTrim(SM0->M0_CODIGO+SM0->M0_CODFIL+SM0->M0_FILIAL))
		bBloco	:= {|| oWSSrvCnt:remove(AllTrim(SM0->M0_CODIGO+SM0->M0_CODFIL+SM0->M0_FILIAL)) }
		lRet := fValidRet( bBloco )
	Else
		// Exclusao
		lRet := oWSSrvCnt:remove(AllTrim(cEmpAnt+SQB->QB_FILIAL+SQB->QB_DEPTO))
		bBloco	:= { || oWSSrvCnt:remove(AllTrim(cEmpAnt+SQB->QB_FILIAL+SQB->QB_DEPTO)) }
		lRet := fValidRet( bBloco )
	EndIf
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} WSShiftWork

@author		Aldo Marini
@since		15/06/2011
@version	1.0
@return		NIL
@obs		Envia as informacoes de Funcionarios para Web Services aplicativo TSA
/*/
//-------------------------------------------------------------------
Method WSShiftWork( nOption, cSeq ) class PTSREPOBJ
Local cServTSA		:= GetMv("MV_TSASERV",.F.,"localhost:8080")
Local oWSSrvCnt		:= WSShiftWorkIntegrationServiceBeanService():New()
Local oSrvCnt		:= ShiftWorkIntegrationServiceBeanService_ShiftWorkDTO():New()
Local lRet			:= .F.
Local aShiftWork	:= {}
Local nA			:= 0
Local nB			:= 0
Local nC			:= 0
Local nDiasSem		:= Dow(Date())
Local dDataRet		:= Date()
Local cDataShiftWork:= ""
Local aArea			:= GetArea()
Local aServices	:= {"ShiftWork",;
					"WSShiftWorkIntegrationServiceBeanService",;
					"ShiftWorkIntegrationServiceBeanService_ShiftWorkDTO",;
					"InsertOrUpdate",;
					"" }
Local bBloco	:= { || .T. }

DEFAULT nOption 	:= 1
DEFAULT cSeq 		:= "01"

cServTSA		+= If(Right(cServTSA,1) <> "/","/","")
oWSSrvCnt:_URL 	:= cServTSA+"ShiftWorkIntegrationServiceBean"
aServices[5]	:= cServTSA+"ShiftWorkIntegrationServiceBean"

WsdlSaveXml (::WsdlSave) // utilizado para gerar XML de envio e recebimento do client(somente para debug)

// Inclusão ou Alteracao
If nOption == 1

	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Modifica a data do incio do turno para o 1o.dia da sequencia a ser enviada ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If nDiasSem <> 2
		If nDiasSem == 1
			dDataRet := dDataRet - 6
		Else
			dDataRet := dDataRet - (nDiasSem - 2)
		Endif
	Endif

	cDataShiftWork	:= DTOS(dDataRet)
	cDataShiftWork	:= SubStr(cDataShiftWork,1,4)+"-"+SubStr(cDataShiftWork,5,2)+"-"+SubStr(cDataShiftWork,7,2)

	// Atualiza o array a aShiftWork com todas as oonfiguracoes conforme cadastro de Tabela de Horario Padrao
	aShiftWork := oObjREP:WSTnoScale( SR6->R6_FILIAL + SR6->R6_TURNO )	
	
	// Escala
 	If Len(aShiftWork) > 0           

		For nA := 1 to Len(aShiftWork)

			// Turno
			oSrvCnt	:= ShiftWorkIntegrationServiceBeanService_ShiftWorkDTO():New()
			oSrvCnt:cdescription 	:= SR6->R6_DESC
			oSrvCnt:cexternalKey	:= AllTrim(aShiftwork [ nA , 2 ])
			oSrvCnt:cinitialDate	:= cDataShiftWork + "T00:00:00"
			oSrvCnt:nsequence		:=  Len(aShiftWork) * 7

			For nB := 1 to Len( aShiftwork [ nA , 1 ] )
				oSCale:= ShiftWorkIntegrationServiceBeanService_scaleDTO():New()
			
				oSCale:ndayType 				:= aShiftWork [ nA , 1, nB, 1 ]		
				oSCale:cdescription 			:= aShiftWork [ nA , 1, nB, 2 ] 			
				oSCale:nendSequence 			:= aShiftWork [ nA , 1, nB, 7 ]		
				oSCale:cexternalKey 			:= AllTrim(aShiftwork [ nA , 2 ])+StrZero(nB,3)
				oSCale:ninitialSequence 		:= aShiftWork [ nA , 1 ,nB, 6 ]										
				oSCale:cshiftWorkExternalKey	:= AllTrim(aShiftwork [ nA , 2 ])
			
				// Pares da Escala
				// Horario de Trabalho
				For nC := 1 to Len( aShiftwork [ nA , 1, nB, 4 ] )
					
					oSCalePair:= ShiftWorkIntegrationServiceBeanService_scalePairDTO():New()
		
					oScalePair:cendTime          := aShiftWork [ nA , 1 , nB, 4 , nC , 1 ]				
					oScalePair:cinitialTime      := aShiftWork [ nA , 1 , nB, 4 , nC , 2 ]				
					oScalePair:npairType         := aShiftWork [ nA , 1 , nB, 4 , nC , 3 ]				
					oScalePair:cscaleExternalKey := AllTrim(aShiftwork [ nA , 2 ])+StrZero(nB,3)
					
					aAdd(oSCale:oWSScalePairDTOCol,oScalePair)

				Next

					aAdd(oSrvCnt:oWSScaleDTOCol,oScale)
			Next
							
			oWSSrvCnt:oWSShiftWorkDto := oSrvCnt
			If !( lRet := oWSSrvCnt:insertOrUpdate(oWSSrvCnt:oWSShiftWorkDto) )
				bBloco	:= { || oWSSrvCnt:insertOrUpdate(oWSSrvCnt:oWSShiftWorkDto) }
				If !( lRet := fValidRet( bBloco ) )	
					// Avalia retorno da execucao do metodo
					lRet := oObjRep:WSLogSendWS(aServices, oWSSrvCnt:oWSShiftWorkDto,,lRet)
				EndIf	
			EndIf	

		Next

	Endif

ElseIf nOption == 2 // Alteracao da descricao do turno

	If !Empty(SR6->R6_RHEXP)
		
		bBloco	:= { || oWSSrvCnt:updateDescriptionShiftWork(AllTrim(cEmpAnt+SPJ->PJ_FILIAL+SPJ->PJ_TURNO+SPJ->PJ_SEMANA),SR6->R6_DESC) }

		dbSelectArea("SPJ")
		If SPJ->(dbSeek(SR6->R6_FILIAL+SR6->R6_TURNO))
			While SPJ->(!Eof()) .And. SR6->R6_FILIAL+SR6->R6_TURNO == SPJ->PJ_FILIAL+SPJ->PJ_TURNO
				If !( lRet := oWSSrvCnt:updateDescriptionShiftWork(AllTrim(cEmpAnt+SPJ->PJ_FILIAL+SPJ->PJ_TURNO+SPJ->PJ_SEMANA),SR6->R6_DESC) )
					If !( lRet := fValidRet( bBloco ) )
						// Avalia retorno da execucao do metodo
						aServices[1] := "updateDescriptionShiftWork"
						aServices[4] := "updateDescriptionShiftWork"
						lRet := oObjRep:WSLogSendWS(aServices, oWSSrvCnt,,lRet,.T.,AllTrim(cEmpAnt+SPJ->PJ_FILIAL+SPJ->PJ_TURNO+SPJ->PJ_SEMANA))
					EndIf
				EndIf				

				SPJ->(dbSkip())			
			Enddo

		Endif

	Endif

Else
	// Exclusao
	If !Empty(SR6->R6_RHEXP)
		If !( lRet := oWSSrvCnt:remove(AllTrim(cEmpAnt+SR6->R6_FILIAL+SR6->R6_TURNO+cSeq)) )
			bBloco	:= { || oWSSrvCnt:remove(AllTrim(cEmpAnt+SR6->R6_FILIAL+SR6->R6_TURNO+cSeq)) }	
			If !( lRet := fValidRet( bBloco ) )	
				// Avalia retorno da execucao do metodo
				aServices[1] := "RemoveShiftWork"
				aServices[4] := "remove"
				lRet := oObjRep:WSLogSendWS(aServices, oWSSrvCnt,,lRet,.T.,AllTrim(cEmpAnt+SR6->R6_FILIAL+SR6->R6_TURNO+cSeq))
			EndIf
		Else
			If !( lRet := oObjREP:WSShiftWork( 1 ) )
				bBloco	:= { || oObjREP:WSShiftWork( 1 ) }
				If !( lRet := fValidRet( bBloco ) )	
					lRet := oObjRep:WSLogSendWS(aServices, oWSSrvCnt:oWSShiftWorkDto,,lRet)
				EndIf			
			EndIf
		EndIf
	Endif
Endif

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} WSScale

@author		Aldo Marini
@since		15/06/2011
@version	1.0
@return		NIL
@obs		Envia as informacoes de Funcionarios para Web Services aplicativo TSA
/*/
//-------------------------------------------------------------------
Method WSSCale( nOption , cWeek , cDayType) class PTSREPOBJ
Local cServTSA			:= GetMv("MV_TSASERV",.F.,"localhost:8080")
Local oWSSrvCnt			:= WSScaleIntegrationServiceBeanService():New()
Local lRet				:= .F.
Local aShiftWorkScale	:= {}
Local nA				:= 0
Local nB				:= 0
Local nT				:= 0
Local aServices	:= {"Scale",;
					"WSScaleIntegrationServiceBeanService",;
					"ScaleIntegrationServiceBeanService_SCALEDTO",;
					"InsertOrUpdate",;
					"" }
Local bBloco	:= { || .T. }

DEFAULT nOption 	:= 1
DEFAULT cWeek		:= ""
DEFAULT cDayType	:= ""

cServTSA		+= If(Right(cServTSA,1) <> "/","/","")
oWSSrvCnt:_URL 	:= cServTSA+"ScaleIntegrationServiceBean"
aServices[5]	:= cServTSA+"ScaleIntegrationServiceBean"

WsdlSaveXml (::WsdlSave) // utilizado para gerar XML de envio e recebimento do client(somente para debug)

// Inclusão ou Alteracao
If nOption == 1 .Or. nOption == 2 .Or. nOption == 4

	// Atualiza o array a aShiftWork com todas as oonfiguracoes conforme cadastro de Tabela de Horario Padrao
	aShiftWorkScale := oObjREP:WSTnoScale( SR6->R6_FILIAL + SR6->R6_TURNO, cWeek, cDayType )
	
	// Escala
 	If Len(aShiftWorkScale) > 0

		For nT := 1 to Len(aShiftWorkScale)

			For nA := 1 to Len( aShiftWorkScale[nT,1] )
	
				// Escala
				oSrvCnt	:= ScaleIntegrationServiceBeanService_SCALEDTO():New()
				oSrvCnt:ndayType 				:= aShiftworkScale [ nT , 1, nA, 1 ] 			
				oSrvCnt:cdescription 			:= aShiftworkScale [ nT , 1, nA, 2 ] 			
				oSrvCnt:nendSequence 			:= aShiftworkScale [ nT , 1, nA, 7 ]			
				oSrvCnt:cexternalKey 			:= aShiftworkScale [ nT , 1, nA, 8 ]
				oSrvCnt:ninitialSequence 		:= aShiftworkScale [ nT , 1 ,nA, 6 ]			
				oSrvCnt:cshiftWorkExternalKey	:= AllTrim(aShiftworkScale [ nT , 2 ])	

				// Pares da Escala
				// Horario de Trabalho
				For nB := 1 to Len( aShiftworkScale [ nT , 1, nA, 4 ] )
	
					oSCalePair:= SCaleIntegrationServiceBeanService_scalePairDTO():New()		
					oScalePair:cendTime          := aShiftworkScale [ nT , 1 , nA, 4 , nB , 1 ]				
					oScalePair:cinitialTime      := aShiftworkScale [ nT , 1 , nA, 4 , nB , 2 ]				
					oScalePair:npairType         := aShiftworkScale [ nT , 1 , nA, 4 , nB , 3 ]				
					oScalePair:cscaleExternalKey := aShiftworkScale [ nT , 1 , nA, 8 ]
		
					aAdd(oSrvCnt:oWSScalePairDTOCol,oScalePair)
					
				Next

				oWSSrvCnt:oWSscaleDTO := oSrvCnt
				If nOption == 1 .Or. nOption == 2
					lRet := oWSSrvCnt:insertOrUpdate(oWSSrvCnt:oWSscaleDTO)
					aServices[4] := "insertOrUpdate"
					bBloco	:= { || oWSSrvCnt:insertOrUpdate(oWSSrvCnt:oWSscaleDTO) }
				ElseIf nOption == 4
					lRet := oWSSrvCnt:updateScale(oWSSrvCnt:oWSscaleDTO)
					aServices[4] := "updateScale"
					bBloco	:= { || oWSSrvCnt:updateScale(oWSSrvCnt:oWSscaleDTO) }
				Endif
	
				// Avalia retorno da execucao do metodo
				If !lRet .And. !( lRet := fValidRet( bBloco ) )
					lRet := oObjRep:WSLogSendWS(aServices, oWSSrvCnt:oWSscaleDTO,,lRet)
				EndIf
				
				/*/
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Grava o controle de exportacao para o TSA - Escalas          ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				SPJ->(dbGoTo( aShiftWorkScale[ nT , 1, nA , 5 ] ))
				
				oObjRep:WSUpdRHExp( "SPJ" )
				
			Next
		Next

	Endif

ElseIf nOption == 3

	// Exclusao
	If !Empty(SPJ->PJ_RHEXP)
		If !( lRet := oWSSrvCnt:remove(cEmpAnt+SPJ->PJ_FILIAL+SPJ->PJ_TURNO+SPJ->PJ_SEMANA+SPJ->PJ_DIA) )
			bBloco	:= { || oWSSrvCnt:remove(cEmpAnt+SPJ->PJ_FILIAL+SPJ->PJ_TURNO+SPJ->PJ_SEMANA+SPJ->PJ_DIA) }	
			If !( lRet := fValidRet( bBloco ) )
				// Avalia retorno da execucao do metodo
				aServices[1] := "RemoveScale"
				aServices[4] := "remove"
				lRet := oObjRep:WSLogSendWS(aServices, oWSSrvCnt,,lRet,.T.,AllTrim(cEmpAnt+SPJ->PJ_FILIAL+SPJ->PJ_TURNO+SPJ->PJ_SEMANA+SPJ->PJ_DIA))	
			EndIf
		EndIf
	Endif
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} WSUser

@author		Aldo Marini
@since		15/06/2011
@version	1.0
@return		NIL
@obs		Envia as informacoes de Funcionarios para Web Services aplicativo TSA
/*/
//-------------------------------------------------------------------
Method WSUser( nOption, cDataIni , cUserNew , cUserOld, cCodeShiftWork, cKeyCCOld, cDataFim, cSeqCodeShiftWork,cKeyDptOld ) class PTSREPOBJ
Local cServTSA	:= GetMv("MV_TSASERV",.F.,"localhost:8080")
Local oWSSrvCnt	:= WSUserIntegrationServiceBeanService():New()
Local cDataAdm	:= DTOS(SRA->RA_ADMISSA)
Local cDataDem	:= DTOS(SRA->RA_DEMISSA)
Local lIncSeq	:= .F. 
Local lIntCracha:= SuperGetMv("MV_TSAIURB",.F.,.T.)
Local lTsaDep	:= If( SQB->(ColumnPos('QB_RHEXP'))>0, SuperGetMv("MV_TSADEP", NIL ,.F. ),.F. )
Local lRet		:= .F. 
Local lTsaAfast := ExistBlock( "PTSAAFAS" )   
Local lTsaDMar	:= ExistBlock( "PTSADMAR" )
Local lTsaCodU	:= ExistBlock( "PTSACODU" )
Local cWhere	:= ""
Local cSelect	:= ""
Local cOrder	:= ""
Local cAliasSR7	:= GetNextAlias()
Local cAliasSPF	:= GetNextAlias()
Local cAliasSRE	:= GetNextAlias()
Local cCracha	:= If( Type("cOldCracha") != "U", cOldCracha, SRA->RA_CRACHA )
Local lDemitido := .F.
Local lOnePosition := .T.
Local dDataDem	:= cToD('')

Local cDataEndPosition	:= "2049-12-31"
Local cDataShiftWork	:= SubStr(cDataAdm,1,4)+"-"+SubStr(cDataAdm,5,2)+"-"+SubStr(cDataAdm,7,2)
Local cDataPosition		:= SubStr(cDataAdm,1,4)+"-"+SubStr(cDataAdm,5,2)+"-"+SubStr(cDataAdm,7,2)
Local cDataCostCenter	:= SubStr(cDataAdm,1,4)+"-"+SubStr(cDataAdm,5,2)+"-"+SubStr(cDataAdm,7,2)
Local cDataDepartment	:= SubStr(cDataAdm,1,4)+"-"+SubStr(cDataAdm,5,2)+"-"+SubStr(cDataAdm,7,2)
Local cDataTrf			:= ""

Local aServices			:= {"User",;
							"WSUserIntegrationServiceBeanService",;
							"UserIntegrationServiceBeanService_userDTO",;
							"insertOrUpdate",;
							""}
Local bBloco			:= { || .T. }
Local cSGBD				:= AllTrim( Upper( TcGetDb() ) )
Local cTime				:= "T00:00:00"
Local lTsa 				:= SuperGetMV("MV_TSAINT",,.F., SRA->RA_FILIAL)
Local lDtAdmTrf 		:= SuperGetMV("MV_TSADTAD",.F.,.F.)

Local nDiasSem			:= 0
Local cDtRefTrn			:= ""
Local nSeqIni			:= 0

DEFAULT nOption 		:= 1
DEFAULT cDataIni 		:= SubStr(cDataAdm,1,4)+"-"+SubStr(cDataAdm,5,2)+"-"+SubStr(cDataAdm,7,2)
DEFAULT cUserNew 		:= cEmpAnt+SRA->RA_FILIAL+SRA->RA_MAT
DEFAULT cUserOld 		:= cEmpAnt+SRA->RA_FILIAL+SRA->RA_MAT
DEFAULT cCodeShiftWork	:= SRA->RA_TNOTRAB
DEFAULT cSeqCodeShiftWork	:= SRA->RA_SEQTURN
DEFAULT cKeyCCOld 		:= cEmpAnt+xFilial("CTT",SRA->RA_FILIAL)+SRA->RA_CC
DEFAULT cKeyDptOld 		:= If(!Empty(SRA->RA_DEPTO),cEmpAnt+xFilial("SQB",SRA->RA_FILIAL)+SRA->RA_DEPTO,"")
DEFAULT cDataFim		:= "2049-12-31"
DEFAULT lNovaSra		:= .F.

// nOption
// 1-insertorupdate
// 2-remove
// 3-insertUserPositionLevel
// 4-insertUserShiftWork
// 5-removeUserShiftWork
// 6-removeUserAllocationUnit
// 7-updateExternalKey
// 8-insertUserLocation
// 9-removeUserRoleBadge
//10-removeUserPositionLevel
//11-insertUserRoleBadge
//12-insertUserCostCenter
//13-insertUserAllocationUnit
//14-removeUserCostCenter
//15-removeUserLocation
//16-Atualiza apenas os dados do Usuario/funcionario

WsdlSaveXml (::WsdlSave) // utilizado para gerar XML de envio e recebimento do client(somente para debug)

cServTSA		+= If(Right(cServTSA,1) <> "/","/","")
oWSSrvCnt:_URL 	:= cServTSA+"UserIntegrationServiceBean"
aServices[5]	:= cServTSA+"UserIntegrationServiceBean"

If ValType(cDataIni) == "D"
	cDataIni := DTOS(cDataIni)
	cDataIni := SubStr(cDataIni,1,4)+"-"+SubStr(cDataIni,5,2)+"-"+SubStr(cDataIni,7,2)
Endif

cDataAdm := SubStr(cDataAdm,1,4)+"-"+SubStr(cDataAdm,5,2)+"-"+SubStr(cDataAdm,7,2)

If !Empty(SRA->RA_DEMISSA) .And. ( SRA->RA_SITFOLH = "D" .Or. SRA->RA_SITFOLH = "T" .Or. SRA->RA_RESCRAI $ "30/31" )
	If ( SRA->RA_SITFOLH = "T" .Or. SRA->RA_RESCRAI $ "30/31" )
		dDataDem	:= sToD(cDataDem) - 1
	Else
		dDataDem	:= sToD(cDataDem)
	EndIf	
	cDataDem	:= dToS(dDataDem)	
	cDataDem 	:= SubStr(cDataDem,1,4)+"-"+SubStr(cDataDem,5,2)+"-"+SubStr(cDataDem,7,2)
	lDemitido	:= .T.
Else
	cDataDem := "2049-12-31"
Endif

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Verifica a data da ultima alteracao de Transferencia de Funcionarios para considerar como data admissao ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If nOption == 1 .Or. ;		// Todos os metodos
	nOption == 8 .Or. ;		// insertUserLocation
	nOption == 11 .Or. ;	// insertUserRoleBadge	
	nOption == 12 .Or. ;	// insertUserCostCenter	
	nOption == 13			// insertUserAllocationUnit

	cSelect		:= " RE_DATA, RE_FILIALD,RE_FILIALP,RE_CCD,RE_CCP,RE_MATD,RE_MATP,RE_DEPTOD,RE_DEPTOP %"
	cWhere		:= "% SRE.RE_EMPP = '" + cEmpAnt + "' AND SRE.RE_FILIALP = '" + SRA->RA_FILIAL + "'  AND SRE.RE_MATP = '" + SRA->RA_MAT +"'"
	cOrder		:= "% RE_DATA DESC "
	Do Case
		Case cSGBD $ "ORACLE"
			cWhere += " AND ROWNUM <= 1 "
		Case cSGBD $ "MYSQL*POSTGRES"
			cOrder += " LIMIT 1 "
		Case cSGBD $ "DB2"
			cOrder += " FETCH FIRST 1 ROW ONLY "	 	
		Case cSGBD $ "INFORMIX"	
			cSelect := " FIRST 1 " + cSelect
		Otherwise
			cSelect := " TOP 1 " + cSelect
	EndCase

	cSelect := "% " + cSelect
	cWhere  := cWhere + " %"
	cOrder  := cOrder + " %"
		
	BeginSql alias cAliasSRE
		SELECT %exp:cSelect% 
		FROM %table:SRE% SRE
		WHERE %exp:cWhere% AND SRE.D_E_L_E_T_  = ' '
		ORDER BY %exp:cOrder%
	EndSql

	If (cAliasSRE)->(!Eof()) .And. !Empty((cAliasSRE)->RE_DATA)
		If DTOS(SRA->RA_ADMISSA) < (cAliasSRE)->RE_DATA
			If ( (cAliasSRE)->RE_FILIALD <> (cAliasSRE)->RE_FILIALP .Or. (cAliasSRE)->RE_MATD <> (cAliasSRE)->RE_MATP )
				If !lDtAdmTrf
					cDataAdm := SubStr((cAliasSRE)->RE_DATA,1,4)+"-"+SubStr((cAliasSRE)->RE_DATA,5,2)+"-"+SubStr((cAliasSRE)->RE_DATA,7,2)	
				EndIf 

				cDataTrf := SubStr((cAliasSRE)->RE_DATA,1,4)+"-"+SubStr((cAliasSRE)->RE_DATA,5,2)+"-"+SubStr((cAliasSRE)->RE_DATA,7,2)
				cDataShiftWork	:= cDataTrf
				cDataPosition	:= cDataTrf
				cDataCostCenter	:= cDataTrf
				cDataDepartment	:= cDataTrf
			ElseIf (cAliasSRE)->RE_CCD <> (cAliasSRE)->RE_CCP
				cDataCostCenter	:= SubStr((cAliasSRE)->RE_DATA,1,4)+"-"+SubStr((cAliasSRE)->RE_DATA,5,2)+"-"+SubStr((cAliasSRE)->RE_DATA,7,2)
			ElseIf ( (cAliasSRE)->RE_DEPTOD <> (cAliasSRE)->RE_DEPTOP ) .OR. ( Empty((cAliasSRE)->RE_DEPTOD) .AND. Empty((cAliasSRE)->RE_DEPTOP) )
				cDataDepartment	:= SubStr((cAliasSRE)->RE_DATA,1,4)+"-"+SubStr((cAliasSRE)->RE_DATA,5,2)+"-"+SubStr((cAliasSRE)->RE_DATA,7,2)
			Endif
		Endif
	Endif
	(cAliasSRE)->(DbCloseArea())

Endif

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Verifica a data da ultima alteracao salarial para envio ao metodo   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If nOption == 1 .Or. nOption == 3
	cWhere		:= "% SR7.R7_FILIAL = '" + SRA->RA_FILIAL + "'  AND SR7.R7_MAT = '" + SRA->RA_MAT +"' %"
	BeginSql alias cAliasSR7
		SELECT MAX(R7_DATA) AS R7_DATA
		FROM %table:SR7% SR7
		WHERE %exp:cWhere%
		and SR7.D_E_L_E_T_  = ' '
	EndSql
	If (cAliasSR7)->(!Eof()) .And. !Empty((cAliasSR7)->R7_DATA)
		If DTOS(SRA->RA_ADMISSA) < (cAliasSR7)->R7_DATA .And. cDataPosition < (cAliasSR7)->R7_DATA
			cDataPosition := SubStr((cAliasSR7)->R7_DATA,1,4)+"-"+SubStr((cAliasSR7)->R7_DATA,5,2)+"-"+SubStr((cAliasSR7)->R7_DATA,7,2)
		Endif
	Endif
	(cAliasSR7)->(DbCloseArea())
Endif

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Verifica a data da ultima alteracao de Turno de Trabalho            ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If nOption == 1
	cWhere		:= "% SPF.PF_FILIAL = '" + SRA->RA_FILIAL + "'  AND SPF.PF_MAT = '" + SRA->RA_MAT +"' AND SPF.PF_RHEXP = '      ' AND SPF.PF_REGRADE <> SPF.PF_REGRAPA AND SPF.PF_SEQUEDE <> SPF.PF_SEQUEPA AND SPF.PF_TURNODE <> SPF.PF_TURNOPA%"
	BeginSql alias cAliasSPF
		SELECT PF_DATA,PF_TURNOPA,PF_SEQUEPA
		FROM %table:SPF% SPF
		WHERE %exp:cWhere%
		and SPF.D_E_L_E_T_  = ' ' 
		ORDER BY PF_DATA DESC
	EndSql

	While (cAliasSPF)->(!Eof())
		If !Empty((cAliasSPF)->PF_DATA) .And. ;
			DTOS(SRA->RA_ADMISSA) < (cAliasSPF)->PF_DATA .And. ;
			DTOS(Date()) >= (cAliasSPF)->PF_DATA .And. ;
			cDataShiftWork < (cAliasSPF)->PF_DATA
			cDataShiftWork := SubStr((cAliasSPF)->PF_DATA,1,4)+"-"+SubStr((cAliasSPF)->PF_DATA,5,2)+"-"+SubStr((cAliasSPF)->PF_DATA,7,2)
			cCodeShiftWork := (cAliasSPF)->	PF_TURNOPA + (cAliasSPF)->PF_SEQUEPA
			lIncSeq 	   := .T.
		Endif
		If STOD((cAliasSPF)->PF_DATA) <= Date()
			Exit
		Endif
		(cAliasSPF)->(DbSkip())
	Enddo
	If !lIncSeq
		cCodeShiftWork  += cSeqCodeShiftWork 
	EndIf
	(cAliasSPF)->(DbCloseArea())
ElseIf nOption == 4
	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Caso nao seja opcao de inclusao inicializa a variavel do Turno com o conteudo do parametro dDataIni ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	cDataShiftWork	:= cDataIni
	cDataDem		:= cDataFim
	cCodeShiftWork  += cSeqCodeShiftWork
ElseIf nOption == 5
	cCodeShiftWork  += cSeqCodeShiftWork
Endif


If nOption == 1 .Or. nOption == 4	
	If !lTsa
		If IsInCallStack('PONM430') .Or. IsInCallStack('GPEA010')
			cDtRefTrn	:= StoD(StrTran(cDataIni,"-",""))
			nSeqIni		:= Val(SRA->RA_SEQTURN)
		Else
			cDtRefTrn	:= SPF->PF_DATA
			nSeqIni		:= Val(SPF->PF_SEQUEPA)
		EndIf
		nDiasSem	:= Dow(cDtRefTrn)
		
		If nDiasSem <> 2
			If nDiasSem == 1
				cDtRefTrn := cDtRefTrn - 6
			Else
				If nSeqIni > 1
					nSeqIni--
					cDtRefTrn := cDtRefTrn - ((nSeqIni * 7) + nDiasSem - 2)
				Else
					cDtRefTrn := cDtRefTrn - (nDiasSem - 2)
				EndIf
			Endif
		Endif
		cDtRefTrn := dToS(cDtRefTrn)
		cDtRefTrn := SubStr(cDtRefTrn,1,4)+"-"+SubStr(cDtRefTrn,5,2)+"-"+SubStr(cDtRefTrn,7,2)
	EndIf
EndIf

dbSelectArea("SRA")

// Posiciona no cadastro de Turno de Trabalho
SR6-> ( dbSeek ( fFilFunc("SR6") + SubStr(cCodeShiftWork,1,TAMSX3("RA_TNOTRAB")[1]) ) )

// Posiciona no cadastro de Departamento
SQB-> ( dbSeek ( fFilFunc("SQB") + SRA->RA_DEPTO ) )

// Posiciona no cadastro de Funcoes
SRJ-> ( dbSeek ( fFilFunc("SRJ") + SRA->RA_CODFUNC ) )

// Posiciona no cadastro de Centro de Custo
CTT-> ( dbSeek ( fFilFunc("CTT") + SRA->RA_CC ) )

If nOption == 1	.Or. nOption == 16 // Inclusao ou Alteracao

	// Usuario
	oSrvCnt	:= UserIntegrationServiceBeanService_userDTO():New()

	oSrvCnt:cexternalKey				:= AllTrim(cEmpAnt+SRA->RA_FILIAL+SRA->RA_MAT)

	If nOption == 1
		oSrvCnt:lflexibleInterval		:= If (Posicione( "SPA", 1, xFilial( "SPA", SRA->RA_FILIAL ) + SRA->RA_REGRA  , "PA_INMOVEL" )=="S",.T.,.F.)
	Else
		oSrvCnt:lflexibleInterval		:= 	If( SPA->PA_INMOVEL == "S" ,.T.,.F.)
	Endif

	If lDemitido
		oSrvCnt:cfireDate					:= cDataDem+cTime
	EndIf

	If !lTsa
		oSrvCnt:chiringDate					:= cDataAdm+cTime
	EndIf
	oSrvCnt:cfilial			  			:= SRA->RA_FILIAL

	oSrvCnt:cpis						:= StrZero(Val(SRA->RA_PIS),12)

	If SRA->( FieldPos( "RA_CODUNIC" )) != 0 .And. !Empty( SRA->RA_CODUNIC )
		If !lTsaCodU
			oSrvCnt:cNaturalPersonExternalKey	:= SRA->RA_CODUNIC
		Else
			oSrvCnt:cNaturalPersonExternalKey	:= ExecBlock("PTSACODU",.F.,.F. )
		EndIf
	Else
		oSrvCnt:cNaturalPersonExternalKey	:= AllTrim(cEmpAnt+SRA->RA_FILIAL+SRA->RA_MAT)
	EndIf
	
	If nOption == 1
		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Ponto de Entrada para retorno do controle de dupla marcacao  ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		IF ( lTsaDMar )
			oSrvCnt:lcontrolDoubleMarking := ExecBlock("PTSADMAR",.F.,.F. )
		Else
			oSrvCnt:lcontrolDoubleMarking	:= .T.
		EndIF   
	
		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Ponto de Entrada para retorno do controle de acesso          ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		IF ( lTsaAfast )
			oSrvCnt:lfreeAccess := ExecBlock("PTSAAFAS",.F.,.F. )
		EndIF                                                                                  
	
		// Turno de Trabalho
		If !IsInCallStack("Gpea010Alt")
			oShiftWork:= UserIntegrationServiceBeanService_userShiftWorkInsertDTO():New()
			oShiftWork:cendDate					:= cDataDem+cTime
			oShiftWork:cinitialDate 			:= cDataShiftWork+cTime
			oShiftWork:cshiftWorkExternalKey	:= AllTrim(cEmpAnt+SR6->R6_FILIAL+cCodeShiftWork)
			oShiftWork:cuserExternalKey			:= AllTrim(cEmpAnt+SRA->RA_FILIAL+SRA->RA_MAT)
			If !lTsa
				oShiftWork:cInitialScaleBaseDate	:= cDtRefTrn+cTime
			EndIf
			aAdd(oSrvCnt:oWSuserShiftWorkDTOCol,oShiftWork)
		EndIf
		
		// Unidade de lotacao
		oUserAllocation := UserIntegrationServiceBeanService_userAllocationUnitInsertDTO():New()
		oUserAllocation:cendDate					:= cDataDem+cTime
		oUserAllocation:callocationUnitExternalKey	:= If(lTsaDep ,AllTrim(cEmpAnt+SQB->QB_FILIAL+SQB->QB_DEPTO) ,AllTrim(WSTSAEmpresa(1)))
		oUserAllocation:cinitialDate 				:= If(lTsaDep,cDataDepartment+cTime, cDataAdm+cTime)
		oUserAllocation:cuserExternalKey			:= AllTrim(cEmpAnt+SRA->RA_FILIAL+SRA->RA_MAT)
		aAdd(oSrvCnt:oWSuserAllocationUnitDTOCol ,oUserAllocation)
	
		// Localizacao
		oUserLocation := UserIntegrationServiceBeanService_userLocationInsertDTO():New()
		oUserLocation:cendDate				:= cDataDem+cTime
		oUserLocation:cinitialDate 			:= cDataAdm+cTime
		oUserLocation:clocationExternalKey	:= "E"+WSTSAEmpresa(2)
		oUserLocation:cuserExternalKey		:= AllTrim(cEmpAnt+SRA->RA_FILIAL+SRA->RA_MAT)
		aAdd(oSrvCnt:oWSuserLocationDTOCol,oUserLocation)
	
		// Cargos
		oPositionLevel:= UserIntegrationServiceBeanService_userPositionLevelInsertDTO():New()
		oPositionLevel:cendDate						:= cDataDem+cTime
		oPositionLevel:cinitialDate 				:= cDataPosition+cTime
		oPositionLevel:cpositionLevelExternalKey	:= cEmpAnt+SRJ->RJ_FILIAL+SRJ->RJ_FUNCAO
		oPositionLevel:cuserExternalKey				:= AllTrim(cEmpAnt+SRA->RA_FILIAL+SRA->RA_MAT)
		aAdd(oSrvCnt:oWSuserPositionLevelDTOCol,oPositionLevel)
	
		// Centro de Custo
		oCostCenter:= UserIntegrationServiceBeanService_userCostCenterInsertDTO():New()
		oCostCenter:cendDate						:= cDataDem+cTime
		oCostCenter:cinitialDate 					:= cDataCostCenter+cTime
		oCostCenter:ccostCenterExternalKey			:= cEmpAnt+CTT->CTT_FILIAL+CTT->CTT_CUSTO
		oCostCenter:cuserExternalKey				:= AllTrim(cEmpAnt+SRA->RA_FILIAL+SRA->RA_MAT)
		aAdd(oSrvCnt:oWSuserCostCenterDTOCol,oCostCenter)
	
		// Definicao de Papeis
		oRoleBadge := UserIntegrationServiceBeanService_userRoleBadgeInsertDTO():New()
		oRoleBadge:cendDate					:= cDataDem+cTime
		oRoleBadge:cinitialDate	 			:= cDataAdm+cTime
		oRoleBadge:cfilial			  		:= SRA->RA_FILIAL
		If (IsInCallStack("GPEM040"))
			// A propriedade InitialDateOld deve ser inicializada na exclusao da rescisao, para nao gerar inconsistencia no TSA
			// (Data fim do cracha = 31/12/9999). 
			oRoleBadge:cInitialDateOld		:=	cDataAdm+cTime
		EndIf
		oRoleBadge:cregistry				:= AllTrim(SRA->RA_MAT)
		If !lTsa
			oRoleBadge:croleType           	:= If( SRA->RA_CATFUNC == "A",'2','1')
		Else
			oRoleBadge:croleType           	:= If( SRA->RA_CATFUNC == "A",2,0)
		EndIf
		oRoleBadge:ctakerUnitExternalKey 	:= AllTrim(WSTSAEmpresa(1))
		oRoleBadge:cbadgeNumber			:= ""
		If lIntCracha .And. !Empty(SRA->RA_CRACHA)
			oRoleBadge:cbadgeNumber			:= alltrim(SRA->RA_CRACHA)
		EndIf
		oRoleBadge:cproviderUnitExternalKey	:= ""
		oRoleBadge:cuserExternalKey			:= AllTrim(cEmpAnt+SRA->RA_FILIAL+SRA->RA_MAT)
		aAdd(oSrvCnt:oWSuserRoleBadgeDTOCol,oRoleBadge)
	EndIf
	
	oWSSrvCnt:oWSUserDTO := oSrvCnt

	lRet := oWSSrvCnt:insertOrUpdate(oWSSrvCnt:oWSUserDTO)
	bBloco	:= { || oWSSrvCnt:insertOrUpdate(oWSSrvCnt:oWSUserDTO)  }
	If !( lRet ) .And. !( lRet := fValidRet( bBloco ) )
		// Avalia retorno da execucao do metodo
		lRet := oObjRep:WSLogSendWS(aServices, oWSSrvCnt:oWSUserDTO,,lRet)
	EndIf		
ElseIf nOption == 2	// Exclusao

	If !Empty(SRA->RA_RHEXP)
		If !( lRet := oWSSrvCnt:remove(AllTrim(cEmpAnt+SRA->RA_FILIAL+SRA->RA_MAT)) )
			bBloco	:= { || oWSSrvCnt:remove(AllTrim(cEmpAnt+SRA->RA_FILIAL+SRA->RA_MAT))  }
			If !( lRet := fValidRet( bBloco ) )
				// Avalia retorno da execucao do metodo
				aServices[1] := "RemoveUser"
				aServices[4] := "remove"
				lRet := oObjRep:WSLogSendWS(aServices, oWSSrvCnt,,lRet,.T.,AllTrim(cEmpAnt+SRA->RA_FILIAL+SRA->RA_MAT))	
			EndIf
		EndIf
	Endif
		
ElseIf nOption == 3		// 3-insertUserPositionLevel

	If Select(cAliasSR7) > 0
		(cAliasSR7)->(DbCloseArea())
	Endif
	
	cWhere		:= "% SR7.R7_FILIAL = '" + SRA->RA_FILIAL + "'  AND SR7.R7_MAT = '" + SRA->RA_MAT +"' %"
	BeginSql alias cAliasSR7
		SELECT R7_DATA
		FROM %table:SR7% SR7
		WHERE %exp:cWhere%
		and SR7.D_E_L_E_T_  = ' '
		ORDER BY R7_DATA DESC
	EndSql
	
	While (cAliasSR7)->(!Eof())
		cDtAuxPosition := (cAliasSR7)->R7_DATA
		cDataIni 		:= SubStr(cDtAuxPosition,1,4)+"-"+SubStr(cDtAuxPosition,5,2)+"-"+SubStr(cDtAuxPosition,7,2)		
		Exit			
	Enddo						

	oPositionLevel:= UserIntegrationServiceBeanService_userPositionLevelInsertDTO():New()
	oPositionLevel:cinitialDate 			:= cDataIni+cTime
	oPositionLevel:cPositionLevelExternalKey:= cEmpAnt+SRJ->RJ_FILIAL+SRJ->RJ_FUNCAO
	oPositionLevel:cuserExternalKey			:= AllTrim(cEmpAnt+SRA->RA_FILIAL+SRA->RA_MAT)
	oWSSrvCnt:oWSuserPositionLevelInsertDTO := oPositionLevel

	If !( lRet := oWSSrvCnt:removeUserPositionLevel(oWSSrvCnt:oWSuserPositionLevelInsertDTO) )
		bBloco	:= { || oWSSrvCnt:removeUserPositionLevel(oWSSrvCnt:oWSuserPositionLevelInsertDTO) }
		If !( lRet := fValidRet( bBloco ) )
			// Avalia retorno da execucao do metodo
			aServices [1] := "RemoveUserPositionLevel"
			aServices [3] := "UserIntegrationServiceBeanService_userPositionLevelInsertDTO"
			aServices [4] := "removeUserPositionLevel"
			lRet := oObjRep:WSLogSendWS(aServices, oWSSrvCnt:oWSuserPositionLevelInsertDTO,,lRet,.T.)
		EndIf
	EndIf
ElseIf nOption == 4		// 4-insertUserShiftWork

	oShiftWork:= UserIntegrationServiceBeanService_userShiftWorkInsertDTO():New()
	oShiftWork:cendDate					:= cDataDem+cTime
	oShiftWork:cinitialDate 			:= cDataShiftWork+cTime
	oShiftWork:cshiftWorkExternalKey	:= AllTrim(cEmpAnt+SR6->R6_FILIAL+cCodeShiftWork)
	oShiftWork:cuserExternalKey			:= AllTrim(cEmpAnt+SRA->RA_FILIAL+SRA->RA_MAT)
	If !lTsa
		oShiftWork:cInitialScaleBaseDate	:= cDtRefTrn+cTime
	EndIf
	oWSSrvCnt:oWSuserShiftWorkInsertDTO := oShiftWork
	
	If !( lRet := oWSSrvCnt:insertUserShiftWork(oWSSrvCnt:oWSuserShiftWorkInsertDTO) )
		bBloco	:= { || oWSSrvCnt:insertUserShiftWork(oWSSrvCnt:oWSuserShiftWorkInsertDTO) }
		If !( lRet := fValidRet( bBloco ) )
			// Avalia retorno da execucao do metodo
			aServices[1] := "UserShiftWork"
			aServices[3] := "UserIntegrationServiceBeanService_userShiftWorkInsertDTO"
			aServices[4] := "insertUserShiftWork"
			lRet := oObjRep:WSLogSendWS(aServices, oWSSrvCnt:oWSUserShiftWorkInsertDTO,,lRet)
		EndIf
	EndIf
ElseIf nOption == 5		// 5-removeUserShiftWork

	oShiftWork:= UserIntegrationServiceBeanService_userShiftWorkInsertDTO():New()
	oShiftWork:cinitialDate 			:= cDataIni+cTime
	oShiftWork:cshiftWorkExternalKey	:= AllTrim(cEmpAnt+SR6->R6_FILIAL+cCodeShiftWork)
	oShiftWork:cuserExternalKey			:= AllTrim(cEmpAnt+SRA->RA_FILIAL+SRA->RA_MAT)
	oWSSrvCnt:oWSuserShiftWorkInsertDTO := oShiftWork

	If !( lRet := oWSSrvCnt:removeUserShiftWork(oWSSrvCnt:oWSuserShiftWorkInsertDTO) )
		bBloco	:= { || oWSSrvCnt:removeUserShiftWork(oWSSrvCnt:oWSuserShiftWorkInsertDTO) }
		If !( lRet := fValidRet( bBloco ) )
			// Avalia retorno da execucao do metodo
			aServices [1] := "RemoveUserShiftWork"
			aServices [3] := "UserIntegrationServiceBeanService_userShiftWorkInsertDTO"
			aServices [4] := "removeUserShiftWork"
			lRet := oObjRep:WSLogSendWS(aServices, oWSSrvCnt:oWSuserShiftWorkInsertDTO,,lRet,.T.)
		EndIf
	EndIf
ElseIf nOption == 7		// 7-updateExternalKey

	oUpdateUser:= UserIntegrationServiceBeanService_externalKeyUpdateDTO():New()
	oUpdateUser:cexternalKeyNew			:= AllTrim(cUserNew)
	oUpdateUser:cexternalKeyOld			:= AllTrim(cUserOld)
	oWSSrvCnt:oWSexternalKeyUpdateDTO 	:= oUpdateUser

	If !( lRet := oWSSrvCnt:updateExternalKey(oWSSrvCnt:oWSexternalKeyUpdateDTO) )
		bBloco	:= { || oWSSrvCnt:updateExternalKey(oWSSrvCnt:oWSexternalKeyUpdateDTO) }
		If !( lRet := fValidRet( bBloco ) )
			// Avalia retorno da execucao do metodo
			aServices[1] := "UserExternalKey"
			aServices[3] := "UserIntegrationServiceBeanService_externalKeyUpdateDTO"
			aServices[4] := "updateExternalKey"
	
			lRet := oObjRep:WSLogSendWS(aServices, oWSSrvCnt:oWSexternalKeyUpdateDTO,,lRet)
	
		EndIf
	EndIf
	
ElseIf nOption == 8		// 8-insertUserLocation

	oUserLocation := UserIntegrationServiceBeanService_userLocationInsertDTO():New()
	oUserLocation:cendDate				:= cDataDem+cTime
	oUserLocation:cinitialDate 			:= cDataAdm+cTime
	oUserLocation:clocationExternalKey	:= "E"+WSTSAEmpresa(2)
	oUserLocation:cuserExternalKey		:= AllTrim(cEmpAnt+SRA->RA_FILIAL+SRA->RA_MAT)
	oWSSrvCnt:oWSuserLocationInsertDTO	:= oUserLocation

	If !( lRet := oWSSrvCnt:insertUserLocation(oWSSrvCnt:oWSuserLocationInsertDTO) )
		bBloco	:= { || oWSSrvCnt:insertUserLocation(oWSSrvCnt:oWSuserLocationInsertDTO) }
		If !( lRet := fValidRet( bBloco ) )
			// Avalia retorno da execucao do metodo
			aServices[1] := "UserLocation"
			aServices[3] := "UserIntegrationServiceBeanService_userLocationInsertDTO"
			aServices[4] := "insertUserLocation"
	
			lRet := oObjRep:WSLogSendWS(aServices, oWSSrvCnt:oWSuserLocationInsertDTO,,lRet)
		
		EndIf
	EndIf

ElseIf nOption == 11	//11-insertUserRoleBadge

	oRoleBadge := UserIntegrationServiceBeanService_userRoleBadgeInsertDTO():New()
	oRoleBadge:cendDate					:= cDataDem+cTime
	oRoleBadge:cinitialDate	 			:= cDataAdm+cTime
	oRoleBadge:cregistry				:= AllTrim(SRA->RA_MAT)
	oRoleBadge:cbadgeNumber				:= ""
	oRoleBadge:cfilial					:= SRA->RA_FILIAL
	If lIntCracha .And. !Empty(SRA->RA_CRACHA)
		oRoleBadge:cbadgeNumber			:= alltrim(SRA->RA_CRACHA)
	EndIf
		If !lTsa
		oRoleBadge:croleType            := If( SRA->RA_CATFUNC == "A",'2','1')
	Else
		oRoleBadge:croleType            := If( SRA->RA_CATFUNC == "A",2,0)
	EndIf
	oRoleBadge:ctakerUnitExternalKey 	:= AllTrim(WSTSAEmpresa(1))
	oRoleBadge:cuserExternalKey			:= AllTrim(cEmpAnt+SRA->RA_FILIAL+SRA->RA_MAT)
	oWSSrvCnt:oWSuserRoleBadgeInsertDTO	:= oRoleBadge

	If !( lRet := oWSSrvCnt:insertUserRoleBadge(oWSSrvCnt:oWSuserRoleBadgeInsertDTO) )
		bBloco	:= { || oWSSrvCnt:insertUserRoleBadge(oWSSrvCnt:oWSuserRoleBadgeInsertDTO) }
		If !( lRet := fValidRet( bBloco ) )
			// Avalia retorno da execucao do metodo
			aServices[1] := "UserRoleBadge"
			aServices[3] := "UserIntegrationServiceBeanService_userRoleBadgeInsertDTO"
			aServices[4] := "insertUserRoleBadge"
	
			lRet := oObjRep:WSLogSendWS(aServices, oWSSrvCnt:oWSuserRoleBadgeInsertDTO,,lRet)
			
		EndIf
	EndIf

ElseIf nOption == 12	//12-insertUserCostCenter

	oCostCenter:= UserIntegrationServiceBeanService_userCostCenterInsertDTO():New()
	oCostCenter:cendDate						:= cDataDem+cTime
	oCostCenter:cinitialDate 					:= cDataAdm+cTime
	oCostCenter:ccostCenterExternalKey			:= AllTrim(cEmpAnt+CTT->CTT_FILIAL+CTT->CTT_CUSTO)
	oCostCenter:cuserExternalKey				:= AllTrim(cEmpAnt+SRA->RA_FILIAL+SRA->RA_MAT)
	oWSSrvCnt:oWSuserCostCenterInsertDTO		:= oCostCenter
	
	If !( lRet := oWSSrvCnt:insertUserCostCenter(oWSSrvCnt:oWSuserCostCenterInsertDTO) )
		bBloco	:= { || oWSSrvCnt:insertUserCostCenter(oWSSrvCnt:oWSuserCostCenterInsertDTO) }
		If !( lRet := fValidRet( bBloco ) )
			// Avalia retorno da execucao do metodo
			aServices[1] := "UserCostCenter"
			aServices[3] := "UserIntegrationServiceBeanService_userCostCenterInsertDTO"
			aServices[4] := "insertUserCostCenter"
	
			lRet := oObjRep:WSLogSendWS(aServices, oWSSrvCnt:oWSuserCostCenterInsertDTO,,lRet)
			
		EndIf
	EndIf

ElseIf nOption == 13	//13-insertUserAllocationUnit

	oUserAllocation := UserIntegrationServiceBeanService_userAllocationUnitInsertDTO():New()
	oUserAllocation:cendDate					:= cDataDem+cTime
	oUserAllocation:callocationUnitExternalKey	:= AllTrim(WSTSAEmpresa(1))
	oUserAllocation:cinitialDate 				:= cDataAdm+cTime
	oUserAllocation:cuserExternalKey			:= AllTrim(cEmpAnt+SRA->RA_FILIAL+SRA->RA_MAT)
	oWSSrvCnt:oWSuserAllocationUnitInsertDTO	:= oUserAllocation
	
	If !( lRet := oWSSrvCnt:insertUserAllocationUnit(oWSSrvCnt:oWSuserAllocationUnitInsertDTO) )
		bBloco	:= { || oWSSrvCnt:insertUserAllocationUnit(oWSSrvCnt:oWSuserAllocationUnitInsertDTO) }
		If !( lRet := fValidRet( bBloco ) )	
			// Avalia retorno da execucao do metodo
			aServices[1] := "UserAllocationUnit"
			aServices[3] := "UserIntegrationServiceBeanService_userAllocationUnitInsertDTO"
			aServices[4] := "insertUserAllocationUnit"
	
			lRet := oObjRep:WSLogSendWS(aServices, oWSSrvCnt:oWSuserAllocationUnitInsertDTO,,lRet)
			
		EndIf
	EndIf
	
ElseIf nOption == 14	//14-removeUserCostCenter

	oRemoveCostCenter:= UserIntegrationServiceBeanService_userCostCenterInsertDTO():New()
	oRemoveCostCenter:cinitialDate 				:= cDataIni +cTime
	oRemoveCostCenter:ccostCenterExternalKey	:= cKeyCCOld
	oRemoveCostCenter:cuserExternalKey			:= cUserOld
	oWSSrvCnt:oWSuserCostCenterInsertDTO		:= oRemoveCostCenter

	If !( lRet := oWSSrvCnt:removeUserCostCenter(oWSSrvCnt:oWSuserCostCenterInsertDTO) )
		bBloco	:= { || oWSSrvCnt:removeUserCostCenter(oWSSrvCnt:oWSuserCostCenterInsertDTO) }
		If !( lRet := fValidRet( bBloco ) )
			// Avalia retorno da execucao do metodo
			aServices [1] := "RemoveUserCostCenter"
			aServices [3] := "UserIntegrationServiceBeanService_userCostCenterInsertDTO"
			aServices [4] := "removeUserCostCenter"
			lRet := oObjRep:WSLogSendWS(aServices, oWSSrvCnt:oWSuserCostCenterInsertDTO,,lRet,.T.)
			
		EndIf	
	EndIf	

ElseIf nOption == 15	//15-removeUserAllocationUnit
	oRemoveDepartment:= UserIntegrationServiceBeanService_userAllocationUnitInsertDTO():New()
	oRemoveDepartment:cinitialDate 					:= cDataIni+cTime
	oRemoveDepartment:callocationUnitExternalKey	:= Alltrim(cKeyDptOld)
	oRemoveDepartment:cuserExternalKey				:= cUserOld
	oWSSrvCnt:oWSuserAllocationUnitInsertDTO		:= oRemoveDepartment

	If !( lRet := oWSSrvCnt:removeUserAllocationUnit(oWSSrvCnt:oWSuserAllocationUnitInsertDTO) )
		bBloco	:= { || oWSSrvCnt:removeuserAllocationUnit(oWSSrvCnt:oWSuserAllocationUnitInsertDTO) }
		If !( lRet := fValidRet( bBloco ) )
			// Avalia retorno da execucao do metodo
			aServices [1] := "RemoveUserAllocationUnit"
			aServices [3] := "UserIntegrationServiceBeanService_userAllocationUnitInsertDTO"
			aServices [4] := "removeUserAllocationUnit"
			lRet := oObjRep:WSLogSendWS(aServices, oWSSrvCnt:oWSuserAllocationUnitInsertDTO,,lRet,.T.)	
		EndIf	
	EndIf

Endif

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} WSReadRHEXP

@author		Aldo Marini
@since		15/06/2011
@version	1.0
@return		NIL
@obs		Analisa as informacoes a serem enviadas para Web Services aplicativo TSA
/*/
//-------------------------------------------------------------------
Method WSReadRHExp( cAlias, nType ) class PTSREPOBJ
Local nA		:= 0
Local lTsa := SUPERGETMV("MV_TSAINT",,.F., SRA->RA_FILIAL)
Default cAlias	:= Alias()
Default nType	:= 1	// 1-Antes das alteracoes, 2-Depois das alteracoes

// Zera os campos do array para adicionar as tabelas especificas
If nType == 1
	::aReadFields	:= {}

	// Campos cadastro de Funcionarios - WebService Pessoa Fisica e Usuarios
	If cAlias == "SRA"
	
		If ( cPaisLoc == "BRA")
	
			::aReadFields	:= { { "RA_ENDEREC"	,  SRA->RA_ENDEREC	, "" } ,;
								 { "RA_COMPLEM" ,  SRA->RA_COMPLEM	, "" } ,;
								 { "RA_MUNICIP" ,  SRA->RA_MUNICIP	, "" } ,;
								 { "RA_NACIONA" ,  SRA->RA_NACIONA	, "" } ,;
								 { "RA_EMAIL" 	,  SRA->RA_EMAIL	, "" } ,;
								 { "RA_MAT" 	,  SRA->RA_MAT		, "" } ,;
								 { "RA_CIC" 	,  SRA->RA_CIC		, "" } ,;
								 { "RA_RG" 		,  SRA->RA_RG		, "" } ,;
								 { "RA_DTRGEXP" ,  SRA->RA_DTRGEXP	, "" } ,;
								 { "RA_RGEXP" 	,  SRA->RA_RGEXP	, "" } ,;
								 { "RA_RGUF" 	,  SRA->RA_RGUF		, "" } ,;
								 { "RA_NOME" 	,  SRA->RA_NOME		, "" } ,;
								 { "RA_BAIRRO"	,  SRA->RA_BAIRRO	, "" } ,;
								 { "RA_TELEFON" ,  SRA->RA_TELEFON	, "" } ,;
								 { "RA_ESTADO"	,  SRA->RA_ESTADO	, "" } ,;
								 { "RA_CEP" 	,  SRA->RA_CEP 		, "" } ,;
								 { "RA_ADMISSA"	,  SRA->RA_ADMISSA	, "" } ,;
								 { "RA_DEMISSA"	,  SRA->RA_DEMISSA	, "" } ,;
								 { "RA_SITFOLH"	,  SRA->RA_SITFOLH	, "" } ,;
								 { "RA_TNOTRAB"	,  SRA->RA_TNOTRAB	, "" } ,;
								 { "RA_REGRA"	,  SRA->RA_REGRA	, "" } ,;
								 { "RA_CODFUNC"	,  SRA->RA_CODFUNC	, "" } ,;
								 { "RA_PIS"		,  SRA->RA_PIS		, "" } ,;
								 { "RA_CRACHA"	,  SRA->RA_CRACHA	, "" } ,;
								 { "RA_BITMAP"	,  SRA->RA_BITMAP	, "" }}
								 
								 If !lTsa
								 	aAdd( { "RA_NASC"	,  SRA->RA_NASC		, "" } )
								 	aAdd( { "RA_SEXO"	,  SRA->RA_SEXO		, "" } )
								 EndIf
		Else

			::aReadFields	:= { { "RA_ENDEREC"	,  SRA->RA_ENDEREC	, "" } ,;
								 { "RA_COMPLEM" ,  SRA->RA_COMPLEM	, "" } ,;
								 { "RA_MUNICIP" ,  SRA->RA_MUNICIP	, "" } ,;
								 { "RA_NACIONA" ,  SRA->RA_NACIONA	, "" } ,;
								 { "RA_EMAIL" 	,  SRA->RA_EMAIL	, "" } ,;
								 { "RA_MAT" 	,  SRA->RA_MAT		, "" } ,;
								 { "RA_CIC" 	,  SRA->RA_CIC		, "" } ,;
								 { "RA_RG" 		,  SRA->RA_RG		, "" } ,;
								 { "RA_RGEXP" 	,  SRA->RA_RGEXP	, "" } ,;
								 { "RA_RGUF" 	,  SRA->RA_RGUF		, "" } ,;
								 { "RA_NOME" 	,  SRA->RA_NOME		, "" } ,;
								 { "RA_BAIRRO"	,  SRA->RA_BAIRRO	, "" } ,;
								 { "RA_TELEFON" ,  SRA->RA_TELEFON	, "" } ,;
								 { "RA_ESTADO"	,  SRA->RA_ESTADO	, "" } ,;
								 { "RA_CEP" 	,  SRA->RA_CEP 		, "" } ,;
								 { "RA_ADMISSA"	,  SRA->RA_ADMISSA	, "" } ,;
								 { "RA_DEMISSA"	,  SRA->RA_DEMISSA	, "" } ,;
								 { "RA_SITFOLH"	,  SRA->RA_SITFOLH	, "" } ,;
								 { "RA_TNOTRAB"	,  SRA->RA_TNOTRAB	, "" } ,;
								 { "RA_REGRA"	,  SRA->RA_REGRA	, "" } ,;
								 { "RA_CODFUNC"	,  SRA->RA_CODFUNC	, "" } ,;
								 { "RA_PIS"		,  SRA->RA_PIS		, "" } ,;
								 { "RA_CRACHA"	,  SRA->RA_CRACHA	, "" } ,;
								 { "RA_BITMAP"	,  SRA->RA_BITMAP	, "" }}

								 If !lTsa
								 	aAdd( { "RA_NASC"	,  SRA->RA_NASC		, "" } )
								 	aAdd( { "RA_SEXO"	,  SRA->RA_SEXO		, "" } )
								 EndIf
		
		EndIf
	
	// Campos cadastro de Turno de Trabalho - WebService Turno e Escala
	ElseIf cAlias == "SR6"
		::aReadFields	:= { { "R6_DESC" ,  SR6->R6_DESC , "" } ,;
							 { "R6_TURNO",  SR6->R6_TURNO , "" }}
	
	// Campos cadastro de Sindicatos - WebService Pessoa Juridica 
	ElseIf cAlias == "RCE"
		::aReadFields	:= { { "RCE_ENDER"	,  RCE->RCE_ENDER 	, "" } ,;
							 { "RCE_NUMER"	,  RCE->RCE_NUMER 	, "" } ,;
							 { "RCE_COMPLE"	,  RCE->RCE_COMPLE 	, "" } ,;
							 { "RCE_MUNIC"	,  RCE->RCE_MUNIC 	, "" } ,;
							 { "RCE_DESCRI"	,  RCE->RCE_DESCRI 	, "" } ,;
							 { "RCE_EMAIL"	,  RCE->RCE_EMAIL 	, "" } ,;
							 { "RCE_CODIGO"	,  RCE->RCE_CODIGO 	, "" } ,;
							 { "RCE_CGC"	,  RCE->RCE_CGC 	, "" } ,;
							 { "RCE_BAIRRO"	,  RCE->RCE_BAIRRO 	, "" } ,;
							 { "RCE_FONE"	,  RCE->RCE_FONE 	, "" } ,;
							 { "RCE_DDD"	,  RCE->RCE_DDD 	, "" } ,;
							 { "RCE_UF"		,  RCE->RCE_UF 		, "" } ,;
							 { "RCE_CEP"	,  RCE->RCE_CEP		, "" } }

	// Campos cadastro de Regras de Afastamento - WebService Usuario
	ElseIf cAlias == "SPA"
		::aReadFields	:= { { "PA_INMOVEL"	,  SPA->PA_INMOVEL 	, "" } }

	Endif
// Apos alteracoes
Else

	If Len(::aReadFields) > 0
		For nA := 1 to Len(::aReadFields)
			::aReadFields [ nA, 3 ] := (cAlias)->(FieldGet(FieldPos(::aReadFields [ nA, 1 ])))
		Next  
	Endif
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} WSChkRHEXP

@author		Aldo Marini
@since		15/06/2011
@version	1.0
@return		NIL
@obs		Valida alteracoes para gravacao do log de exportacao para Web Services aplicativo TSA
/*/
//-------------------------------------------------------------------
Method WSChkRHExp( cAlias, lJob, cField ) class PTSREPOBJ
Local lRet		:= .F.
Local nA		:= 0
Local nPos		:= 0

Default cAlias	:= Alias()
Default lJob	:= .F.
Default cField	:= ""

If !lJob

	If !Empty(cField)
		If (nPos := aScan( ::aReadFields , { |x| x[1] == UPPER(AllTrim(cField)) } ) ) > 0
			If ::aReadFields [ nPos, 2 ] <> ::aReadFields [ nPos, 3 ]
				lRet := .T.
			Endif
		Endif
	Else
		// Campos cadastro de Escalas/Tabela de Horario Padrao - WebService Turno/Escalas
		If cAlias $ "SPJ|SR6"  
			// Qualquer alteracao realizada no cadastro de Tabela de Horario padrao, tabela SPJ devera ser enviado novamente
			// todos os registros devido ao controle dos intevalos e entradas/saidas da tabela
			lRet	:= .T.
		Endif
		
		If Len(::aReadFields) > 0
			For nA := 1 to Len(::aReadFields)
				If ::aReadFields [ nA, 2 ] <> ::aReadFields [ nA, 3 ]
					lRet := .T.
					Exit
				Endif
			Next  
		Endif

	Endif

Else
	lRet := .T.
Endif

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} WSUpdRHEXP

@author		Aldo Marini
@since		15/06/2011
@version	1.1
@return		NIL
@obs		Grava o log de exportacao para Web Services aplicativo TSA
@History 13/07/2016, Cícero Alves, Adicionada a tabela RCM - Situações de afastamento
/*/
//-------------------------------------------------------------------
Method WSUpdRHExp( cAlias, lClear ) class PTSREPOBJ
Local nA		:= 0
Local nPos		:= 0
Local aCampos	:= {}
Local cDataExp	:= SubStr(DTOS(Date()),7,2)+SubStr(DTOS(Date()),5,2)+SubStr(DTOS(Date()),3,2)
Local lTsaDep	:= If( SQB->(ColumnPos('QB_RHEXP'))>0, SuperGetMv("MV_TSADEP", NIL ,.F. ),.F. )

Default lClear	:= .F.
Default cAlias	:= Alias()

aCampos := { {"SRA", "RA_RHEXP" },;	// Cadastro de Funcionários/ Autônomos
			 {"CTT", "CTT_RHEXP"},;	// Cadastro de Centro de Custos
			 {"RCE", "RCE_RHEXP"},;	// Cadastro de Sindicatos
			 {"SR6", "R6_RHEXP" },;	// Cadastro de Turnos de Trabalho
			 {"SR8", "R8_RHEXP" },;	// Cadastro de Afastamentos
			 {"SRJ", "RJ_RHEXP" },;	// Cadastro de Funções
			 {"SRG", "RG_RHEXP" },;	// Cabeçalho de Férias
			 {"SRH", "RH_RHEXP" },;	// Cabeçalho de Rescisão
			 {"SPA", "PA_RHEXP" },;	// Cadastro de Regras de Apontamentos
			 {"SP2", "P2_RHEXP" },;	// Cadastro de Exceções por Período
			 {"SP3", "P3_RHEXP" },;	// Cadastro de Feriados
			 {"SPE", "PE_RHEXP" },;	// Cadastro de Crachás Provisório
			 {"SPF", "PF_RHEXP" },;	// Transferência de Turno
			 {"RCM", "RCM_RHEXP"},;	// Situacao de afastamento
			 {"SPJ", "PJ_RHEXP" }}	// Tabela de Horário Padrão
If lTsaDep
	aAdd(aCampos, {"SQB","QB_RHEXP"  })	// Tabela de Departamento
EndIf

If (nPos := aScan( aCampos , { |x| x[1] == cAlias } ) ) > 0

	Begin Transaction
		RecLock(cAlias, .F.)
			( cAlias )->( FieldPut( FieldPos ( aCampos [ nPos, 2 ] ) , If( lClear , " ", cDataExp ) ) )
		MsUnLock()
	End Transaction

Endif

If cAlias == "SR6"

	// Escala
	If SPJ->(dbSeek( SR6->R6_FILIAL + SR6->R6_TURNO ))

		Begin Transaction

		While SPJ->(!Eof()) .And. SR6->R6_FILIAL + SR6->R6_TURNO == SPJ->PJ_FILIAL + SPJ->PJ_TURNO
			If (nPos := aScan( aCampos , { |x| x[1] == "SPJ" } ) ) > 0

				RecLock("SPJ", .F.)
					( "SPJ" )->( FieldPut( FieldPos ( aCampos [ nPos, 2 ] ) , cDataExp ) )
				MsUnLock()
			Endif
			SPJ->(dbSkip())
		Enddo

		End Transaction

	Endif
	
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} WSTnoScale

@author		Aldo Marini
@since		01/07/2011
@version	1.0
@return		NIL
@obs		Carrega a tabela de horario padrao para exportacao Web Services aplicativo TSA
@obs 		A integracao com TSA devera ser enviado apenas um registro do tipo Jornada

/*/
//-------------------------------------------------------------------
Method WSTnoScale( cKeyShiftWork, ckeyWeek, cDayType ) class PTSREPOBJ
Local aScale		:= {}
Local aScalePair	:= {}
Local aScaleHora	:= {}
Local cEntrada		:= ""
Local cSaida		:= ""
Local aDiaSem 		:= {"Domingo", "Segunda-Feira", "Terça-Feira","Quarta-Feira","Quinta-Feira","Sexta-Feira", "Sábado"}
Local nCountSeq		:= 0
Local cSemana		:= ""
Local aShiftScale	:= {}
Local aScaleAux		:= {}
Local nCt			:= 0
Local nCt1			:= 0
Local nCt1Scale     := 0
Local nI			:= 0
Local nX			:= 0
Local nTipoDia		:= 0
Local nDiaSemana	:= 0
Local cShiftExternal:= ""
Local lAddDia		:= .F.
Local lTsa

Default cKeyShiftWork 	:= ( SR6->R6_FILIAL + SR6->R6_TURNO )
Default cKeyWeek		:= ""
Default cDayType		:= ""

SPJ->(dbSetOrder(1))

//+----------------------------------------------------------------------------------------------------------------------------------------------+
//|Tipo     |Entrada  |Saida    |PJ_ENTRA1|PJ_SAIDA1|PJ_ENTRA2|PJ_SAIDA2|PJ_ENTRA3|PJ_SAIDA3|PJ_ENTRA4|PJ_SAIDA4|PJ_INTERV1|PJ_INTERV2|PJ_INTERV3|
//+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+----------+----------+----------+
//|1a.Jorn  |PJ_ENTRA1|PJ_SAIDA1|Maior    |Maior    |Zero	  |Zero     |Zero     |Zero     |Zero     |Zero     |Indiferent|Indiferent|Indiferent|
//|2a.Jorn  |PJ_ENTRA1|PJ_SAIDA2|Maior    |Maior    |Maior    |Maior    |Zero     |Zero     |Zero     |Zero     |Indiferent|Indiferent|Indiferent|
//|3a.Jorn  |PJ_ENTRA1|PJ_SAIDA3|Maior    |Maior    |Maior    |Maior    |Maior    |Maior    |Zero     |Zero     |Indiferent|Indiferent|Indiferent|
//|4a.Jorn  |PJ_ENTRA1|PJ_SAIDA4|Maior    |Maior    |Maior    |Maior    |Maior    |Maior    |Maior    |Maior    |Indiferent|Indiferent|Indiferent|
//|Intervalo|PJ_SAIDA1|PJ_ENTRA2|Indiferen|Maior    |Maior    |Indiferen|Indiferen|Indiferen|Indiferen|Indiferen|	Sim    |Nao	      |Nao       |
//|Intervalo|PJ_SAIDA2|PJ_ENTRA3|Indiferen|Indiferen|Indiferen|Maior    |Maior    |Indiferen|Indiferen|Indiferen|	Nao    |Sim	      |Nao       |
//|Intervalo|PJ_SAIDA3|PJ_ENTRA4|Indiferen|Indiferen|Indiferen|Indiferen|Indiferen|Maior    |Maior    |Indiferen|	Nao    |Nao	      |Sim       |
//+----------------------------------------------------------------------------------------------------------------------------------------------+


WsdlSaveXml (::WsdlSave) // utilizado para gerar XML de envio e recebimento do client(somente para debug)

// Verifica se houve a passagem do codigo da semana da Tabela de Horario Padrao e adiciona na chave
If !Empty(cKeyWeek)
	cKeyShiftWork += cKeyWeek
Endif

// Verifica se houve a passagem do codigo da semana da Tabela de Horario Padrao e adiciona na chave
If !Empty(cDayType)
	cKeyShiftWork += cDayType
Endif


// Posiciona a chave do Turno na Tabela de Horario Padrão
If SPJ->(dbSeek( cKeyShiftWork ))

	nCountSeq 	:= 0
	cSemana		:= ""
	
	lTsa := SUPERGETMV("MV_TSAINT",,.T., SPJ->PJ_FILIAL)
		
	While SPJ->(!Eof()) .And. cKeyShiftWork == SPJ->PJ_FILIAL + SPJ->PJ_TURNO + If( !Empty(ckeyWeek), SPJ->PJ_SEMANA , "" ) + If( !Empty(cDayType), SPJ->PJ_DIA , "" )

		aScalePair := {}

		// Totaliza o numero de semanas 
		If cSemana <> SPJ->PJ_SEMANA
			nCountSeq ++
			cSemana := SPJ->PJ_SEMANA
		Endif
		
		// Verifica se os valores do horarios de entrada e saida estao preenchidos
		If SPJ->( PJ_ENTRA1+PJ_SAIDA1+PJ_ENTRA2+PJ_SAIDA2+PJ_ENTRA3+PJ_SAIDA3+PJ_ENTRA4+PJ_SAIDA4 ) > 0

			// Verificacao da 1a.Jornada
			If SPJ->( PJ_ENTRA1 + PJ_SAIDA1 ) > 0 .And. SPJ->( PJ_ENTRA2 + PJ_SAIDA2 + PJ_ENTRA3 + PJ_SAIDA3 + PJ_ENTRA4 + PJ_SAIDA4 ) == 0
				cEntrada	:= "1990-01-01T"+StrTran(StrZero(SPJ->PJ_ENTRA1,5,2),".",":")+":00"	
				cSaida		:= "1990-01-01T"+StrTran(StrZero(SPJ->PJ_SAIDA1,5,2),".",":")+":00"

				// Pares da Escala
				If !Empty(cEntrada) .And. !Empty(cSaida)
					aAdd(aScalePair, { cSaida ,;																// cendTime
			                           cEntrada ,;     															// cinitialTime
			                           0,;     																	// npairType
			                           AllTrim(cEmpAnt+SPJ->PJ_FILIAL+SPJ->PJ_TURNO+SPJ->PJ_SEMANA+SPJ->PJ_DIA) })     // cscaleExternalKey
				Endif
				
			// Verificacao da 1a.Jornada e 2a.Jornada
			ElseIf SPJ->( PJ_ENTRA1 + PJ_SAIDA1 ) > 0 .And. SPJ->( PJ_ENTRA2 + PJ_SAIDA2 ) > 0 .And. SPJ->( PJ_ENTRA3 + PJ_SAIDA3 + PJ_ENTRA4 + PJ_SAIDA4 ) == 0
				cEntrada	:= "1990-01-01T"+StrTran(StrZero(SPJ->PJ_ENTRA1,5,2),".",":")+":00"	
				cSaida		:= "1990-01-01T"+StrTran(StrZero(SPJ->PJ_SAIDA2,5,2),".",":")+":00"

				// Pares da Escala
				If !Empty(cEntrada) .And. !Empty(cSaida)
					aAdd(aScalePair, { cSaida ,;																// cendTime
			                           cEntrada ,;     															// cinitialTime
			                           0,;     																	// npairType
			                           AllTrim(cEmpAnt+SPJ->PJ_FILIAL+SPJ->PJ_TURNO+SPJ->PJ_SEMANA+SPJ->PJ_DIA) })     // cscaleExternalKey
				Endif
				
			// Verificacao da 1a.Jornada, 2a.Jornada e 3a.Jornada
			ElseIf SPJ->( PJ_ENTRA1 + PJ_SAIDA1 ) > 0 .And. SPJ->( PJ_ENTRA2 + PJ_SAIDA2 ) > 0 .And. SPJ->( PJ_ENTRA3 + PJ_SAIDA3 ) > 0 .And. SPJ->( PJ_ENTRA4 + PJ_SAIDA4 ) == 0
				cEntrada	:= "1990-01-01T"+StrTran(StrZero(SPJ->PJ_ENTRA1,5,2),".",":")+":00"	
				cSaida		:= "1990-01-01T"+StrTran(StrZero(SPJ->PJ_SAIDA3,5,2),".",":")+":00"

				// Pares da Escala
				If !Empty(cEntrada) .And. !Empty(cSaida)
					aAdd(aScalePair, { cSaida ,;																// cendTime
			                           cEntrada ,;     															// cinitialTime
			                           0,;     																	// npairType
			                           cEmpAnt+SPJ->PJ_FILIAL+SPJ->PJ_TURNO+SPJ->PJ_SEMANA+SPJ->PJ_DIA })     // cscaleExternalKey
				Endif
				
			// Verificacao da 1a.Jornada, 2a.Jornada, 3a.Jornada e 4a.Jornada
			ElseIf SPJ->( PJ_ENTRA1 + PJ_SAIDA1 ) > 0 .And. SPJ->( PJ_ENTRA2 + PJ_SAIDA2 ) > 0 .And. SPJ->( PJ_ENTRA3 + PJ_SAIDA3 ) > 0 .And. SPJ->( PJ_ENTRA4 + PJ_SAIDA4 ) > 0
				cEntrada	:= "1990-01-01T"+StrTran(StrZero(SPJ->PJ_ENTRA1,5,2),".",":")+":00"	
				cSaida		:= "1990-01-01T"+StrTran(StrZero(SPJ->PJ_SAIDA4,5,2),".",":")+":00"

				// Pares da Escala
				If !Empty(cEntrada) .And. !Empty(cSaida)
					aAdd(aScalePair, { cSaida ,;																// cendTime
			                           cEntrada ,;     															// cinitialTime
			                           0,;     																	// npairType
			                           cEmpAnt+SPJ->PJ_FILIAL+SPJ->PJ_TURNO+SPJ->PJ_SEMANA+SPJ->PJ_DIA })     // cscaleExternalKey
				Endif
				
			Endif


			// Horario do intervalo
			If SPJ->PJ_INTERV1  == "S" .And. SPJ->( PJ_ENTRA2 + PJ_SAIDA1 ) > 0

				cEntrada	:= "1990-01-01T"+StrTran(StrZero(SPJ->PJ_SAIDA1,5,2),".",":")+":00"
				cSaida		:= "1990-01-01T"+StrTran(StrZero(SPJ->PJ_ENTRA2,5,2),".",":")+":00"	

				// Pares da Escala
				If !Empty(cEntrada) .And. !Empty(cSaida)
					aAdd(aScalePair, { cSaida ,;																// cendTime
			                           cEntrada ,;     															// cinitialTime
			                           1,;     																	// npairType
			                           cEmpAnt+SPJ->PJ_FILIAL+SPJ->PJ_TURNO+SPJ->PJ_SEMANA+SPJ->PJ_DIA })     // cscaleExternalKey
				Endif
			ElseIf SPJ->PJ_INTERV2  == "S" .And. SPJ->( PJ_ENTRA3 + PJ_SAIDA2 ) > 0

				cEntrada	:= "1990-01-01T"+StrTran(StrZero(SPJ->PJ_SAIDA2,5,2),".",":")+":00"
				cSaida		:= "1990-01-01T"+StrTran(StrZero(SPJ->PJ_ENTRA3,5,2),".",":")+":00"	

				// Pares da Escala
				If !Empty(cEntrada) .And. !Empty(cSaida)
					aAdd(aScalePair, { cSaida ,;																// cendTime
			                           cEntrada ,;     															// cinitialTime
			                           1,;     																	// npairType
			                           cEmpAnt+SPJ->PJ_FILIAL+SPJ->PJ_TURNO+SPJ->PJ_SEMANA+SPJ->PJ_DIA })     // cscaleExternalKey
				Endif
			
			ElseIf SPJ->PJ_INTERV3  == "S" .And. SPJ->( PJ_ENTRA4 + PJ_SAIDA3 ) > 0

				cEntrada	:= "1990-01-01T"+StrTran(StrZero(SPJ->PJ_SAIDA3,5,2),".",":")+":00"
				cSaida		:= "1990-01-01T"+StrTran(StrZero(SPJ->PJ_ENTRA4,5,2),".",":")+":00"	

				// Pares da Escala
				If !Empty(cEntrada) .And. !Empty(cSaida)
					aAdd(aScalePair, { cSaida ,;																// cendTime
			                           cEntrada ,;     															// cinitialTime
			                           1,;     																	// npairType
			                           cEmpAnt+SPJ->PJ_FILIAL+SPJ->PJ_TURNO+SPJ->PJ_SEMANA+SPJ->PJ_DIA })     // cscaleExternalKey
				Endif
			
			Endif
				
		Endif

		nTipoDia	:= If(SPJ->PJ_TPDIA == "S",0,If(SPJ->PJ_TPDIA == "C",1,If(SPJ->PJ_TPDIA == "D",2,2)))
		nDiaSemana	:= If(Val(SPJ->PJ_DIA)>1,Val(SPJ->PJ_DIA)-1,7)

		If !lTsa
			If Empty( aScale )
				lAddDia := .T.
			Else
				For nI := 1 To Len( aScale )
					aScaleHora	:= aClone( aScale[nI,4] )
					aScaleAux	:= aClone( aScalePair )

					For nX := 1 To Len( aScaleHora )
						aDel( aScaleHora[nX] , Len( aScaleHora[nX] ) )
						aSize( aScaleHora[nX] , Len( aScaleHora[nX] ) - 1 )
					Next

					For nX := 1 To Len(aScaleAux)
						aDel( aScaleAux[nX] , Len( aScaleAux[nX] ) )
						aSize( aScaleAux[nX], Len( aScaleAux[nX] ) - 1 )
					Next
					
					If nTipoDia == aScale[nI,1] .And. ArrayCompare(aScaleHora,aScaleAux) .And. aScale[nI,8] + 1 == nDiaSemana
						aScale[nI,8] := nDiaSemana
						aScale[nI,2] := AllTrim(SR6->R6_DESC) + " " + aDiaSem [ aScale[nI,6] + 1 ] + " à " + aDiaSem [ Val(SPJ->PJ_DIA) ]
						lAddDia := .F.
					Else
						lAddDia := .T.
					EndIf
				Next
			EndIf
		EndIf

		If lAddDia .Or. lTsa
			aAdd( aScale , { nTipoDia ,; 													// ndayType
							AllTrim(SR6->R6_DESC) + " " + aDiaSem [ Val(SPJ->PJ_DIA) ],;	// cdescription
							Val(SPJ->PJ_SEMANA),; 											// ninitialSequence
							aScalePair ,;													// Array contendo os pares de escalas
							SPJ->(Recno()),;												// Recno da Tabela de Horario Padrao
							nDiaSemana,;													// Sequencia da semana iniciando pela 2a.Feira
							cEmpAnt+SPJ->PJ_FILIAL+SPJ->PJ_TURNO+SPJ->PJ_SEMANA,; 			// cexternalKey Turno
							nDiaSemana})													// nendSequence
		EndIf

		lAddDia	:= .F.

		SPJ->(dbSkip())
	Enddo
	
Endif

aScale := aSort( aScale ,,, {|x,y| Str(x[3])+Str(x[6]) < Str(y[3])+Str(y[6]) } )

// Cria um array com todas as semanas e todas as sequencias
If Len(aScale) > 0
	For nCt := 1 to nCountSeq
	
		aScaleAux := {}
		cShiftExternal := ""
	 	If ( nCt1 := aScan( aScale , { |x| Str(x[3]) == Str(nCt) } ) ) > 0
	
	        cShiftExternal := aScale[nCt1,7]
			nCt1Scale := 1
	
			While nCt1Scale <= Len(aScale) .And. cShiftExternal == aScale[nCt1,7]
				aAdd( aScaleAux , { aScale[nCt1,1],;
								aScale[nCt1,2],;
								nCt1Scale,;
								aScale[nCt1,4],;
								aScale[nCt1,5],;
								aScale[nCt1,6],;
								aScale[nCt1,8],;
								cShiftExternal+StrZero(nCt1,3)})
				nCt1++
				If nCt1 > Len(aScale)
					nCt1 := 1
				Endif
	
				nCt1Scale++
	
			Enddo
	
		Endif
		
		aAdd(aShiftScale, { aScaleAux, cShiftExternal } )
	
	Next
Endif

Return aShiftScale



//-------------------------------------------------------------------
/*/{Protheus.doc} WSDayNotWorked

@author		Aldo Marini
@since		04/07/2011
@version	1.0
@return		NIL
@obs		Envia as informacoes de Funcionarios para Web Services aplicativo TSA
/*/
//-------------------------------------------------------------------
Method WSDayNotWorked( nOption , aCompany , aOldDados ) class PTSREPOBJ
Local cServTSA			:= GetMv("MV_TSASERV",.F.,"localhost:8080")
Local oWSSrvCnt			:= WSDayNotWorkedIntegrationServiceBeanService():New()
Local lRet				:= .F.
Local cDayNot			:= ""
Local cDayNotTo			:= ""
Local aShifTWork		:= {}
Local nRecnoSM0			:= SM0->(Recno())
Local aArea				:= GetArea()
Local nA				:= 0
Local nB				:= 0
Local cKeyExternal 		:= ""
Local aDaysException	:= {}
Local dP2_DATA			:= SP2->P2_DATA
Local dP2_DATAATE		:= SP2->P2_DATAATE
Local cP2_TURNO			:= SP2->P2_TURNO
Local cP2_CC			:= SP2->P2_CC
Local cP2_TRABA			:= SP2->P2_TRABA
Local lMsBlQl			:=	SR6->(FieldPos( "R6_MSBLQL" )) > 0
Local cChave			:= ""
Local aServices	:= {"DayNotWorked",;
					"WSDayNotWorkedIntegrationServiceBeanService",;
					"DayNotWorkedIntegrationServiceBeanService_DayNotWorkedDTO",;
					"insertOrUpdateIncrement",;
					"" }
Local bBloco			:= { || .T. }
Local lGravou			:= 	.F.					
 
DEFAULT nOption 		:= 1
DEFAULT aCompany		:= {}
DEFAULT aOldDados		:= {}

cServTSA		+= If(Right(cServTSA,1) <> "/","/","")
oWSSrvCnt:_URL 	:= cServTSA+"DayNotWorkedIntegrationServiceBean"
aServices[5]	:= cServTSA+"DayNotWorkedIntegrationServiceBean"

WsdlSaveXml (::WsdlSave) // utilizado para gerar XML de envio e recebimento do client(somente para debug)

If nOption == 1 .Or. nOption == 2

	// Ajusta o formato do campo data para o envio do WebService
	If SP3->P3_FIXO == "N"
		cDayNot	:= DTOS(SP3->P3_DATA)
	Else
		cDayNot	:= StrZero(Year(Date()),4) + SP3->P3_MESDIA
	Endif
	cDayNot := SubStr(cDayNot,1,4)+"-"+SubStr(cDayNot,5,2)+"-"+SubStr(cDayNot,7,2)
	
	// Carrega as filiais da empresa corrente para o envio dos feriados para todas as filiais
	// quando a tabela SP3 (Feriados) for compartilhada
	If Len(aCompany) == 0
		If Empty(xFilial("SP3"))
			dbSelectArea("SM0")
			dbSetOrder(1)
			If SM0->( dbSeek( cEmpAnt ) )
				While SM0->(!Eof()) .And. SM0->M0_CODIGO == cEmpAnt
					aAdd(aCompany,SM0->M0_CODFIL)
					SM0->(dbSkip())	
				Enddo
			Endif
		Else
			// Carrega apenas a filial corrente
			aAdd(aCompany,SM0->M0_CODFIL)
		Endif
	Endif
	
	// Carrega a tabela de Turnos de Trabalho para o envio dos feriados para todos os turnos
	dbSelectArea("SPJ")
	dbSetOrder(1)
	
	/* Descricao da variavel lGravou - Este trecho foi ajustado para considerar a seguinte situacao: A tabela SPJ contem os horarios da 
	tabela de horario padrao. Os feriados devem ser gerados por turno, sendo assim, ao enviar os feriados do turno 001 (por ex.) e 
	o restante dos registros referem-se aos hora'rios, devem ser ignoradas, permitindo que o webservice seja executado apenas 
	na 'quebra' do turno.	
	*/
	
	// Caso o cadastro de Turnos seja compartilhado carrega todos os codigos para envio ao WS
	If Empty( xFilial ("SPJ") )
		If SPJ->( dbSeek( xFilial("SPJ") ))
			While SPJ->(!Eof())
				If cChave	!= SPJ->PJ_FILIAL + SPJ->PJ_TURNO + SPJ->PJ_SEMANA
					cChave	:= SPJ->PJ_FILIAL + SPJ->PJ_TURNO + SPJ->PJ_SEMANA
					If lMsBlQl 
						If ( fNotBlock(SPJ->PJ_FILIAL , SPJ->PJ_TURNO) ) 
							aAdd(aShiftWork,{ SPJ->PJ_FILIAL , SPJ->PJ_TURNO+SPJ->PJ_SEMANA } )
						EndIf
					Else	
						aAdd(aShiftWork,{ SPJ->PJ_FILIAL , SPJ->PJ_TURNO+SPJ->PJ_SEMANA } )
					EndIf
				EndIf
				SPJ->(dbSkip())				
			Enddo
		Endif
	Else
		For nA := 1 to Len(aCompany)
			If SPJ->( dbSeek( xFilial( "SPJ" , SubStr( aCompany [ nA ], 1, FwGetTamFilial ) ) ) )				
				While SPJ->(!Eof()) .And. SPJ->PJ_FILIAL == xFilial( "SPJ" , SubStr( aCompany [ nA ], 1, FwGetTamFilial ) )
					If cChave	!= SPJ->PJ_FILIAL + SPJ->PJ_TURNO + SPJ->PJ_SEMANA
						cChave	:= SPJ->PJ_FILIAL + SPJ->PJ_TURNO + SPJ->PJ_SEMANA
						If lMsBlQl
							If ( fNotBlock(SPJ->PJ_FILIAL , SPJ->PJ_TURNO) )
								aAdd(aShiftWork,{ SPJ->PJ_FILIAL , SPJ->PJ_TURNO+SPJ->PJ_SEMANA } )
							EndIf 
						Else	
							aAdd(aShiftWork,{ SPJ->PJ_FILIAL , SPJ->PJ_TURNO+SPJ->PJ_SEMANA } )
						EndIf
					EndIf
					SPJ->(dbSkip())					
				Enddo
			Endif
		Next
	Endif
	
	// Inclusão ou Alteracao
	If 	Len(aCompany) > 0 .And. Len(aShiftWork) > 0
	
		oSrvCnt					:= DayNotWorkedIntegrationServiceBeanService_DayNotWorkedDTO():New()
		oSrvCnt:cdayNotWorked	:= cDayNot
		oSrvCnt:cdescription	:= SP3->P3_DESC
		oSrvCnt:cexternalKey	:= "F"+cEmpAnt+SP3->P3_FILIAL+DTOS(SP3->P3_DATA)
		oSrvCnt:lrecurrent		:= If( SP3->P3_FIXO == "S",.T.,.F.)
	
		// Realiza a selecao dos registros das filias da empresa logada
		For nA := 1 to Len(aCompany)
	
			// Realiza a selecao dos registros dos turnos de trabalho
			For nB := 1 to Len(aShiftWork)
	
				oLocationDay:= DayNotWorkedIntegrationServiceBeanService_locationDayNotWorkedDTO():New()
				oLocationDay:cdayNotWorkedExternalKey  := "F"+cEmpAnt+SP3->P3_FILIAL+DTOS(SP3->P3_DATA)
				oLocationDay:clocationExternalKey      := "E" + cEmpAnt + aCompany[ nA ]	 				// "E"+SM0->M0_CODIGO+SM0->M0_CODFIL
				oLocationDay:cshiftWorkExternalKey     := cEmpAnt + aShiftWork [ nB , 1 ] + aShiftWork [ nB , 2 ] 
				aAdd(oSrvCnt:oWSlocationDayNotWorkedDTOCol,oLocationDay)
	
			Next
		Next
					
		oWSSrvCnt:oWSDayNotWorkedDTO := oSrvCnt
			
		If nOption == 1 .Or. nOption == 2
			If !( lRet := oWSSrvCnt:insertOrUpdateIncrement(oWSSrvCnt:oWSDayNotWorkedDTO) )
				bBloco	:= { || oWSSrvCnt:insertOrUpdateIncrement(oWSSrvCnt:oWSDayNotWorkedDTO) }
				If !( lRet := fValidRet( bBloco ) )
					// Avalia retorno da execucao do metodo
					lRet := oObjRep:WSLogSendWS(aServices, oWSSrvCnt:oWSDayNotWorkedDTO,,lRet)
				EndIf	
			EndIf	
		Endif
				
	Endif
	
ElseIf nOption == 3
	
	// Exclusao
	If !Empty(SP3->P3_RHEXP)
		If !( lRet := oWSSrvCnt:remove("F"+cEmpAnt+SP3->P3_FILIAL+DTOS(SP3->P3_DATA)) )
			bBloco	:= { || oWSSrvCnt:remove("F"+cEmpAnt+SP3->P3_FILIAL+DTOS(SP3->P3_DATA)) }
			If !( lRet := fValidRet( bBloco ) )
				// Avalia retorno da execucao do metodo
				aServices[1] := "RemoveDayNotWorked"
				aServices[4] := "remove"
	
				lRet := oObjRep:WSLogSendWS(aServices, oWSSrvCnt,,lRet,.T.,"F"+cEmpAnt+SP3->P3_FILIAL+DTOS(SP3->P3_DATA))
	
			EndIf	
		EndIf	

	Endif
	
ElseIf nOption == 4 .Or. nOption == 5

	If Len(aOldDados) > 0
		dP2_DATA	:= aOldDados[1]
		dP2_DATAATE	:= aOldDados[2]
		cP2_TURNO	:= aOldDados[3]
		cP2_CC		:= aOldDados[4]
		cP2_TRABA	:= aOldDados[5]
	Endif	

	// Carrega a tabela de Turnos de Trabalho para o envio dos feriados para todos os turnos
	dbSelectArea("SR6")
	dbSetOrder(1)

	dbSelectArea("SPJ")
	dbSetOrder(1)
		
	// Verifica se a excecao eh por Turno para carregar todo o cadastro de turno como excecao/dia nao trabalhado
	If Empty(cP2_TURNO)

		// Caso o cadastro de Turnos seja compartilhado carrega todos os codigos para envio ao WS
		If Empty( xFilial ("SPJ") )
			If SPJ->( dbSeek( xFilial("SPJ") ))
				While SPJ->(!Eof())
					aAdd(aShiftWork,{ SPJ->PJ_FILIAL , SPJ->PJ_TURNO+SPJ->PJ_SEMANA } )
					SPJ->(dbSkip())	
				Enddo
			Endif
		Else
			If SPJ->( dbSeek( xFilial( "SPJ" , SM0->M0_CODFIL ) ) )
				While SPJ->(!Eof()) .And. xFilial( "SPJ" , SPJ->PJ_FILIAL ) == xFilial( "SPJ" , SM0->M0_CODFIL )
					aAdd(aShiftWork,{ SPJ->PJ_FILIAL , SPJ->PJ_TURNO+SPJ->PJ_SEMANA } )
					SPJ->(dbSkip())	
				Enddo
			Endif
		Endif

	Else
		If SPJ->(dbSeek( xFilial( "SPJ" , SM0->M0_CODFIL) + cP2_TURNO ))
			aAdd(aShiftWork,{ xFilial( "SPJ" , SM0->M0_CODFIL),  cP2_TURNO + SPJ->PJ_SEMANA } )
		Endif
	Endif
	
	// Inclusão ou Alteracao
	If 	Len(aShiftWork) > 0
	
		// Verifica se a data foi preenchia e se eh maior para compor os dias 
		If !Empty(dP2_DATAATE) .And. dP2_DATAATE > dP2_DATA

			For nA := 0 to (dP2_DATAATE-dP2_DATA)

				// Ajusta o formato do campo data para o envio do WebService
				cDayNot	:= DTOS( dP2_DATA + nA )
				cDayNot := SubStr(cDayNot,1,4)+"-"+SubStr(cDayNot,5,2)+"-"+SubStr(cDayNot,7,2)

				aAdd(aDaysException, cDayNot )
			Next

		Else
			// Ajusta o formato do campo data para o envio do WebService
			cDayNot	:= DTOS(dP2_DATA)
			cDayNot := SubStr(cDayNot,1,4)+"-"+SubStr(cDayNot,5,2)+"-"+SubStr(cDayNot,7,2)

			aAdd(aDaysException , cDayNot )
		Endif
				

		For nA := 1 to Len( aDaysException )
		
			//  Monta a chave externa do servico 
			cKeyExternal := "E" + cEmpAnt + SP2->P2_FILIAL + aDaysException[ nA ] + StrZero(nA,3)
			If !Empty(dP2_DATAATE)
				cDayNotTo	:= DTOS(dP2_DATAATE)
				cDayNotTo	:= SubStr(cDayNotTo,1,4)+"-"+SubStr(cDayNotTo,5,2)+"-"+SubStr(cDayNotTo,7,2)
				cKeyExternal += "-"+cDayNotTo
			Endif			
			If !Empty(cP2_TURNO)
				cKeyExternal +=	"-"+cP2_TURNO
			Endif
			If !Empty(cP2_CC)
				cKeyExternal +=	"-"+cP2_CC
			Endif

			If nOption == 4
				oSrvCnt					:= DayNotWorkedIntegrationServiceBeanService_DayNotWorkedDTO():New()
				oSrvCnt:cdayNotWorked	:= aDaysException [ nA ]
				oSrvCnt:cdescription	:= SP2->P2_MOTIVO
				oSrvCnt:cexternalKey	:= cKeyExternal
				oSrvCnt:lrecurrent		:= .F.
			
				// Realiza a selecao dos registros dos turnos de trabalho
				For nB := 1 to Len(aShiftWork)
		
					oLocationDay:= DayNotWorkedIntegrationServiceBeanService_locationDayNotWorkedDTO():New()
					oLocationDay:cdayNotWorkedExternalKey  := cKeyExternal
					oLocationDay:clocationExternalKey      := "E"+WSTSAEmpresa(2,SP2->P2_FILIAL)
					oLocationDay:cshiftWorkExternalKey     := cEmpAnt + aShiftWork [ nB , 1 ] + aShiftWork [ nB , 2 ] 
					aAdd(oSrvCnt:oWSlocationDayNotWorkedDTOCol,oLocationDay)
		
				Next
							
				oWSSrvCnt:oWSDayNotWorkedDTO := oSrvCnt
				
				If !( lRet := oWSSrvCnt:insertOrUpdate(oWSSrvCnt:oWSDayNotWorkedDTO) )
					bBloco	:= { || oWSSrvCnt:insertOrUpdate(oWSSrvCnt:oWSDayNotWorkedDTO) }
					If !( lRet := fValidRet( bBloco ) )
						// Avalia retorno da execucao do metodo
						aServices[1] := "DayNotWorkedE"
	
						lRet := oObjRep:WSLogSendWS(aServices, oWSSrvCnt:oWSDayNotWorkedDTO,,lRet)
					EndIf
				EndIf

			Else
				If !Empty(SP2->P2_RHEXP)

					If !( lRet := oWSSrvCnt:remove(cKeyExternal) )
						bBloco	:= { || oWSSrvCnt:remove(cKeyExternal) }
						If !( lRet := fValidRet( bBloco ) )
							// Avalia retorno da execucao do metodo
							aServices[1] := "RemoveDayNotWorkedE"
							aServices[4] := "remove"
	
							lRet := oObjRep:WSLogSendWS(aServices, oWSSrvCnt,,lRet,.T.,cKeyExternal)
	
						EndIf
					EndIf
					
				Endif
			Endif			

		Next
		
	Endif
Endif

SM0->(dbGoTo(nRecnoSM0))
RestArea(aArea)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} WSLocation

@author		Aldo Marini
@since		05/07/2011
@version	1.0
@return		NIL
@obs		Envia as informacoes de Localidade para Web Services aplicativo TSA
/*/
//-------------------------------------------------------------------
Method WSLocation( nOption ) class PTSREPOBJ
Local cServTSA			:= GetMv("MV_TSASERV",.F.,"localhost:8080")
Local oWSSrvCnt			:= WSLocationIntegrationServiceBeanService():New()
Local oSrvCnt			:= LocationIntegrationServiceBeanService_locationDTO():New()
Local lRet				:= .F.
Local bBloco			:= { || .T. }
DEFAULT nOption 		:= 1

WsdlSaveXml (::WsdlSave) // utilizado para gerar XML de envio e recebimento do client(somente para debug)

cServTSA	+= If(Right(cServTSA,1) <> "/","/","")
oWSSrvCnt:_URL := cServTSA+"LocationIntegrationServiceBean"

If nOption == 1 .Or. nOption == 2

	oSrvCnt:ccity			:= SM0->M0_CIDCOB
	oSrvCnt:ccitycode		:= Left(AllTrim(SM0->M0_CODMUN),5)

	oSrvCnt:ccountry		:= cPaisLoc		// Campo não existe
	oSrvCnt:ccountrycode	:= cPaisLoc		// Campo não existe

	oSrvCnt:cexternalKey	:= "E"+SM0->M0_CODIGO+SM0->M0_CODFIL

	oSrvCnt:cstate			:= SM0->M0_ESTCOB
	oSrvCnt:cstatecode		:= SM0->M0_ESTCOB
	
	oWSSrvCnt:oWSLocationDTO := oSrvCnt
	If !( lRet := oWSSrvCnt:insertOrUpdate(oSrvCnt) )
		bBloco	:= { || oWSSrvCnt:insertOrUpdate(oSrvCnt) }
		If !( lRet := fValidRet( bBloco ) )
			// Avalia retorno da execucao do metodo
			lRet := oObjRep:WSLogSendWS({"Location"}, oWSSrvCnt:oWSLocationDTO,,lRet)
		EndIf	
	EndIf	
Else
// Exclusao
	lRet := oWSSrvCnt:remove("E"+SM0->M0_CODIGO+SM0->M0_CODFIL)
	bBloco	:= { || oWSSrvCnt:remove("E"+SM0->M0_CODIGO+SM0->M0_CODFIL) }
	lRet := fValidRet( bBloco )
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} WSPositionLevel

@author		Aldo Marini
@since		15/06/2011
@version	1.0
@return		NIL
@obs		Envia as informacoes de Funcoes de Funcionarios para Web Services aplicativo TSA
/*/
//-------------------------------------------------------------------
Method WSPositionLevel( nOption ) class PTSREPOBJ
Local cServTSA	:= GetMv("MV_TSASERV",.F.,"http://localhost:8080")
Local oWSSrvCnt	:= WSPositionLevelIntegrationServiceBeanService():New()
Local oSrvCnt	:= PositionLevelIntegrationServiceBeanService_PositionLevelDTO():New()
Local lRet		:= .F.
Local aServices	:= {"PositionLevel",;
					"WSPositionLevelIntegrationServiceBeanService",;
					"PositionLevelIntegrationServiceBeanService_PositionLevelDTO",;
					"InsertOrUpdate",;
					"" }
Local bBloco	:= { || .T. }					
DEFAULT nOption := 1

cServTSA		+= If(Right(cServTSA,1) <> "/","/","")
oWSSrvCnt:_URL 	:= cServTSA+"PositionLevelIntegrationServiceBean"
aServices[5]	:= cServTSA+"PositionLevelIntegrationServiceBean"

WsdlSaveXml (::WsdlSave) // utilizado para gerar XML de envio e recebimento do client(somente para debug)

// Inclusão ou Alteracao

If nOption == 1 .Or. nOption == 2

	oSrvCnt:cdescription 			:= SRJ->RJ_DESC
	oSrvCnt:cexternalKey			:= cEmpAnt+SRJ->RJ_FILIAL+SRJ->RJ_FUNCAO

	oWSSrvCnt:oWSPositionLevelDTO := oSrvCnt
	If !( lRet := oWSSrvCnt:insertOrUpdate(oSrvCnt) )
		bBloco	:= { || oWSSrvCnt:insertOrUpdate(oSrvCnt) }
		If !( lRet := fValidRet( bBloco ) )
			// Avalia retorno da execucao do metodo
			lRet := oObjRep:WSLogSendWS(aServices, oWSSrvCnt:oWSPositionLevelDTO,,lRet)
		EndIf	
	EndIf	

Else
	// Exclusao
	If !Empty(SRJ->RJ_RHEXP)	

		If !( lRet := oWSSrvCnt:remove(cEmpAnt+SRJ->RJ_FILIAL+SRJ->RJ_FUNCAO) )
			bBloco	:= { || oWSSrvCnt:remove(cEmpAnt+SRJ->RJ_FILIAL+SRJ->RJ_FUNCAO) }						 
			If !( lRet := fValidRet( bBloco ) )
				// Avalia retorno da execucao do metodo
				aServices [1] := "RemovePositionLevel"
				aServices [4] := "Remove"
				lRet := oObjRep:WSLogSendWS(aServices, oWSSrvCnt ,,lRet,.T.,cEmpAnt+SRJ->RJ_FILIAL+SRJ->RJ_FUNCAO)
	
			Endif
		Endif

	EndIf	
	
Endif

 Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} WSCostCenter

@author		Aldo Marini
@since		15/06/2011
@version	1.0
@return		NIL
@obs		Envia as informacoes de Centro de Custo para Web Services aplicativo TSA
/*/
//-------------------------------------------------------------------
Method WSCostCenter( nOption ) class PTSREPOBJ
Local cServTSA	:= GetMv("MV_TSASERV",.F.,"http://localhost:8080")
Local oWSSrvCnt	:= WSCostCenterIntegrationServiceBeanService():New()
Local oSrvCnt	:= CostCenterIntegrationServiceBeanService_CostCenterDTO():New()
Local lRet		:= .F.
Local aServices	:= {"CostCenter",;
					"WSCostCenterIntegrationServiceBeanService",;
					"CostCenterIntegrationServiceBeanService_CostCenterDTO",;
					"InsertOrUpdate",;
					"" }
Local bBloco	:= { || .T. }

DEFAULT nOption := 1

cServTSA		+= If(Right(cServTSA,1) <> "/","/","")
oWSSrvCnt:_URL 	:= cServTSA+"CostCenterIntegrationServiceBean"
aServices[5]	:= cServTSA+"CostCenterIntegrationServiceBean"

WsdlSaveXml (::WsdlSave) // utilizado para gerar XML de envio e recebimento do client(somente para debug)

// Inclusão ou Alteracao

If nOption == 1 .Or. nOption == 2

	oSrvCnt:cdescription 	   := CTT->CTT_DESC01
	oSrvCnt:cexternalKey	   := cEmpAnt+CTT->CTT_FILIAL+CTT->CTT_CUSTO

	oWSSrvCnt:oWSCostCenterDTO := oSrvCnt
	If !( lRet := oWSSrvCnt:insertOrUpdate(oSrvCnt) )
		bBloco	:= { || oWSSrvCnt:insertOrUpdate(oSrvCnt) }
		If !( lRet := fValidRet( bBloco ) )
			// Avalia retorno da execucao do metodo
			lRet := oObjRep:WSLogSendWS(aServices, oWSSrvCnt:oWSCostCenterDTO,,lRet)	
		EndIf
	EndIf

Else
	// Exclusao
	If !Empty(CTT->CTT_RHEXP)
		If !( lRet := oWSSrvCnt:remove(cEmpAnt+CTT->CTT_FILIAL+CTT->CTT_CUSTO) )
			bBloco	:= { || oWSSrvCnt:remove(cEmpAnt+CTT->CTT_FILIAL+CTT->CTT_CUSTO) }
			If !( lRet := fValidRet( bBloco ) )			
				// Avalia retorno da execucao do metodo
				aServices [1] := "RemoveCostCenter"
				aServices [4] := "Remove"
				lRet := oObjRep:WSLogSendWS(aServices, oWSSrvCnt ,,lRet,.T.,cEmpAnt+CTT->CTT_FILIAL+CTT->CTT_CUSTO)
			EndIf
		EndIf
			
	Endif

Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} WSException

@author		Aldo Marini
@since		04/07/2011
@version	1.0
@return		NIL
@obs		Envia as informacoes de Excecoes para Web Services aplicativo TSA
/*/
//-------------------------------------------------------------------
Method WSException( nOption , aRegistry , aOldDados ) class PTSREPOBJ
Local cServTSA			:= GetMv("MV_TSASERV",.F.,"localhost:8080")
Local oWSSrvCnt			:= WSExceptionIntegrationServiceBeanService():New()
Local lRet				:= .F.
Local cDayExce			:= ""
Local cDayExceTo		:= ""
Local aArea				:= GetArea()
Local nA				:= 0
Local nB				:= 0
Local cKeyExternal 		:= ""
Local bBloco			:= { || .T. }
Local aPairDtoCol 		:= {}
Local lTsaBDNT 			:= ExistBlock( "PTSABDNT" )   
Local dP2_DATA			:= SP2->P2_DATA
Local dP2_DATAATE		:= SP2->P2_DATAATE
Local cP2_TURNO			:= SP2->P2_TURNO
Local cP2_CC			:= SP2->P2_CC
Local cP2_TRABA			:= SP2->P2_TRABA
Local lTabPad			:= SP2->P2_HERDHOR == "S"
Local aServices	:= {"Exception",;
					"WSExceptionIntegrationServiceBeanService",;
					"ExceptionIntegrationServiceBeanService_ExceptionDTO",;
					"InsertOrUpdate",;
					"" }
Local cTime				:= "T00:00:00"
DEFAULT nOption 		:= 1
DEFAULT aRegistry		:= {}
DEFAULT aOldDados		:= {}

cServTSA		+= If(Right(cServTSA,1) <> "/","/","")
oWSSrvCnt:_URL 	:= cServTSA+"ExceptionIntegrationServiceBean"
aServices[5]	:= cServTSA+"ExceptionIntegrationServiceBean"

If nOption == 3 .And. Len(aOldDados) > 0
	dP2_DATA	:= aOldDados[1]
	dP2_DATAATE	:= aOldDados[2]
	cP2_TURNO	:= aOldDados[3]
	cP2_CC		:= aOldDados[4]
	cP2_TRABA	:= aOldDados[5]
Endif	
WsdlSaveXml (::WsdlSave) // utilizado para gerar XML de envio e recebimento do client(somente para debug)

// Ajusta o formato do campo data para o envio do WebService
cDayExce := DTOS( dP2_DATA )
cDayExce := SubStr(cDayExce,1,4)+"-"+SubStr(cDayExce,5,2)+"-"+SubStr(cDayExce,7,2)

// Verifica se a data final esta preenchida, caso nao esteja considera a data inicial como final
If !Empty(dP2_DATAATE)
	cDayExceTo	:= DTOS(dP2_DATAATE)
Else
	cDayExceTo	:= "20491231"	// Assume ultima data quando vier em branco
Endif			

cDayExceTo	:= SubStr(cDayExceTo,1,4)+"-"+SubStr(cDayExceTo,5,2)+"-"+SubStr(cDayExceTo,7,2)

// Atualiza o array a aPairDtoCol com todas as oonfiguracoes conforme cadastro de Tabela de Horario Padrao
aPairDtoCol :=  oObjREP:WSExpPairScale()
	
If Len(aPairDtoCol) > 0  .OR. lTabPad 

	For nB:= 1 to Len(aRegistry)
	
		//  Monta a chave externa do servico 
		cKeyExternal := cEmpAnt + SP2->P2_FILIAL + aRegistry[ nB ] + cDayExce + cDayExceTo 
		If !Empty(cP2_TURNO)
			cKeyExternal +=	"-"+cP2_TURNO
		Endif
		If !Empty(cP2_CC)
			cKeyExternal +=	"-"+cP2_CC
		Endif
		
		// Tira os espacos da variavel
		cKeyExternal := AllTrim(cKeyExternal)

		If nOption == 1 .Or. nOption == 2
	
			oSrvCnt					:= ExceptionIntegrationServiceBeanService_ExceptionDTO():New()
			oSrvCnt:ndirection		:= 2
			oSrvCnt:cenddate		:= cDayExceTo+cTime
			oSrvCnt:nexceptionType	:= 0
			oSrvCnt:cexternalKey	:= cKeyExternal
			oSrvCnt:cinitialDate	:= cDayExce+cTime
			oSrvCnt:cobservation	:= SP2->P2_MOTIVO
			
		
			If SP2->P2_TRABA == "S"
				oSrvCnt:nOrigin	:=	1	
			ElseIf SP2->P2_TRABA = "N" .Or. SP2->P2_TRABA = "D"
				oSrvCnt:nOrigin	:=	3
				/*/
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Ponto de Entrada para retorno do bloqueio do acesso          ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
				IF ( lTsaBDNT )
					oSrvCnt:nexceptionType := ExecBlock("PTSABDNT",.F.,.F. )
				EndIF                                                                                  

			Endif
			oSrvCnt:cuserExternalKey:= 	AllTrim( cEmpAnt + SP2->P2_FILIAL + aRegistry[ nB ] )
			
			If lTabPad
				aPairDtoCol := oObjREP:WSExpPairScale(2, aRegistry[ nB ])
			EndIf
			
			// Realiza a selecao dos registros dos turnos de trabalho
			For nA := 1 to Len(aPairDtoCol)
		
				oPairDTOCol:= ExceptionIntegrationServiceBeanService_exceptionPairDTO():New()
				oPairDTOCol:cendTime             := aPairDtoCol [ nA , 1 ]
				oPairDTOCol:cinitialTime         := aPairDtoCol [ nA , 2 ]
				oPairDTOCol:npairType            := aPairDtoCol [ nA , 3 ]
				aAdd(oSrvCnt:oWSExceptionPairDTOCol,oPairDTOCol)
		
			Next
							
			aAdd(oWSSrvCnt:oWSexceptionDTO, oSrvCnt)

		Else
	
			If !Empty(SP2->P2_RHEXP)
				If !( lRet := oWSSrvCnt:remove(cKeyExternal) )			
					bBloco	:= { || oWSSrvCnt:remove(cKeyExternal) }
					If !( lRet := fValidRet( bBloco ) )	
						// Avalia retorno da execucao do metodo
						aServices[1] := "RemoveException"
						aServices[4] := "remove"
						lRet := oObjRep:WSLogSendWS(aServices, oWSSrvCnt,,lRet,.T.,cKeyExternal)
					EndIf
				EndIf
		
			Endif
			
		Endif				
	
	Next

	If nOption == 1 .Or. nOption == 2

		If !( lRet := oWSSrvCnt:insertOrUpdate(oWSSrvCnt:oWSexceptionDTO) )
			bBloco	:= { || oWSSrvCnt:insertOrUpdate(oWSSrvCnt:oWSexceptionDTO) }
			If !( lRet := fValidRet( bBloco ) )
				// Avalia retorno da execucao do metodo
				aServices[1] := "Exception"
				aServices[4] := "insertOrUpdate"
				lRet := oObjRep:WSLogSendWS(aServices, oWSSrvCnt:oWSExceptionDTO,,lRet)
			EndIf
		EndIf

	Endif

Endif			

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} WSExpPairScale

@author		Aldo Marini
@since		07/07/2011
@version	1.0
@return		NIL
@obs		Carrega as informacoes das Excecoes para exportacao Web Services aplicativo TSA

/*/
//-------------------------------------------------------------------
Method WSExpPairScale( nOption, cMat) class PTSREPOBJ
Local aScalePair	:= {}
Local aShiftWork	:= {}
Local cEntrada		:= ""
Local cSaida		:= ""
Local nA			:= 0
Local nB			:= 0
Local nC			:= 0

Default nOption 	:= 1

WsdlSaveXml (::WsdlSave) // utilizado para gerar XML de envio e recebimento do client(somente para debug)

// Prever se o conteudo do campo P2_HERDHOR estiver com "S" para selecionar os horarios da tabela de horario padrao


//+----------------------------------------------------------------------------------------------------------------------------------------------+
//|Tipo     |Entrada  |Saida    |PJ_ENTRA1|PJ_SAIDA1|PJ_ENTRA2|PJ_SAIDA2|PJ_ENTRA3|PJ_SAIDA3|PJ_ENTRA4|PJ_SAIDA4|PJ_INTERV1|PJ_INTERV2|PJ_INTERV3|
//+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+----------+----------+----------+
//|1a.Jorn  |P2_ENTRA1|P2_SAIDA1|Maior    |Maior    |Zero	  |Zero     |Zero     |Zero     |Zero     |Zero     |Indiferent|Indiferent|Indiferent|
//|2a.Jorn  |P2_ENTRA1|P2_SAIDA2|Maior    |Maior    |Maior    |Maior    |Zero     |Zero     |Zero     |Zero     |Indiferent|Indiferent|Indiferent|
//|3a.Jorn  |P2_ENTRA1|P2_SAIDA3|Maior    |Maior    |Maior    |Maior    |Maior    |Maior    |Zero     |Zero     |Indiferent|Indiferent|Indiferent|
//|4a.Jorn  |P2_ENTRA1|P2_SAIDA4|Maior    |Maior    |Maior    |Maior    |Maior    |Maior    |Maior    |Maior    |Indiferent|Indiferent|Indiferent|
//|Intervalo|P2_SAIDA1|P2_ENTRA2|Indiferen|Maior    |Maior    |Indiferen|Indiferen|Indiferen|Indiferen|Indiferen|	Sim    |Nao	      |Nao       |
//|Intervalo|P2_SAIDA2|P2_ENTRA3|Indiferen|Indiferen|Indiferen|Maior    |Maior    |Indiferen|Indiferen|Indiferen|	Nao    |Sim	      |Nao       |
//|Intervalo|P2_SAIDA3|P2_ENTRA4|Indiferen|Indiferen|Indiferen|Indiferen|Indiferen|Maior    |Maior    |Indiferen|	Nao    |Nao	      |Sim       |
//+----------------------------------------------------------------------------------------------------------------------------------------------+

// Verifica se os valores do horarios de entrada e saida estao preenchidos
If SP2->( P2_ENTRA1+P2_SAIDA1+P2_ENTRA2+P2_SAIDA2+P2_ENTRA3+P2_SAIDA3+P2_ENTRA4+P2_SAIDA4 ) > 0

	// Verificacao da 1a.Jornada
	If SP2->( P2_ENTRA1 + P2_SAIDA1 ) > 0 .And. SP2->( P2_ENTRA2 + P2_SAIDA2 + P2_ENTRA3 + P2_SAIDA3 + P2_ENTRA4 + P2_SAIDA4 ) == 0
		cEntrada	:= "1990-01-01T"+StrTran(StrZero(SP2->P2_ENTRA1,5,2),".",":")+":00"	
		cSaida		:= "1990-01-01T"+StrTran(StrZero(SP2->P2_SAIDA1,5,2),".",":")+":00"

		// Pares da Escala
		If !Empty(cEntrada) .And. !Empty(cSaida)
			aAdd(aScalePair, { cSaida ,;																// cendTime
	                           cEntrada ,;     															// cinitialTime
	                           0})     																	// npairType
		Endif
		
	// Verificacao da 1a.Jornada e 2a.Jornada
	ElseIf SP2->( P2_ENTRA1 + P2_SAIDA1 ) > 0 .And. SP2->( P2_ENTRA2 + P2_SAIDA2 ) > 0 .And. SP2->( P2_ENTRA3 + P2_SAIDA3 + P2_ENTRA4 + P2_SAIDA4 ) == 0
		cEntrada	:= "1990-01-01T"+StrTran(StrZero(SP2->P2_ENTRA1,5,2),".",":")+":00"	
		cSaida		:= "1990-01-01T"+StrTran(StrZero(SP2->P2_SAIDA2,5,2),".",":")+":00"

		// Pares da Escala
		If !Empty(cEntrada) .And. !Empty(cSaida)
			aAdd(aScalePair, { cSaida ,;																// cendTime
	                           cEntrada ,;     															// cinitialTime
	                           0})     																	// npairType
		Endif
		
	// Verificacao da 1a.Jornada, 2a.Jornada e 3a.Jornada
	ElseIf SP2->( P2_ENTRA1 + P2_SAIDA1 ) > 0 .And. SP2->( P2_ENTRA2 + P2_SAIDA2 ) > 0 .And. SP2->( P2_ENTRA3 + P2_SAIDA3 ) > 0 .And. SP2->( P2_ENTRA4 + P2_SAIDA4 ) == 0
		cEntrada	:= "1990-01-01T"+StrTran(StrZero(SP2->P2_ENTRA1,5,2),".",":")+":00"	
		cSaida		:= "1990-01-01T"+StrTran(StrZero(SP2->P2_SAIDA3,5,2),".",":")+":00"

		// Pares da Escala
		If !Empty(cEntrada) .And. !Empty(cSaida)
			aAdd(aScalePair, { cSaida ,;																// cendTime
	                           cEntrada ,;     															// cinitialTime
	                           0})     																	// npairType
		Endif
		
	// Verificacao da 1a.Jornada, 2a.Jornada, 3a.Jornada e 4a.Jornada
	ElseIf SP2->( P2_ENTRA1 + P2_SAIDA1 ) > 0 .And. SP2->( P2_ENTRA2 + P2_SAIDA2 ) > 0 .And. SP2->( P2_ENTRA3 + P2_SAIDA3 ) > 0 .And. SP2->( P2_ENTRA4 + P2_SAIDA4 ) > 0
		cEntrada	:= "1990-01-01T"+StrTran(StrZero(SP2->P2_ENTRA1,5,2),".",":")+":00"	
		cSaida		:= "1990-01-01T"+StrTran(StrZero(SP2->P2_SAIDA4,5,2),".",":")+":00"

		// Pares da Escala
		If !Empty(cEntrada) .And. !Empty(cSaida)
			aAdd(aScalePair, { cSaida ,;																// cendTime
	                           cEntrada ,;     															// cinitialTime
	                           0})     																	// npairType
		Endif
		
	Endif


	// Horario do intervalo
	If SP2->P2_INTERV1  == "S" .And. SP2->( P2_ENTRA2 + P2_SAIDA1 ) > 0

		cEntrada	:= "1990-01-01T"+StrTran(StrZero(SP2->P2_SAIDA1,5,2),".",":")+":00"
		cSaida		:= "1990-01-01T"+StrTran(StrZero(SP2->P2_ENTRA2,5,2),".",":")+":00"	

		// Pares da Escala
		If !Empty(cEntrada) .And. !Empty(cSaida)
			aAdd(aScalePair, { cSaida ,;																// cendTime
	                           cEntrada ,;     															// cinitialTime
	                           1})     																	// npairType
		Endif

	ElseIf SP2->P2_INTERV2  == "S" .And. SP2->( P2_ENTRA3 + P2_SAIDA2 ) > 0

		cEntrada	:= "1990-01-01T"+StrTran(StrZero(SP2->P2_SAIDA2,5,2),".",":")+":00"
		cSaida		:= "1990-01-01T"+StrTran(StrZero(SP2->P2_ENTRA3,5,2),".",":")+":00"	

		// Pares da Escala
		If !Empty(cEntrada) .And. !Empty(cSaida)
			aAdd(aScalePair, { cSaida ,;																// cendTime
	                           cEntrada ,;     															// cinitialTime
	                           1})     																	// npairType
		Endif
	
	ElseIf SP2->P2_INTERV3  == "S" .And. SP2->( P2_ENTRA4 + P2_SAIDA3 ) > 0

		cEntrada	:= "1990-01-01T"+StrTran(StrZero(SP2->P2_SAIDA3,5,2),".",":")+":00"
		cSaida		:= "1990-01-01T"+StrTran(StrZero(SP2->P2_ENTRA4,5,2),".",":")+":00"	

		// Pares da Escala
		If !Empty(cEntrada) .And. !Empty(cSaida)
			aAdd(aScalePair, { cSaida ,;																// cendTime
	                           cEntrada ,;     															// cinitialTime
	                           1})     																	// npairType
		Endif
	
	Endif

ElseIf nOption == 2
	SRA->( dbSetOrder(1) )
	SRA->( dbSeek( xFilial("SRA") + cMat ) )
	SR6->( dbSeek( xFilial("SR6") + SRA->RA_TNOTRAB ) )
	aShiftWork :=  oObjREP:WSTnoScale( SR6->R6_FILIAL + SR6->R6_TURNO, SRA->RA_SEQTURN )
	
	Begin Sequence
		For nA := 1 To Len(aShiftWork) 
			For nB := 1 To Len(aShiftWork[nA, 1]) 
				If aShiftWork[nA, 1, nB, 1] == 0
					For nC := 1 To Len(aShiftWork[nA, 1, nB, 4]) 
						aAdd(aScalePair, { aShiftWork[nA, 1, nB, 4, nC, 1] ,;						// cendTime
				                           aShiftWork[nA, 1, nB, 4, nC, 2] ,;     					// cinitialTime
				                           aShiftWork[nA, 1, nB, 4, nC, 3]})						// npairType
					Next nC
					Break
				EndIf
			Next nB
		Next nA
	End Sequence

Endif

Return aScalePair

//-------------------------------------------------------------------
/*/{Protheus.doc} WSAbsenceReason
@author		Aldo Marini
@since		11/07/2011
@version	2.0
@return		NIL
@obs		Envia as informacoes de Excecoes para Web Services aplicativo TSA
@History 13/07/2016, Cícero Alves, Alterada a tabela de busca para RCM, antes utilizava SX5 
/*/
//-------------------------------------------------------------------
Method WSAbsenceReason(nOption, cKeyUnit, cDataIni, cDataFim, cKeyUser, lGPEA240) class PTSREPOBJ
	
	Local cServTSA			:= GetMv("MV_TSASERV", .F., "localhost:8080")
	Local oWSSrvCnt			:= WSAbsenceReasonIntegrationServiceBeanService():New()
	Local lRet				:= .F.
	Local aArea				:= GetArea()
	Local aServices	:= {"AbsenceReason",;
						"WSAbsenceReasonIntegrationServiceBeanService",;
						"AbsenceReasonIntegrationServiceBeanService_AbsenceReasonDTO",;
						"InsertOrUpdate",;
						"" }
	Local bBloco			:= { || .T. }
	Local cTime				:= "T00:00:00"
	DEFAULT nOption 		:= 1
	DEFAULT ckeyUnit		:= AllTrim(SM0->M0_CODIGO + SM0->M0_CODFIL + SM0->M0_FILIAL)
	DEFAULT cDataIni		:= SRA->RA_ADMISSA
	DEFAULT cDataFim		:= SRA->RA_DEMISSA
	DEFAULT cKeyUser		:= AllTrim(cEmpAnt + SRA->RA_FILIAL + SRA->RA_MAT)
	DEFAULT lGPEA240		:= .F.
	
	WsdlSaveXml (::WsdlSave) // utilizado para gerar XML de envio e recebimento do client(somente para debug)
	
	cDataIni := DTOS(cDataIni)
	cDataIni := SubStr(cDataIni, 1, 4) + "-" + SubStr(cDataIni, 5, 2) + "-" + SubStr(cDataIni, 7, 2)
	
	cDataFim := DTOS(cDataFim)
	If !Empty(cDataFim)
		cDataFim := SubStr(cDataFim, 1, 4) + "-" + SubStr(cDataFim, 5, 2) + "-" + SubStr(cDataFim, 7, 2)
	Else
		cDataFim := "2049-12-31"
	Endif
	
	cServTSA		+= If(Right(cServTSA,1) <> "/","/","")
	oWSSrvCnt:_URL 	:= cServTSA + "AbsenceReasonIntegrationServiceBean"
	aServices[5]	:= cServTSA + "AbsenceReasonIntegrationServiceBean"
	
	If nOption == 1 .Or. nOption == 2
	
		oSrvCnt	:= AbsenceReasonIntegrationServiceBeanService_AbsenceReasonDTO():New()
		oSrvCnt:cdescription	:= RCM->RCM_DESCRI
		oSrvCnt:cexternalKey	:= AllTrim(cEmpAnt + RCM->RCM_FILIAL + RCM->RCM_TIPO)
		oSrvCnt:nsituationType	:= If(AllTrim(RCM->RCM_TIPOAF) != "1", 1, 0)
	
		If !Empty(SX5->X5_FILIAL)
			oUnitAbsence := AbsenceReasonIntegrationServiceBeanService_unitAbsenceReasonInsertDTO():New()
	
			oUnitAbsence:cabsenceReasonExternalKey	:= AllTrim(cEmpAnt + RCM->RCM_FILIAL + RCM->RCM_TIPO)
			If Empty(SX5->X5_CHAVE)
				oUnitAbsence:lblockAccess			:= .F.
			Else 
				oUnitAbsence:lblockAccess			:= .T.
			EndIf
			oUnitAbsence:nrestrictedDaysQuantity	:= 0
			oUnitAbsence:cunitExternalKey			:= AllTrim(WSTSAEmpresa(1, RCM->RCM_FILIAL))
	
			aAdd(oSrvCnt:oWSunitAbsenceReasonDTOCol,oUnitAbsence)
		Endif
		
		oWSSrvCnt:oWSabsenceReasonDTO := oSrvCnt
			
		If !( lRet := oWSSrvCnt:insertOrUpdate(oWSSrvCnt:oWSabsenceReasonDTO) )
			bBloco	:= { || oWSSrvCnt:insertOrUpdate(oWSSrvCnt:oWSabsenceReasonDTO) }
			If !( lRet := fValidRet( bBloco ) )
				// Avalia retorno da execucao do metodo
				lRet := oObjRep:WSLogSendWS(aServices, oWSSrvCnt:oWSAbsenceReasonDTO,,lRet)
			EndIf
		EndIf
	ElseIf nOption == 3
	
		If !( lRet := oWSSrvCnt:remove(AllTrim(cEmpAnt + RCM->RCM_FILIAL + RCM->RCM_TIPO)))
			bBloco	:= { || oWSSrvCnt:remove(AllTrim(cEmpAnt + RCM->RCM_FILIAL + RCM->RCM_TIPO)) }
			If !( lRet := fValidRet( bBloco ) )
				// Avalia retorno da execucao do metodo
				aServices[1] := "RemoveAbsenceReason"
				aServices[4] := "remove"
				lRet := oObjRep:WSLogSendWS(aServices, oWSSrvCnt, , lRet, .T., AllTrim(cEmpAnt + RCM->RCM_FILIAL + RCM->RCM_TIPO))
			EndIf
		EndIf
	ElseIf nOption == 4
	
		oSrvCnt := AbsenceReasonIntegrationServiceBeanService_unitAbsenceReasonInsertDTO():New()
	
		oSrvCnt:cabsenceReasonExternalKey		:= AllTrim(cEmpAnt + RCM->RCM_FILIAL + RCM->RCM_TIPO)
	
		oSrvCnt:nrestrictedDaysQuantity			:= 0
		oSrvCnt:cunitExternalKey				:= AllTrim(cKeyUnit)
	
		oWSSrvCnt:oWSunitAbsenceReasonInsertDTO := oSrvCnt
			
		If !( lRet := oWSSrvCnt:insertUnitAbsenceReason(oWSSrvCnt:oWSunitAbsenceReasonInsertDTO) )
			bBloco	:= { || oWSSrvCnt:insertUnitAbsenceReason(oWSSrvCnt:oWSunitAbsenceReasonInsertDTO) }		
			If !( lRet := fValidRet( bBloco ) )
				// Avalia retorno da execucao do metodo
				aServices[1] := "UnitAbsenceReason"
				aServices[3] := "AbsenceReasonIntegrationServiceBeanService_unitAbsenceReasonInsertDTO"
				aServices[4] := "insertUnitAbsenceReason"
				lRet := oObjRep:WSLogSendWS(aServices, oWSSrvCnt:oWSunitAbsenceReasonInsertDTO, , lRet)
			EndIf	
		EndIf	
	ElseIf nOption == 5
	
		oSrvCnt := AbsenceReasonIntegrationServiceBeanService_userAbsenceReasonInsertDTO():New()
		oSrvCnt:cabsenceReasonExternalKey	:= AllTrim(cEmpAnt + RCM->RCM_FILIAL + RCM->RCM_TIPO)
		oSrvCnt:cendDate					:= cDataFim+cTime
		oSrvCnt:cinitialDate				:= cDataIni+cTime
		If !lGPEA240
			oSrvCnt:cuserExternalKey		:= AllTrim(cEmpAnt + SR8->R8_FILIAL + SR8->R8_MAT)
		Else
			oSrvCnt:cuserExternalKey		:= AllTrim(cKeyUser)
		EndIf
	
		oWSSrvCnt:oWSuserAbsenceReasonInsertDTO := oSrvCnt
			
		If !( lRet := oWSSrvCnt:insertUserAbsenceReason(oWSSrvCnt:oWSuserAbsenceReasonInsertDTO) )
			bBloco	:= { || oWSSrvCnt:insertUserAbsenceReason(oWSSrvCnt:oWSuserAbsenceReasonInsertDTO) }
			If !( lRet := fValidRet( bBloco ) )
				// Avalia retorno da execucao do metodo
				aServices[1] := "UserAbsenceReason"
				aServices[3] := "AbsenceReasonIntegrationServiceBeanService_userAbsenceReasonInsertDTO"
				aServices[4] := "insertUserAbsenceReason"
				lRet := oObjRep:WSLogSendWS(aServices, oWSSrvCnt:oWSuserAbsenceReasonInsertDTO, , lRet)	
			EndIf
		EndIf
	
	ElseIf nOption == 6
	
		oSrvCnt := AbsenceReasonIntegrationServiceBeanService_userAbsenceReasonRemoveDTO():New()

		oSrvCnt:cabsenceReasonExternalKey	:= AllTrim(cEmpAnt + RCM->RCM_FILIAL +  RCM->RCM_TIPO)
		oSrvCnt:cuserExternalKey			:= AllTrim(cKeyUser)
		oSrvCnt:cinitialDate	   			:= cDataIni+cTime
	
		oWSSrvCnt:oWSuserAbsenceReasonRemoveDTO := oSrvCnt
			
		If !( lRet := oWSSrvCnt:removeUserAbsenceReason(oWSSrvCnt:oWSuserAbsenceReasonRemoveDTO) )
			bBloco	:= { || oWSSrvCnt:removeUserAbsenceReason(oWSSrvCnt:oWSuserAbsenceReasonRemoveDTO) }
			If !( lRet := fValidRet( bBloco ) )
				// Avalia retorno da execucao do metodo
				aServices[1] := "RemoveUserAbsenceReason"
				aServices[3] := "AbsenceReasonIntegrationServiceBeanService_userAbsenceReasonRemoveDTO"
				aServices[4] := "RemoveUserAbsenceReason"
				lRet := oObjRep:WSLogSendWS(aServices, oWSSrvCnt:oWSuserAbsenceReasonRemoveDTO, , lRet, .T.)
		
			EndIf	
		EndIf	
	ElseIf nOption == 7
	
		oSrvCnt := AbsenceReasonIntegrationServiceBeanService_userAbsenceReasonInsertDTO():New()
	
		If SRA->RA_SITFOLH $ "D,T"
			cDataFim := DTOS(SRA->RA_DEMISSA)
			If !Empty(cDataFim)
				cDataFim := SubStr(cDataFim, 1, 4) + "-" + SubStr(cDataFim, 5, 2) + "-" + SubStr(cDataFim, 7, 2)
			Else
				cDataFim := "2049-12-31"
			Endif
		Else
			If Empty(cDataFim)
				cDataFim := "2049-12-31"
			Endif
		Endif
		
		oSrvCnt:cabsenceReasonExternalKey	:= AllTrim(cEmpAnt + RCM->RCM_FILIAL + RCM->RCM_TIPO)
		oSrvCnt:cendDate					:= cDataFim+cTime
		oSrvCnt:cinitialDate				:= cDataIni+cTime
		oSrvCnt:cuserExternalKey			:= AllTrim(cEmpAnt + SRA->RA_FILIAL + SRA->RA_MAT)
	
		oWSSrvCnt:oWSuserAbsenceReasonInsertDTO := oSrvCnt
			
		If !( lRet := oWSSrvCnt:insertUserAbsenceReason(oWSSrvCnt:oWSuserAbsenceReasonInsertDTO) )
			bBloco	:= { || oWSSrvCnt:insertUserAbsenceReason(oWSSrvCnt:oWSuserAbsenceReasonInsertDTO) }
			If !( lRet := fValidRet( bBloco ) )
				// Avalia retorno da execucao do metodo
				aServices[1] := "UserAbsenceReason"
				aServices[3] := "AbsenceReasonIntegrationServiceBeanService_userAbsenceReasonInsertDTO"
				aServices[4] := "insertUserAbsenceReason"
		
				lRet := oObjRep:WSLogSendWS(aServices, oWSSrvCnt:oWSuserAbsenceReasonInsertDTO,,lRet)	
			EndIf
		EndIf
	
	Endif			
	
	RestArea(aArea)
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} WSLogSendWS

@author		Aldo Marini
@since		16/07/2011
@version	1.0
@return		NIL
@obs		Verifica se o retorno existe err e envia as informacoes de Log de erro por email
/*/
//-------------------------------------------------------------------
Method WSLogSendWS( aService, oObjWs , lJOB , lRet , lSync, cExternalKey ) class PTSREPOBJ
Local cBody 		:= ""
Local cMsgErr		:= ""
Local cMsgRet		:= ""
Local nTypeSend		:= GetMv("MV_TSATLOG",.F.,3)
Local nF 			:= 0

DEFAULT aService	:= {}
DEFAULT lJOB 		:= .F.
DEFAULT lRet 		:= .F.
DEFAULT lSync 		:= .F.
DEFAULT cExternalKey:= ""

If Len(aService) == 0
	Return .F.
Endif

If !lRet
	cMsgErr := GetWSCError() 
Else
	If !lSync 
		If ValType(oObjWs) == "O"
			If (nPos := aScan(::aCodeError, {|x| x[1] == oObjWs:cstatuscode })) > 0
				lRet := ::aCodeError [ nPos , 2 ]
			Endif
		Else
			lRet := .F.	
		Endif
	Endif
Endif  
	

If !lRet
    
    //Verifica se a chamada foi via carga e atualizacao de dados
	If !IsInCallStack("PONM430")
		If ValType(oObjWs) == "O"
			cBody := ::WSLoadMsg(oObjWs)
		Endif
		If !Empty(cMsgErr)
			cBody := cBody + CRLF + cMsgErr
		Endif

		// Envia email caso parametro esteja como 1-email  ou 3-ambos
		If nTypeSend == 1 .Or. nTypeSend == 3 .Or. nTypeSend == 5
			::WSSendMail( aService[1] , cBody)
		Endif

		// Grava o Log em arquivo caso parametro esteja como 2-Arquivo ou 3-ambos
		If nTypeSend == 2 .Or. nTypeSend == 3 .Or. nTypeSend == 5
			::WSSendArq( aService[1] , cBody)
		Endif

	Else
		If (nPos := aScan(::aRetError, {|x| x[1] == aService[1] })) > 0
			cMsgRet := &(::aRetError[nPos,2])
		Else
			cMsgRet := ""
		EndIf	
			
		AAdd(aRetLog,aService[1] +": " +If(ValType(oObjWs)=="0",oObjWs:cstatusDescription,"") +cMsgRet)

		// Grava o Log em arquivo caso parametro esteja como 2-Arquivo ou 3-ambos
		If nTypeSend == 2 .Or. nTypeSend == 3 .Or. nTypeSend == 5

			If ValType(oObjWs) == "O"
				cBody := ::WSLoadMsg(oObjWs)
			Endif
			If !Empty(cMsgErr)
				cBody := cBody + CRLF + cMsgErr
			Endif

			::WSSendArq( aService[1] , cBody)
		Endif

	Endif

	If lSync .And. aScan(::aRetError, {|x| x[1] == aService[1] .And. x[3] == .T. }) > 0
         
		::WSInsertSync(oObjWs,cExternalkey,aService)

	Endif
	
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} WSSendMail

@author		Aldo Marini
@since		16/07/2011
@version	1.0
@return		NIL
@obs		Envia as informacoes de Log de erro por email
/*/
//-------------------------------------------------------------------
Method WSSendMail( cService, cBody ) class PTSREPOBJ
Local cMailTSA		:= AllTrim(GetMv("MV_TSAMAIL",.F.,""))
Local cSubject 		:= "Protheus SIGA"+cModulo+" Integracao TSA X Protheus - " + cService 
DEFAULT cBody 		:= "Inconsistencias WebService "

If Empty(cMailTSA)
	Return
Endif

gpeMail(cSubject,cBody,cMailTSA)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} WSSendArq

@author		Aldo Marini
@since		04/10/2011
@version	1.0
@return		NIL
@obs		Envia as informacoes de Log em arquivo
/*/
//-------------------------------------------------------------------
Method WSSendArq( cService, cBody ) class PTSREPOBJ
Local cDirArqLog	:= Lower(GetMv("MV_TSADARQ",.F.,"\logwsrhtsa\"))
Local cArqLog		:= Lower(CriaTrab(NIL,.F.))
Local nHdl			:= 0

If Right(cDirArqLog,1) <> "\"
	cDirArqLog := cDirArqLog + "\"
EndIf

If !Empty(cArqLog) .And. !Empty(cService) .And. !Empty(cBody)

	If ((nHdl:= FCREATE(cDirArqLog + cArqLog + "_" + Lower(cService)+'.txt' , FC_NORMAL)) == -1)

		// Verifica se existe o diretorio de log
		If ((nHdl:= MakeDir(cDirArqLog)) <> 0)
			Return
		Else
			If ((nHdl:= FCREATE(cDirArqLog + cArqLog + "_" + Lower(cService)+'.txt', FC_NORMAL)) <> -1)
				FWRITE( nHdl, cBody )
				FCLOSE( nHdl )		
			Endif
		EndIf
	Else
		FWRITE( nHdl, cBody )
		FCLOSE( nHdl )		
	EndIf
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} WSLoadMsg

@author		Aldo Marini
@since		16/07/2011
@version	1.0
@return		NIL
@obs		Prepara a mensagem de email conforme as propriedades passadas
/*/
//-------------------------------------------------------------------
Method WSLoadMsg( oObjMail ) class PTSREPOBJ
Local nA 		:= 0
Local nB		:= 0
Local cRetBody	:= ""
Local aArrayTmp := ClassDataArr(oObjMail)

For nA := 1 to Len(aArrayTmp)
	cRetBody += aArrayTmp [ nA , 1 ] + ": "
	If ValType(aArrayTmp [ nA , 2 ]) == "C"
		 cRetBody += aArrayTmp [ nA , 2 ]
	ElseIf ValType(aArrayTmp [ nA , 2 ]) == "D"
		 cRetBody += DTOC(aArrayTmp [ nA , 2 ])
	ElseIf ValType(aArrayTmp [ nA , 2 ]) == "N"
		 cRetBody += Str(aArrayTmp [ nA , 2 ])
	ElseIf ValType(aArrayTmp [ nA , 2 ]) == "L"
		 cRetBody += If(aArrayTmp [ nA , 2 ],".T.",".F.")
	ElseIf ValType(aArrayTmp [ nA , 2 ]) == "A"
		If LEN(aArrayTmp [ nA , 2 ]) > 0
			For nB := 1 to Len(aArrayTmp [ nA , 2 ])
				cRetBody += ::WSLoadMsg( aArrayTmp [ nA , 2 , nB] )
			Next
		Endif
	Endif		 
	cRetBody += CRLF
Next

// Retirada a descricao "Erro Tecnico" para nao confundir o usuario
If AT("Erro Técnico: ",cRetBody) > 0
	cRetBody := StrTran(cRetBody, "Erro Técnico: ", "")
Endif

Return cRetBody

//-------------------------------------------------------------------
/*/{Protheus.doc} WSLoadMsg

@author		Aldo Marini
@since		16/07/2011
@version	1.0
@return		NIL
@obs		Prepara a mensagem de email conforme as propriedades passadas
/*/
//-------------------------------------------------------------------
Method WSFieldsLoadMsg( oObjMail ) class PTSREPOBJ
Local nA 			:= 0
Local nB			:= 0
Local aArrayTmp		:= ClassDataArr(oObjMail)
Local aFieldsTmp	:= {}
Local cType			:= ""
Local cField		:= ""
Local cContent		:= ""

// Devera ser desconsiderado os campos STATUSCODE E STATUSDESCRIPTION na montagem do array
// e so devera montar se existir para identificar a estrutura do method

If aScan( aArrayTmp , {|x| x[1] = 'CSTATUSCODE' } ) > 0
	For nA := 1 to Len(aArrayTmp)

		cField	:= aArrayTmp [ nA , 1 ]

		If !( AllTrim(cField) == "CSTATUSCODE" .Or. AllTrim(cField) == "CSTATUSDESCRIPTION" )
			cType	:= ""
			cContent:= ""
	
			If ValType(aArrayTmp [ nA , 2 ]) == "C"
				 cContent := aArrayTmp [ nA , 2 ]
				 cType := "C"
			ElseIf ValType(aArrayTmp [ nA , 2 ]) == "D"
				 cContent := DTOC(aArrayTmp [ nA , 2 ])
				 cType := "D"
			ElseIf ValType(aArrayTmp [ nA , 2 ]) == "N"
				 cContent := Str(aArrayTmp [ nA , 2 ])
				 cType := "N"
			ElseIf ValType(aArrayTmp [ nA , 2 ]) == "L"
				 cContent := If(aArrayTmp [ nA , 2 ],".T.",".F.")
				 cType := "L"
			ElseIf ValType(aArrayTmp [ nA , 2 ]) == "A"
				If LEN(aArrayTmp [ nA , 2 ]) > 0
					For nB := 1 to Len(aArrayTmp [ nA , 2 ])
						aAdd(aFieldsTmp , ::WSFieldsLoadMsg( aArrayTmp [ nA , 2 , nB] ) )
					Next
				Endif
			Endif		 
			aAdd(aFieldsTmp, { cField , cType, cContent } )
		Endif
	Next
Endif

Return aFieldsTmp


//-------------------------------------------------------------------
/*/{Protheus.doc} WSInsertSync

@author		Aldo Marini
@since		29/08/2012
@version	1.0
@return		NIL
@obs		Insere os registros na tabela de syncronismo futuro
/*/
//-------------------------------------------------------------------
Method WSInsertSync( oObject , cExternalKey , aService ) class PTSREPOBJ	

Local aArea			:= GetArea()
Local aFieldsTmp 	:= (::WSFieldsLoadMsg( oObject ))
Local nF			:= 0
Local cID			:= ""                                         
Local cTab			:= "SYNC_TSA"
Local lTemRR2 		:= AliasInDic("RR2")

If Len(aFieldsTmp) == 0
	aAdd(aFieldsTmp, { " " , "X" , cExternalKey} )
Endif

//Teste de abertura de arquivo de sincronismo de registros deletados 
If !lTemRR2
	TSAOpenSync()
	cCpoId		:= "ID"
	cCompany	:= "COMPANY"
	cBranchC	:= "BRANCH_C"
	cBranchE	:= "BRANCH_E"
	cRegister	:= "REGISTER"
	cURL		:= "URL"
	cObject		:= "TSAOBJECT"
	cMethod		:= "TSAMETHOD"
	cSequen		:= "TSASEQUENC"
	cCommand	:= "TSACOMMAND"
	cProperty	:= "PROPERTY"
	cTypeData	:= "TYPE_DATA"
	cContent	:= "TSACONTENT"
	cLenght		:= "TSALENGHT"
Else
	fMigrRR2()
	dbSelectArea("RR2")
	cTab 		:= "RR2"
	cCpoId		:= "RR2_ID"
	cCompany	:= "RR2_COMPAN"
	cBranchC	:= "RR2_BRANCC"
	cBranchE	:= "RR2_BRANCE"
	cRegister	:= "RR2_REGIST"
	cURL		:= "RR2_URL"
	cObject		:= "RR2_OBJECT"
	cMethod		:= "RR2_METHOD"
	cSequen		:= "RR2_SEQUEN"
	cCommand	:= "RR2_COMMAN"
	cProperty	:= "RR2_PROPER"
	cTypeData	:= "RR2_TYPEDA"
	cContent	:= "RR2_CONTEN"
	cLenght		:= "RR2_LENGTH"
EndIf
	
// Grava o Log dos registros deletados
If Select(cTab) > 0 
	If Len( aFieldsTmp ) > 0 
		cID := dToS(Date())+Substr(Time(), 1, 2)+Substr(Time(), 4, 2)+StrZero(Randomize(0, 99), 2)
		If lTemRR2 .And. RR2->( dbSeek(cID) )
			cID := dToS(Date())+Substr(Time(), 1, 2)+Substr(Time(), 4, 2)+StrZero(Randomize(0, 99), 2)
		EndIf
		For nF := 1 to Len(aFieldsTmp)
			RecLock(cTab,.T.)
				&(cCpoId)	:= cID
				&(cCompany)	:= cEmpAnt
				&(cBranchC)	:= cFilAnt
				&(cBranchE)	:= SRA->RA_FILIAL
				&(cRegister):= SRA->RA_MAT
				&(cURL)		:= aService [5]
				&(cObject)	:= aService [2]
				&(cMethod)	:= aService [3]
				&(cSequen)	:= StrZero(nF,2)
     			&(cCommand)	:= aService[4]
				&(cProperty):= aFieldsTmp [ nF , 1 ]
				&(cTypeData):= aFieldsTmp [ nF , 2 ]
				&(cContent)	:= aFieldsTmp [ nF , 3 ]
				&(cLenght)	:= Len(aFieldsTmp [ nF , 3 ])
			MsUnLock()
	    Next
	Endif
Endif

RestArea( aArea )

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ WSTSAEmpresa     ³ Autor ³ RH - Inovacao     ³ Data ³ 26/04/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna empresa + Filial + nome da filial para os WS           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nenhum                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ponto Eletronico                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function WSTSAEmpresa(nTipo,cFilBsc)
Local cRet 		:= SM0->M0_CODIGO+SM0->M0_CODFIL+SM0->M0_FILIAL
Local aArea		:= GetArea()
Local nRecSM0	:= SM0->(Recno())

Default nTipo 	:= 1 	// 1-Empresa+Filial+Nome Filial 2-Empresa+Filial
Default cFilBsc	:= SRA->RA_FILIAL

cFilBsc	:= IF(Empty(cFilBsc),cFilAnt,cFilBsc)

dbSelectArea("SM0")
dbSetOrder(1)
If SM0->( dbSeek( cEmpAnt + cFilBsc) )
	If nTipo == 1
		cRet := AllTrim(cEmpAnt + SM0->M0_CODFIL + SM0->M0_FILIAL)
	ElseIf nTipo == 2
		cRet := cEmpAnt + SM0->M0_CODFIL
	Endif	
Endif
SM0->(dbGoTo(nRecSM0))
	
RestArea(aArea)
Return cRet                     



/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ TSAOpenSync      ³ Autor ³ RH - Inovacao     ³ Data ³ 30/08/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realize a criacao e/ou atualizacao da tabela de sincronismo    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nenhum                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ponto Eletronico                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TSAOpenSync()

Local aTopInfo := {}

Local oTblStru := FWTableStruct():New("SYNC_PROTHEUS_TSA","SYNC_TSA",__cRDD)

oTblStru:AddField( "ID"			,"C",14				,0)
oTblStru:AddField( "COMPANY"	,"C",2				,0)
oTblStru:AddField( "BRANCH_C"	,"C",FwSizeFilial()	,0)
oTblStru:AddField( "BRANCH_E"	,"C",FwSizeFilial()	,0)
oTblStru:AddField( "REGISTER"	,"C",6				,0)
oTblStru:AddField( "URL"		,"C",250			,0)
oTblStru:AddField( "TSAOBJECT"	,"C",250			,0)
oTblStru:AddField( "TSAMETHOD"	,"C",250			,0)
oTblStru:AddField( "TSASEQUENC"	,"C",2				,0)
oTblStru:AddField( "TSACOMMAND"	,"C",250			,0)
oTblStru:AddField( "PROPERTY"	,"C",250			,0)
oTblStru:AddField( "TYPE_DATA"	,"C",1				,0)
oTblStru:AddField( "TSACONTENT"	,"C",250			,0)
oTblStru:AddField( "TSALENGHT"	,"N",3				,0)

oTblStru:SetPrimaryKey( { "ID" , "TSASEQUENC" , "COMPANY" } )

oTblStru:AddIndex( "01" , { "ID","COMPANY","BRANCH_C","BRANCH_E","REGISTER" } )

oTblStru:Activate()

oTblDDL := FWTableDDL():New()

aTopInfo := FWGetTopInfo()

oTblDDL:AddDbAcess( aTopInfo[1], aTopInfo[2], aTopInfo[3], aTopInfo[4], aTopInfo[5], aTopInfo[6], AdvConnect() )
oTblDDL:SetTableStruct(oTblStru)
oTblDDL:Activate()
oTblDDL:CreateTable()
oTblDDL:OpenTable()

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fNotBlock      ³ Autor ³ Luis Artuso         ³ Data ³ 25/10/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida se turno esta bloqueado para uso.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nenhum                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ponto Eletronico                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function fNotBlock(cFil , cTurno)

Local cAliasSR6		:= 'SR6'
Local lRet			:= .F.
Local aAreaSPJ		:= {}
				
aAreaSPJ	:= SPJ->( GetArea() )

If (cAliasSR6)->( dbSeek( cFil + cTurno ) ) // Localiza o turno do funcionario no cadastro de turnos							
	If ( !(cAliasSR6)->R6_MSBLQL == '1' ) // Se registro for permitido para uso
		lRet	:= .T.
	EndIf
EndIf

RestArea(aAreaSPJ)

Return lRet


/*{Protheus.doc} fValidRet

Funcao que verifica o retorno da execucao do webservice e reenvia o XML caso haja falha na rede
 
@author Allyson Mesashi
@since 28/07/2015
@version P11 R8
@Return lRet Retorna se o XML foi processado corretamente
*/
Static Function fValidRet( bBloco )

Local cRet 	:= GetWscError()
Local lRet 	:= .T.
Local nVezes	:= 0

Default bBloco := { || .T. }

Begin Sequence
	If !Empty(cRet)
		//Se for falha na rede, tenta o reenvio do XML por 5x
		If  "WSCERR045" $ cRet
			While nVezes < 5
				eVal( bBloco )
				cRet 	:= GetWscError()
				If Empty(cRet) .Or. !("WSCERR045" $ cRet)
					Break
				EndIf
				nVezes++
			End While
			lRet := .F.
		//Se nao, envia o flag de que nao foi processado corretamente
		Else
			lRet := .F.
		EndIf
	EndIf
End Sequence

Return lRet
