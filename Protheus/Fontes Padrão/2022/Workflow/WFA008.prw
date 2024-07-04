#include "SIGAWF.CH"

#DEFINE	MV_TDMLBOX	1
#DEFINE	MV_TDADMIN	2
#DEFINE	MV_TDSNDAU	3
#DEFINE	MV_TDENVAT	4
#DEFINE	MV_TDMLAUT	5
#DEFINE	MV_TDZIPEX	6
#DEFINE	MV_TDENV		7
#DEFINE	MV_TDREC		8
#DEFINE	MV_TDNF001	9
#DEFINE	MV_TDNF002	10
#DEFINE	MV_TDNF003	11

function WFA008()
	Local oDlg
	Local nFolder
	Local cDir, cCaption := "Parametros do Transdados"
	Local aFolders, aFields
	
	aFields := {}

	AAdd( aFields, { "MV_TDMLBOX", Space( 20 ),, WFMBoxList() } )	// Caixa de correio do workflow
	AAdd( aFields, { "MV_TDADMIN", Space( 50 ), } )		// E-mail do(s) administrador(es)
	AAdd( aFields, { "MV_TDSNDAU", .t., } )				// Envio automatico de mensagens
	AAdd( aFields, { "MV_TDENVAT", .t., } )				// Enviar somente com arquivos anexos
	AAdd( aFields, { "MV_TDMLAUT", Space( 255 ), } )	// Emails autorizados
	AAdd( aFields, { "MV_TDZIPEX", Space( 10 ), } )		// Extensao de arquivo compactado
	AAdd( aFields, { "MV_TDENV  ", "enviar", } )			// Diretorio de envio 
	AAdd( aFields, { "MV_TDREC  ", "receber", } )		// Diretorio de recebimento
	AAdd( aFields, { "MV_TDNF001", .t., } )				// Resumo de envio
	AAdd( aFields, { "MV_TDNF002", .t., } )				// Resumo do recebimento
	AAdd( aFields, { "MV_TDNF003", .t., } )				// Erro de execucao

	aFields := WFAGetMV( aFields )

   aFolders := {}
	AAdd( aFolders, "Correio" )
	AAdd( aFolders, "Diretorios de trabalho" )
	AAdd( aFolders, "Notificacao" )
	AAdd( aFolders, "E-mails Autorizados" )
	
	DEFINE MSDIALOG oDlg FROM 92,69 TO 450,575 TITLE cCaption PIXEL
	DEFINE FONT oFont NAME "Arial" SIZE 0, -14 BOLD

	oFolder := TFolder():New( 15, 05, aFolders, aFolders, oDlg, nFolder,,,.T., .T., 240, 150 )
	
	nFolder := 1	// Correio
	@   5, 10 GROUP oGroup TO 60,230 LABEL " Caixa de Correio: " PIXEL OF oFolder:aDialogs[ nFolder ]
	@  28, 15 SAY "Conta:" COLOR CLR_BLUE PIXEL OF oFolder:aDialogs[ nFolder ]
	@  28, 55 COMBOBOX aFields[ MV_TDMLBOX,3 ] VAR aFields[ MV_TDMLBOX,2 ] ITEMS aFields[ MV_TDMLBOX,4 ] PIXEL SIZE 75, 10 OF oFolder:aDialogs[ nFolder ]

	@  65, 10 GROUP oGroup TO 130,230 LABEL " Composicao da mensagem: " PIXEL OF oFolder:aDialogs[ nFolder ]
	@  78, 15 CHECKBOX aFields[ MV_TDENVAT,3 ] VAR aFields[ MV_TDENVAT,2 ] PROMPT "Enviar somente com arquivos anexos." PIXEL SIZE 150, 10 OF oFolder:aDialogs[ nFolder ] 
	@  91, 15 CHECKBOX aFields[ MV_TDSNDAU,3 ] VAR aFields[ MV_TDSNDAU,2 ] PROMPT "Envio automatico." PIXEL SIZE 150, 10 OF oFolder:aDialogs[ nFolder ]

   nFolder := 2	// Diretorios de trabalho
	@   5, 10 GROUP oGroup TO 60,230 LABEL " Diretorio de envio: " PIXEL OF oFolder:aDialogs[ nFolder ]
	@  30, 15 SAY "\TRANSDADOS\EMP" + cEmpAnt + "\" COLOR CLR_BLUE PIXEL OF oFolder:aDialogs[ nFolder ]
	@  28, 75 MSGET  aFields[ MV_TDENV,3 ] VAR aFields[ MV_TDENV,2 ] PICTURE "@!" PIXEL SIZE 150, 10 OF oFolder:aDialogs[ nFolder ]

	@  65, 10 GROUP oGroup TO 130,230 LABEL " Diretorio de recebimento: " PIXEL OF oFolder:aDialogs[ nFolder ]
	@  90, 15 SAY "\TRANSDADOS\EMP" + cEmpAnt + "\" COLOR CLR_BLUE PIXEL OF oFolder:aDialogs[ nFolder ]
	@  88, 75 MSGET  aFields[ MV_TDREC,3 ] VAR aFields[ MV_TDREC,2 ] PICTURE "@!" PIXEL SIZE 150, 10 OF oFolder:aDialogs[ nFolder ]

   nFolder := 3	// Notificacao
	@   5, 10 GROUP oGroup TO 60,230 LABEL " E-mail do administrador: " PIXEL OF oFolder:aDialogs[ nFolder ] 
	@  28, 15 SAY "Endereco:" COLOR CLR_BLUE PIXEL OF oFolder:aDialogs[ nFolder ]
	@  28, 55 MSGET  aFields[ MV_TDADMIN,3 ] VAR aFields[ MV_TDADMIN,2 ] PIXEL SIZE 170, 10 OF oFolder:aDialogs[ nFolder ]

	@  65, 10 GROUP oGroup TO 130,230 LABEL " Enviar notificacao: " PIXEL OF oFolder:aDialogs[ nFolder ]
	@  78, 15 CHECKBOX aFields[ MV_TDNF001,3 ] VAR aFields[ MV_TDNF001,2 ] PROMPT "Resumo do envio." PIXEL SIZE 200, 10 OF oFolder:aDialogs[ nFolder ] 
	@  91, 15 CHECKBOX aFields[ MV_TDNF002,3 ] VAR aFields[ MV_TDNF002,2 ] PROMPT "Resumo do recebimento." PIXEL SIZE 200, 10 OF oFolder:aDialogs[ nFolder ]
	@ 104, 15 CHECKBOX aFields[ MV_TDNF003,3 ] VAR aFields[ MV_TDNF003,2 ] PROMPT "Erro de execucao." PIXEL SIZE 200, 10 OF oFolder:aDialogs[ nFolder ]

   nFolder := 4	// E-mails autorizados
	@   5, 10 GROUP oGroup TO 130,230 LABEL " Enderecos eletronicos: " PIXEL OF oFolder:aDialogs[ nFolder ]
	@  15, 15 GET aFields[ MV_TDMLAUT,3 ] VAR aFields[ MV_TDMLAUT,2 ] MEMO SIZE 210,110 PIXEL OF oFolder:aDialogs[ nFolder ]

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg, {|| WFASetMV( aFields ), oDlg:End() }, {|| oDlg:End() } )
return
