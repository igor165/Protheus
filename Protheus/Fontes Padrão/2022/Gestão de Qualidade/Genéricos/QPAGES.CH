#ifndef _QPAGES_CH
#define _QPAGES_CH
#xcommand @ <nRow>,<nCol> QPAGES <oPag> ;
				 [ SIZE <nWidth>, <nHeight> ] ;
				 [ OF <oWnd> ] ;
				 [ DIALOGS <DlgName,...> ] ;
				 [ OPTION <nOption> ] ;
				 [ <click:ON CHANGE> <bChange>];
				 [ <Actives: ACTIVE> <aActive> ] ;
				 [ FONT <oFont> ] ;
		 => ;
			 <oPag> := TQPages():New( <nRow>, <nCol>, <nHeight>, <nWidth>,;
			 <oWnd>, [{<DlgName>}], <nOption>, [<{bChange}>],[<aActive>],[<oFont>] )

#endif
