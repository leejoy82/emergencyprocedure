<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>Ops Procedures</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script crossorigin src="https://unpkg.com/react@18/umd/react.production.min.js"></script>
    <script crossorigin src="https://unpkg.com/react-dom@18/umd/react-dom.production.min.js"></script>
    <script src="https://unpkg.com/@babel/standalone/babel.min.js"></script>
    <style>
        /* Hide scrollbar for Chrome, Safari and Opera */
        .no-scrollbar::-webkit-scrollbar {
            display: none;
        }
        /* Hide scrollbar for IE, Edge and Firefox */
        .no-scrollbar {
            -ms-overflow-style: none;  /* IE and Edge */
            scrollbar-width: none;  /* Firefox */
        }
        body {
            -webkit-tap-highlight-color: transparent;
        }
    </style>
</head>
<body class="bg-gray-900 h-screen w-screen overflow-hidden flex justify-center items-center">

    <div id="root" class="w-full h-full max-w-md bg-gray-50 flex flex-col shadow-2xl overflow-hidden relative">
        <!-- React App mounts here -->
    </div>

    <script type="text/babel">
        const { useState, useMemo } = React;

        // --- ICON COMPONENT & DATA ---
        // Simple SVG paths to replace Lucide icons so this runs without external dependencies
        const iconPaths = {
            search: "M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z",
            chevronRight: "M9 5l7 7-7 7",
            x: "M6 18L18 6M6 6l12 12",
            phone: "M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z",
            info: "M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z",
            
            // Procedure specific icons
            shieldAlert: "M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z M12 8v4 M12 16h.01", // Attack
            siren: "M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5", // Bomb (Using generic layer icon as siren abstract) -> replacing with better Alert
            flame: "M8.5 14.5A2.5 2.5 0 0011 12c0-1.38-.5-2-1-3-1.072-2.143-.224-4.054 2-6 .5 2.5 2 4.9 4 6.5 2 1.6 3 3.5 3 5.5a7 7 0 11-14 0c0 1.1.2 2.2.5 3.3a9 9 0 00.9-5.8z", // Fire
            users: "M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z", // Disorder
            plane: "M12 2L2 7l10 5 10-5-10-5z", // Drone (using layer/abstract) -> Using paper plane style: M2 12h20L2 2v20z no that's wrong. Let's use simple shape
            wind: "M9.59 4.59A2 2 0 1111 8H2m10.59 11.41A2 2 0 1014 16H2m15.73-8.27A2.5 2.5 0 1119.5 12H2", // Gas
            lock: "M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z", // Lockdown
            baby: "M12 2a10 10 0 1010 10A10 10 0 0012 2zm0 18a8 8 0 118-8 8 8 0 01-8 8zm0-14a3.5 3.5 0 103.5 3.5A3.5 3.5 0 0012 6zm0 5a1.5 1.5 0 111.5-1.5A1.5 1.5 0 0112 11zm0 2a5 5 0 00-5 2.5 1 1 0 001.6 1.2A3 3 0 0112 15a3 3 0 013.4 1.7 1 1 0 001.6-1.2A5 5 0 0012 13z", // Child (Using generic face/smile for now)
            stethoscope: "M5.5 16a3.5 3.5 0 01-.369-6.98 4 4 0 117.753-1.977A4.5 4.5 0 1113.5 16h-8z", // Medical (Using Cloud/abstract) - switching to heart
            zap: "M13 2L3 14h9l-1 8 10-12h-9l1-8z", // Power
            flask: "M9 3v2m6-2v2M9 3h6m-5 0v2.6a2 2 0 01-.2 1.1l-2.6 5.3A2 2 0 008.3 17h7.4a2 2 0 001.1-3l-2.6-5.3a2 2 0 01-.2-1.1V5", // Chemical
            building: "M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4", // Structural
            droplets: "M12 2.69l5.66 5.66a8 8 0 11-11.31 0z", // Flood
        };

        const Icon = ({ name, className }) => (
            <svg 
                xmlns="http://www.w3.org/2000/svg" 
                viewBox="0 0 24 24" 
                fill="none" 
                stroke="currentColor" 
                strokeWidth="2" 
                strokeLinecap="round" 
                strokeLinejoin="round" 
                className={className}
            >
                <path d={iconPaths[name] || iconPaths.info} />
            </svg>
        );

        // --- APP COMPONENT ---
        const OpsProceduresApp = () => {
            const [searchTerm, setSearchTerm] = useState('');
            const [selectedProcedure, setSelectedProcedure] = useState(null);
            const [activeTab, setActiveTab] = useState('procedures'); 

            // Procedure Data
            const procedures = [
                {
                    id: 'attack',
                    title: 'Vehicle or Weapon Attack',
                    iconName: 'shieldAlert',
                    color: 'bg-red-50',
                    iconColor: 'text-red-600',
                    keywords: 'terrorist gun knife run hide tell ethane',
                    sections: [
                        {
                            title: 'Immediate Action',
                            steps: [
                                'RUN from Danger',
                                'HIDE if necessary',
                                'TELL the police by dialling 999',
                                'Prioritise your own safety'
                            ]
                        },
                        {
                            title: 'ETHANE Details',
                            steps: [
                                '1. Exact location of incident',
                                '2. Type of incident',
                                '3. Hazards',
                                '4. Access routes',
                                '5. Number of casualties',
                                '6. Emergency services already involved'
                            ]
                        },
                        {
                            title: 'Armed Response Protocol',
                            steps: [
                                'Remain in contact with emergency services',
                                'Let Shop Watch know what is happening',
                                'Keep your hands in view',
                                'Don’t make sudden movements',
                                'Expect to be treated very firmly'
                            ]
                        },
                        {
                            title: 'Aftermath',
                            steps: [
                                'Provide first aid to any casualties',
                                'Turn off utilities',
                                'Use emergency grab bags (Trust/Ops offices)',
                                'Communicate via megaphone',
                                'Discretely cover upsetting scenes',
                                'Gather witness info/statements',
                                'Keep a decision log',
                                'Press: Answer "No comment" and refer to Marketing/Comms'
                            ]
                        }
                    ]
                },
                {
                    id: 'bomb',
                    title: 'Bomb / Bomb Threat',
                    iconName: 'siren',
                    color: 'bg-orange-50',
                    iconColor: 'text-orange-600',
                    keywords: 'explosive package suspect phone',
                    sections: [
                        {
                            title: 'General',
                            steps: ['Inform police immediately. Follow their advice.']
                        },
                        {
                            title: 'Phone Threats',
                            steps: [
                                'Remain calm and listen carefully',
                                'Keep caller on the line',
                                'Alert someone else to dial 999',
                                'Take the number of the caller',
                                'Complete "bomb threat checklist"'
                            ]
                        },
                        {
                            title: 'Search Guidance (HOT)',
                            steps: [
                                'Hidden – has the item been concealed?',
                                'Obvious – is it obviously suspicious?',
                                'Typical – Is it typical for this area?'
                            ]
                        },
                        {
                            title: 'Evacuation',
                            steps: [
                                'PA: "Due to a security alert, we are evacuating the building."',
                                'Muster Points: Eureka car park (bags), Shay stadium (vehicles)',
                                'Leave doors/windows open',
                                'Do NOT use fire alarm',
                                'No radios within 15m of suspicious item',
                                'Avoid exiting via South Gate',
                                'Lock gates once empty'
                            ]
                        }
                    ]
                },
                {
                    id: 'disorder',
                    title: 'Public Disorder / Crime',
                    iconName: 'users',
                    color: 'bg-blue-50',
                    iconColor: 'text-blue-600',
                    keywords: 'fight drunk violence theft asb',
                    sections: [
                        {
                            title: 'Actions',
                            steps: [
                                'Assess risk and contact 999 or 101',
                                'Use Shop Watch to seek assistance',
                                'Work in PAIRS. Do not confront alone.',
                                'Use training to diffuse or eject',
                                'Seek help from tenants',
                                'Log via ASB procedure',
                                'Ensure licensed staff saves CCTV data',
                                'Keep a log of decision making'
                            ]
                        }
                    ]
                },
                {
                    id: 'drone',
                    title: 'Unmanned Flying Aircraft (Drone)',
                    iconName: 'plane',
                    color: 'bg-slate-50',
                    iconColor: 'text-slate-600',
                    keywords: 'uav fly camera spy',
                    sections: [
                        {
                            title: 'Sighting',
                            steps: [
                                'Check if carrying anything. If yes, contact 999.',
                                'Alert Ops team',
                                'Locate pilot (likely <150m)',
                                'Ask pilot to land away from building'
                            ]
                        },
                        {
                            title: 'If It Lands/Crashes',
                            steps: [
                                'Contact police',
                                'Avoid touching. If necessary, box it as evidence.',
                                'Log as ASB incident',
                                'Save CCTV evidence'
                            ]
                        }
                    ]
                },
                {
                    id: 'fire',
                    title: 'Fire or Fire Alarm',
                    iconName: 'flame',
                    color: 'bg-red-50',
                    iconColor: 'text-red-500',
                    keywords: 'burn smoke alarm evacuation',
                    sections: [
                        {
                            title: 'False Alarm',
                            steps: [
                                'Investigate area on panel map',
                                'Remove source and reset panel',
                                'Tell First County it is false',
                                'Record in logbook'
                            ]
                        },
                        {
                            title: 'Real Fire',
                            steps: [
                                'Hit "Sound Alarms" if not sounding',
                                'Call Fire Brigade',
                                'Tackle with extinguisher ONLY if safe',
                                'Switch off gas/electricity mains',
                                'Prepare South Gate for fire engine',
                                'Evacuate away from fire to Courtyard Centre'
                            ]
                        },
                        {
                            title: 'Evacuation',
                            steps: [
                                'Move to centre of courtyard',
                                'Use megaphone to communicate',
                                'Use evac chair for disabled visitors if safe',
                                'Account for all tenants/teams',
                                'Senior Ops to liaise with Fire Service'
                            ]
                        }
                    ]
                },
                {
                    id: 'gas',
                    title: 'Gas Leak',
                    iconName: 'wind',
                    color: 'bg-yellow-50',
                    iconColor: 'text-yellow-600',
                    keywords: 'smell leak fumes',
                    sections: [
                        {
                            title: 'Procedure',
                            steps: [
                                'Check area. Get second opinion on smell.',
                                'If confirmed: Contact Emergency Gas Helpline',
                                'Communicate with tenants',
                                'Liaise with Gas Board re: evacuation',
                                'Inform neighbours'
                            ]
                        }
                    ]
                },
                {
                    id: 'lockdown',
                    title: 'Lock Down / Invacuation',
                    iconName: 'lock',
                    color: 'bg-purple-50',
                    iconColor: 'text-purple-600',
                    keywords: 'security alert gates shut',
                    sections: [
                        {
                            title: 'Procedure',
                            steps: [
                                'Contact 999 & Shop Watch',
                                'Lock gates (inc Square Chapel & SE lift)',
                                'PA Announcement: "Due to a security alert... we ask you to stay in the building"',
                                'Direct public to safe spaces (Deli, Trading Rooms)',
                                'Staff to provide refreshments',
                                'Station high-viz staff in courtyard',
                                'Licensed staff to monitor CCTV',
                                'Wait for police guidance to reopen'
                            ]
                        }
                    ]
                },
                {
                    id: 'child',
                    title: 'Lost Child',
                    iconName: 'baby',
                    color: 'bg-pink-50',
                    iconColor: 'text-pink-500',
                    keywords: 'missing parent kid minor',
                    sections: [
                        {
                            title: 'Initial Actions',
                            steps: [
                                'Take guardian/child to Welcome Centre',
                                'Two staff members with child at ALL times',
                                'Radio "Operation Lima" with description (when safe)'
                            ]
                        },
                        {
                            title: 'Search',
                            steps: [
                                'Staff search courtyard, public areas, balconies',
                                'Monitor gates/CCTV',
                                'PA: "If you have lost a family member, please report to the Welcome Centre"',
                                'Contact Shop Watch',
                                'Contact Police if not found'
                            ]
                        }
                    ]
                },
                {
                    id: 'medical',
                    title: 'Medical Incident',
                    iconName: 'stethoscope',
                    color: 'bg-green-50',
                    iconColor: 'text-green-600',
                    keywords: 'hurt sick ambulance injury',
                    sections: [
                        {
                            title: 'Procedure',
                            steps: [
                                'Call 999 if serious',
                                'Move to first aid room if possible',
                                'Perform first aid (work in pairs)',
                                'Use equipment (wheelchair/defib) as needed',
                                'Prepare South Gate for ambulance',
                                'Complete accident form',
                                'Save CCTV data'
                            ]
                        }
                    ]
                },
                {
                    id: 'crowd',
                    title: 'Overcrowding',
                    iconName: 'users',
                    color: 'bg-indigo-50',
                    iconColor: 'text-indigo-600',
                    keywords: 'capacity busy full people',
                    sections: [
                        {
                            title: 'Monitoring',
                            steps: [
                                'Monitor footfall counters',
                                'Know max capacity on event days'
                            ]
                        },
                        {
                            title: 'Action (Over 3,000/Capacity)',
                            steps: [
                                'Staff on gates to implement "One In, One Out"',
                                'PA Announcement: "Due to large number of people... implementing one in one out"',
                                'Wait for safe levels before reopening'
                            ]
                        }
                    ]
                },
                {
                    id: 'power',
                    title: 'Loss of Power',
                    iconName: 'zap',
                    color: 'bg-yellow-100',
                    iconColor: 'text-yellow-500',
                    keywords: 'electric lights out blackout',
                    sections: [
                        {
                            title: 'Actions',
                            steps: [
                                'Contact 105 and Shop Watch',
                                'If just PH: Contact electrical contractors',
                                'Check safety systems (Fire alarm, CCTV)',
                                'Check access control doors',
                                'Close building if >1 hour or safety failure'
                            ]
                        }
                    ]
                },
                {
                    id: 'chemical',
                    title: 'Bio / Chem / Radiological',
                    iconName: 'flask',
                    color: 'bg-lime-50',
                    iconColor: 'text-lime-600',
                    keywords: 'attack acid powder substance',
                    sections: [
                        {
                            title: 'Safety',
                            steps: [
                                'Take victim to refuse area/first aid room',
                                'AVOID TOUCHING. Direct them to treat themselves.',
                                'Clear/isolate contaminated area.',
                                'Contact 999'
                            ]
                        },
                        {
                            title: 'Advice to Victim',
                            steps: [
                                'Seek fresh air',
                                'Rinse itchy skin with water',
                                'Remove outer clothing (cut off)',
                                'Do not eat/drink/smoke',
                                'Remove substances with dry absorbent material'
                            ]
                        }
                    ]
                },
                {
                    id: 'structural',
                    title: 'Structural Failure',
                    iconName: 'building',
                    color: 'bg-gray-100',
                    iconColor: 'text-gray-600',
                    keywords: 'collapse wall damage building',
                    sections: [
                        {
                            title: 'Actions',
                            steps: [
                                'Clear area/cordon off',
                                'Remove obvious hazards if safe',
                                'Inform tenants',
                                'Organise structural inspection',
                                'Put up signage'
                            ]
                        }
                    ]
                },
                {
                    id: 'flood',
                    title: 'Flood or Major Leak',
                    iconName: 'droplets',
                    color: 'bg-blue-100',
                    iconColor: 'text-blue-500',
                    keywords: 'water pipe burst wet',
                    sections: [
                        {
                            title: 'Actions',
                            steps: [
                                'Isolate water supply',
                                'Move items to safety',
                                'Evacuate area',
                                'Check safety systems still work',
                                'Contact M&E provider',
                                'Clean with assistance',
                                'Take photos'
                            ]
                        }
                    ]
                }
            ];

            const contacts = [
                { name: 'M&E Provider (T Clarke)', number: '01132 586711' },
                { name: 'Library', number: '01422 392633' },
                { name: 'Library (Alt)', number: '01422 288000' },
                { name: 'Orange Box', number: '01422 288000' },
                { name: 'Industrial Museum (Tim)', number: '07954 493490' },
                { name: 'Industrial Museum (Andrew)', number: '07786 967184' },
                { name: 'Piece Mill (Jesse)', number: '07387 233294' },
            ];

            const filteredProcedures = useMemo(() => {
                if (!searchTerm) return procedures;
                const lowerTerm = searchTerm.toLowerCase();
                return procedures.filter(p => 
                p.title.toLowerCase().includes(lowerTerm) || 
                p.keywords.includes(lowerTerm)
                );
            }, [searchTerm]);

            const handleProcedureClick = (proc) => {
                setSelectedProcedure(proc);
            };

            const closeDetail = () => {
                setSelectedProcedure(null);
            };

            return (
                <div className="flex flex-col h-full bg-gray-50 font-sans text-slate-800">
                
                    {/* Header */}
                    <div className="bg-slate-900 text-white p-4 pt-6 shadow-md z-10 flex-shrink-0">
                        <h1 className="text-xl font-bold tracking-tight">Ops Procedures</h1>
                        <p className="text-xs text-slate-400">Emergency Crib Sheets</p>
                    </div>

                    {/* Main Content Area */}
                    <div className="flex-1 overflow-y-auto relative no-scrollbar">
                        
                        {/* Navigation Tabs */}
                        {!selectedProcedure && (
                        <div className="flex bg-white border-b sticky top-0 z-20 shadow-sm">
                            <button 
                            onClick={() => setActiveTab('procedures')}
                            className={`flex-1 py-3 text-sm font-semibold transition-colors ${activeTab === 'procedures' ? 'border-b-2 border-blue-600 text-blue-600 bg-blue-50/50' : 'text-gray-500'}`}
                            >
                            Procedures
                            </button>
                            <button 
                            onClick={() => setActiveTab('contacts')}
                            className={`flex-1 py-3 text-sm font-semibold transition-colors ${activeTab === 'contacts' ? 'border-b-2 border-blue-600 text-blue-600 bg-blue-50/50' : 'text-gray-500'}`}
                            >
                            Contacts
                            </button>
                        </div>
                        )}

                        {/* Procedures List */}
                        {!selectedProcedure && activeTab === 'procedures' && (
                        <div className="p-4 space-y-3 pb-20">
                            <div className="relative mb-4">
                            <input
                                type="text"
                                placeholder="Search (e.g., 'fire')..."
                                className="w-full pl-10 pr-4 py-3 rounded-xl border border-gray-200 shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 bg-white"
                                value={searchTerm}
                                onChange={(e) => setSearchTerm(e.target.value)}
                            />
                            <div className="absolute left-3 top-3.5 text-gray-400 w-5 h-5">
                                <Icon name="search" className="w-5 h-5" />
                            </div>
                            </div>

                            {filteredProcedures.length === 0 ? (
                            <div className="text-center py-10 text-gray-500">
                                <div className="inline-block p-4 bg-gray-200 rounded-full mb-2">
                                    <Icon name="info" className="w-6 h-6 text-gray-400" />
                                </div>
                                <p>No procedures found.</p>
                            </div>
                            ) : (
                            filteredProcedures.map((proc) => (
                                <div 
                                key={proc.id}
                                onClick={() => handleProcedureClick(proc)}
                                className={`flex items-center p-4 rounded-xl border border-gray-100 shadow-sm active:scale-[0.98] transition-all cursor-pointer bg-white`}
                                >
                                <div className={`p-3 rounded-full ${proc.color} mr-4 flex-shrink-0`}>
                                    <Icon name={proc.iconName} className={`w-6 h-6 ${proc.iconColor}`} />
                                </div>
                                <div className="flex-1">
                                    <h3 className="font-bold text-gray-800 text-sm">{proc.title}</h3>
                                </div>
                                <Icon name="chevronRight" className="text-gray-300 w-5 h-5" />
                                </div>
                            ))
                            )}
                        </div>
                        )}

                        {/* Contacts List */}
                        {!selectedProcedure && activeTab === 'contacts' && (
                        <div className="p-4 space-y-3 pb-20">
                            <div className="bg-yellow-50 border border-yellow-200 p-4 rounded-lg mb-4 text-sm text-yellow-800">
                            <p className="font-bold mb-1">Location of List:</p>
                            Full list is in the cupboard in the operations office.
                            </div>
                            
                            {contacts.map((contact, idx) => (
                            <a 
                                key={idx}
                                href={`tel:${contact.number.replace(/\s/g, '')}`}
                                className="flex items-center justify-between p-4 bg-white rounded-xl border border-gray-100 shadow-sm active:bg-blue-50 transition-colors"
                            >
                                <div>
                                <p className="font-bold text-gray-800 text-sm">{contact.name}</p>
                                <p className="text-blue-600 font-mono text-lg mt-1">{contact.number}</p>
                                </div>
                                <div className="bg-green-100 p-2 rounded-full">
                                    <Icon name="phone" className="w-5 h-5 text-green-600" />
                                </div>
                            </a>
                            ))}
                        </div>
                        )}

                        {/* Procedure Detail Modal */}
                        {selectedProcedure && (
                        <div className="absolute inset-0 bg-white z-30 flex flex-col animate-[slideIn_0.2s_ease-out]">
                            <div className={`p-4 ${selectedProcedure.color} border-b flex items-center justify-between sticky top-0 z-40 shadow-sm`}>
                            <div className="flex items-center space-x-3">
                                <div className="p-2 bg-white/60 rounded-full backdrop-blur-sm">
                                    <Icon name={selectedProcedure.iconName} className={`w-6 h-6 ${selectedProcedure.iconColor}`} />
                                </div>
                                <h2 className="font-bold text-lg leading-tight text-gray-900 pr-2">{selectedProcedure.title}</h2>
                            </div>
                            <button 
                                onClick={closeDetail}
                                className="p-2 bg-white/60 rounded-full hover:bg-white/90 transition-colors flex-shrink-0"
                            >
                                <Icon name="x" className="w-6 h-6 text-gray-700" />
                            </button>
                            </div>
                            
                            <div className="flex-1 overflow-y-auto p-4 space-y-6 pb-20 no-scrollbar">
                            {/* ETHANE shortcut if applicable */}
                            {selectedProcedure.id === 'attack' && (
                                <div className="bg-slate-800 text-white p-4 rounded-lg border border-slate-700 shadow-lg">
                                    <h4 className="font-bold text-yellow-400 mb-2 border-b border-slate-600 pb-1">ETHANE Reporting</h4>
                                    <ul className="text-sm space-y-2">
                                    <li><strong className="text-yellow-400">E</strong>xact location</li>
                                    <li><strong className="text-yellow-400">T</strong>ype of incident</li>
                                    <li><strong className="text-yellow-400">H</strong>azards</li>
                                    <li><strong className="text-yellow-400">A</strong>ccess routes</li>
                                    <li><strong className="text-yellow-400">N</strong>umber of casualties</li>
                                    <li><strong className="text-yellow-400">E</strong>mergency services involved</li>
                                    </ul>
                                </div>
                            )}

                            {selectedProcedure.sections.map((section, idx) => (
                                <div key={idx}>
                                <h3 className="text-xs font-bold uppercase tracking-widest text-gray-400 mb-3 border-b border-gray-100 pb-1">
                                    {section.title}
                                </h3>
                                <ul className="space-y-4">
                                    {section.steps.map((step, sIdx) => (
                                    <li key={sIdx} className="flex items-start">
                                        <span className="flex-shrink-0 w-6 h-6 rounded-full bg-slate-100 text-slate-600 flex items-center justify-center text-xs font-bold mr-3 mt-0.5 border border-slate-200">
                                        {sIdx + 1}
                                        </span>
                                        <span className="text-gray-800 text-base leading-relaxed">{step}</span>
                                    </li>
                                    ))}
                                </ul>
                                </div>
                            ))}
                            
                            <div className="bg-gray-50 p-4 rounded-lg border border-gray-200 mt-8 text-sm text-gray-500 italic text-center">
                                Log all decisions. Inform managers.
                            </div>
                            </div>
                        </div>
                        )}
                    </div>

                    {/* Footer */}
                    <div className="bg-white border-t p-2 text-center text-[10px] text-gray-400 flex-shrink-0">
                        Emergency Ops Assistant • Mobile Optimized
                    </div>

                </div>
            );
        };

        const root = ReactDOM.createRoot(document.getElementById('root'));
        root.render(<OpsProceduresApp />);
    </script>
</body>
</html>
