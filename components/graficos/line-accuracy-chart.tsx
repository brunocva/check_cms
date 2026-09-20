'use client'

import { CartesianGrid, Line, LineChart, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts'
import { formatDate } from '@/lib/utils/format'
import type { AccuracyPoint } from '@/lib/utils/metrics'

// Evolução do % de acerto, uma sessão finalizada por ponto.
export function LineAccuracyChart({ data }: { data: AccuracyPoint[] }) {
  const chartData = data.map((point, index) => ({ ...point, label: `#${index + 1}` }))

  return (
    <ResponsiveContainer width="100%" height={280}>
      <LineChart data={chartData} margin={{ top: 8, right: 16, left: -16, bottom: 0 }}>
        <CartesianGrid strokeDasharray="3 3" className="stroke-border" />
        <XAxis dataKey="label" tick={{ fontSize: 12 }} stroke="currentColor" className="text-muted-foreground" />
        <YAxis domain={[0, 100]} tick={{ fontSize: 12 }} stroke="currentColor" className="text-muted-foreground" />
        <Tooltip
          formatter={(value: number) => [`${value}%`, 'Acerto']}
          labelFormatter={(label, payload) => (payload?.[0] ? formatDate(payload[0].payload.date) : label)}
          contentStyle={{ borderRadius: 8, fontSize: 12 }}
        />
        <Line type="monotone" dataKey="score" stroke="#6366f1" strokeWidth={2} dot={{ r: 3 }} activeDot={{ r: 5 }} />
      </LineChart>
    </ResponsiveContainer>
  )
}
